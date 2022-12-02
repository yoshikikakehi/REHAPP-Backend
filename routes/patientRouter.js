const express = require("express");
const mysql = require("mysql");
const azureDB = require("../AzureDB");
const sqlConfig = azureDB.config;
const Assignment = require("../models/Assignment");
const auths = require("../auth_tokens");

const router = express.Router();

router.use(express.json());

router.get('/getAssignedExercises', auths.verifyUser, auths.verifyPatient, (req, res, next) => {
    const patientEmail = req.user.email;

    const sqlQuery = `call rehapp.getAssignedExercises(${mysql.escape(patientEmail)})`;

    const sqlConnection = mysql.createConnection(sqlConfig);

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) next(error);

        sqlConnection.query('select * from getAssignedExercisesResult', (error, results, fields) => {
            if (error) next(error);

            if (results.length == 0) {
                res.status(200);
                res.set("Content-Type", "application/json");
                res.json({
                    status: "Success",
                    assignments: []
                });
            }
            else if (results[0].Success == 0) {
                res.status(403);
                res.set("Content-Type", "application/json")
                res.json({
                    status: results[0].Reason
                });
            }
            else {
                var assignments = [];

                for (var i = 0; i < results.length; i++) {
                    const result = results[i];
                    var assignment = new Assignment(
                        result.AssignmentID, 
                        patientEmail, 
                        result.Therapist, 
                        result.ExerciseName, 
                        result.ExerciseDescription, 
                        result.ExercisePicture, 
                        result.ExerciseVideo, 
                        result.ExpectedDuration, 
                        result.ExerciseFrequency, 
                        result.ExerciseStatus,
                        result.ActualDuration,
                        result.ExerciseDifficulty,
                        result.ExerciseComment
                    );
                    assignments[i] = assignment;
                }

                res.status(200);
                res.set("Content-Type", "application/json");
                res.json({
                    status: "Success",
                    assignments: assignments
                });
            }

            sqlConnection.end();
        });
    });
});

router.post('/createExerciseNote', auths.verifyUser, auths.verifyPatient, (req, res, next) => {
    const patient = req.user.email;
    const assignmentID = req.body.AssignmentID;
    const completionTime = req.body.CompletionTime;
    const difficultyLevel = req.body.DifficultyLevel;
    const comment = req.body.Comment;

    const sqlQuery = {
        sql: 'call rehapp.createExerciseNote(?, ?, ?, ?, ?)',
        values: [patient, assignmentID, completionTime, difficultyLevel, comment]
    };

    const sqlConnection = mysql.createConnection(sqlConfig);

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) next(error);

        sqlConnection.query(`select * from rehapp.createExerciseNoteResult`, (error, results, fields) => {
            if (error) next(error);

            var status;
            if (results[0].Success == 0) {
                status = 400;
            }
            else {
                status = 200;
            }

            res.status(status);
            res.set("Content-Type", "application/json");
            res.json({
                status: results[0].Reason
            });

            sqlConnection.end();
        });
    });
});

router.put('/updateExerciseNote', auths.verifyUser, auths.verifyPatient, (req, res, next) => {
    const patient = req.user.email;
    const assignmentID = req.body.AssignmentID;
    const completionTime = req.body.CompletionTime;
    const difficultyLevel = req.body.DifficultyLevel;
    const comment = req.body.Comment;

    const sqlQuery = {
        sql: `call rehapp.updateExerciseNote(?, ?, ?, ?, ?)`,
        values: [patient, assignmentID, completionTime, difficultyLevel, comment]
    };

    const sqlConnection = mysql.createConnection(sqlConfig);

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) next(error);

        sqlConnection.query(`select * from rehapp.updateExerciseNoteResult`, (error, results, fields) => {
            if (error) next(error);

            var status;
            if (results[0].Success == 0) {
                status = 400;
            }
            else {
                status = 200;
            }
            res.status(status);
            res.set("Content-Type", "application/json");
            res.json({
                status: results[0].Reason
            });

            sqlConnection.end();
        });
    });
});

module.exports = router;