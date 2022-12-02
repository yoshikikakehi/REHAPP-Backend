const express = require("express");
const auth_tokens = require("./auth_tokens");
const mysql = require('mysql');
const azureDB = require('./AzureDB');
const sqlconfig = azureDB.config;

const router = express.Router();
router.use(express.json());

router.post("/register", (req, res, next) => {
    const email = req.body.email;
    const password = req.body.password;
    const firstname = req.body.firstname;
    const lastname = req.body.lastname;
    const role = req.body.role;

    const sqlQuery = {
        sql: 'call rehapp.register(?, ?, ?, ?, ?)',
        values: [email, password, firstname, lastname, role]
    };

    const sqlConnection = mysql.createConnection(sqlconfig);

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) next(error);

        const user_token = auth_tokens.getToken({ UserEmail: email });
        res.status(200);
        res.set("Content-Type", "application/json");
        res.json({
            success: true,
            token: user_token,
            status: "Registration succeeds",
            expiresIn: 86400,
            user: {
                email: email,
                firstname: firstname,
                lastname: lastname,
                role: role
            }
        });
    });

    sqlConnection.end();
});

router.post("/login", (req, res, next) => {
    const email = req.body.email;
    const password = req.body.password;

    const sqlQuery = {
        sql: 'call rehapp.login(?, ?)',
        values: [email, password]
    };

    const sqlConnection = mysql.createConnection(sqlconfig);

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) next(error);

        sqlConnection.query('select * from rehapp.loginResult', (error, results, fields) => {
            if (error) next(error);

            if (results[0].Success == 1) {
                res.status = 200;
                res.set("Content-Type", "application/json");
                res.json({
                    success: true,
                    status: "Login succeeds",
                    token: auth_tokens.getToken({ UserEmail: email }),
                    expiresIn: 86400,
                    user: {
                        email: results[0].UserEmail,
                        firstname: results[0].FirstName,
                        lastname: results[0].LastName,
                        role: results[0].UserRole
                    }
                });
            }
            else {
                res.status = 401;
                res.set("Content-Type", "application/json");
                res.json({
                    success: false,
                    status: "Login fails",
                    error: results[0].Reason
                });
            };
        });

        sqlConnection.end();
    });
});

router.get("/logout", (req, res, next) => {
    res.status(200);
    res.json({
        success: true,
        status: "Logout succeeds"
    });
});

module.exports = router;