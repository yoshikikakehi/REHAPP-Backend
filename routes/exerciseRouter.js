const express = require("express");
const mysql = require("mysql");
const azureDB = require("../AzureDB");
const sqlConfig = azureDB.config;
var Exercise = require("../models/Exercise");
const auths = require("../auth_tokens");

const router = express.Router();
router.use(express.json());

router.get("/", auths.verifyUser, auths.verifyTherapist, (req, res, next) => {
    const therapistEmail = req.user.email;
    const sqlConnection = mysql.createConnection(sqlConfig);
    const sqlQuery = `call rehapp.getExerciseBank(${sqlConnection.escape(therapistEmail)})`;

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) next(error); 

        sqlConnection.query('select * from rehapp.getExerciseBankResult', (err, results, _) => {
            if (err) next(err);
            
            if (results[0].Success == 0) {
                res.status(406);
                res.set("Content-Type", "application/json");
                res.json({
                    status: results[0].Reason
                });
            }
            else {
                var exercises = [];
                for (var i = 0; i < results.length; i++) {
                    const result = results[i];
                    var exercise = new Exercise(result.ExID, result.ExName, result.ExDescription, result.ExPicture, result.ExVideo, result.ExTime, result.ExFrequency);
                    exercises[i] = exercise;
                }
                res.status(200);
                res.set("Content-Type", "application/json");
                res.json({
                    status: "Success",
                    exercises: exercises
                });
            }

            sqlConnection.end();
        });
    });
});

module.exports = router;