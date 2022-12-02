const passport = require("passport");
const fs = require("fs");
const jwt = require("jsonwebtoken");
const mysql = require("mysql");
const azureDB = require("./AzureDB");
const sqlConfig = azureDB.config;

// Create a token
const RSA_PRIVATE_KEY = fs.readFileSync("./bin/private.key");
const RSA_PUBLIC_KEY = fs.readFileSync("./bin/public.key");

function createToken(user) {
    return jwt.sign(user, RSA_PRIVATE_KEY, {
        algorithm: "RS256",
        expiresIn: 86400
    });
}
exports.getToken = createToken;

// Extract token and verify
const JwtStrategy = require("passport-jwt").Strategy;
const ExtractJwt = require("passport-jwt").ExtractJwt;

const options = {
    jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
    secretOrKey: RSA_PUBLIC_KEY
}

passport.use( new JwtStrategy(options, (jwt_payload, done) => {
    const userEmail = jwt_payload.UserEmail;

    const sqlQuery = `call rehapp.findUser(${mysql.escape(userEmail)})`;

    const sqlConnection = mysql.createConnection(sqlConfig);

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) return done(error, false);

        sqlConnection.query(`select * from rehapp.findUserResult`, (error, results, fields) => {
            if (error) return done(error, false);

            if (results[0].Success == 0) {
                return done(null, false);
            }
            else {
                return done(null, { 
                    email: results[0].UserEmail,
                    firstname: results[0].FirstName,
                    lastname: results[0].LastName,
                    role: results[0].UserRole 
                });
            }
        });

        sqlConnection.end();
    });
}));

exports.verifyUser = passport.authenticate("jwt", { session: false });

exports.verifyTherapist = (req, res, next) => {
    if (req.user.role == 'therapist') {
        next();
    } else {
        const error = new Error("You are not authorized to perform this operation");
        error.status = 403;
        next(error);
    }
};

exports.verifyPatient = (req, res, next) => {
    if (req.user.role == 'patient') {
        next();
    } else {
        const error = new Error("You are not authorized to perform this operation");
        error.status = 403;
        next(error);
    }
};
