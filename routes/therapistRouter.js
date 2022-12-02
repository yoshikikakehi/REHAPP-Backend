const express = require("express");
const mysql = require("mysql");
const azureDB = require("../AzureDB");
const mysqlConfig = azureDB.config;
const Patient = require("../models/Patient");
const Assignment = require("../models/Assignment");
const auths = require("../auth_tokens");

const router = express.Router();
router.use(express.json());

router.get("/searchPatient", auths.verifyUser, auths.verifyTherapist, (req, res, next) => {
    const patientEmail = mysql.escape(req.query.PatientEmail);

    const mysqlQuery = `call rehapp.searchPatient(${patientEmail})`;

    const mysqlConnection = mysql.createConnection(mysqlConfig);

    mysqlConnection.query(mysqlQuery, (error, _, __) => {
        if (error) next(error);

        mysqlConnection.query('select * from rehapp.searchPatientResult', (error, results, fields) => {
            if (error) next (error);

            if (results.length == 0) {
                res.status(200);
                res.set("Content-Type", "application/json");
                res.json({
                    status: "Success",
                    patients: []
                });
            }
            else {
                if (results[0].Success == 0) {
                    res.status(403);
                    res.set("Content-Type", "application/json");
                    res.json({
                        status: results[0].Reason 
                    });
                }
                else {
                    var patients = [];

                    for (var i = 0; i < results.length; i++) {
                        const result = results[i];
                        const patient = new Patient(result.PatientEmail, result.PatientFirstName, result.PatientLastName);
                        patients[i] = patient;
                    }

                    res.status(200);
                    res.set("Content-Type", "application/json");
                    res.json({
                        status: "Success",
                        patients: patients
                    });
                }
            }

            mysqlConnection.end();
        })
    })
});

router.put("/addPatient", auths.verifyUser, auths.verifyTherapist, (req, res, next) => {
    const TherapistEmail = mysql.escape(req.user.email);
    const PatientEmail = mysql.escape(req.body.PatientEmail);

    const sqlQuery = `call rehapp.addPatient(${TherapistEmail}, ${PatientEmail})`;
    const sqlConnection = mysql.createConnection(mysqlConfig);

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) next(error);

        sqlConnection.query('select * from rehapp.addPatientResult', (error, results, fields) => {
            if (error) next(error);
            
            var status;
            if (results[0].Success == 0) {
                status = 403;
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

router.delete("/deletePatient", auths.verifyUser, auths.verifyTherapist, (req, res, next) => {
    const patientEmail = mysql.escape(req.body.PatientEmail);

    const mysqlQuery = `call rehapp.deletePatient(${patientEmail})`;

    const mysqlConection = mysql.createConnection(mysqlConfig);

    mysqlConection.query(mysqlQuery, (error, _, __) => {
        if (error) next(error);

        mysqlConection.query('select * from rehapp.deletePatientResult', (error, results, fields) => {
            if (error) next(error);

            var status;
            if (results[0].Success == 0) {
                status = 403;
            }
            else {
                status = 200;
            }

            res.status(status);
            res.set("Content-Type", "application/json");
            res.json({
                status: results[0].Reason
            });

            mysqlConection.end();
        });
    });
});

router.get("/getPatients", auths.verifyUser, auths.verifyTherapist, (req, res, next) => {
    const therapist = mysql.escape(req.user.email);

    const mysqlQuery = `call rehapp.getPatients(${therapist})`;

    const mysqlConection = mysql.createConnection(mysqlConfig);

    mysqlConection.query(mysqlQuery, (error, _, __) => {
        if (error) next(error);

        mysqlConection.query('select * from rehapp.getPatientsResult', (error, results, fields) => {
            if (error) next(error);

            if (results.length == 0) {
                res.status(200);
                res.set("Content-Type", "application/json");
                res.json({
                    status: "Success",
                    patients: []
                });
            }
            else if (results[0].Success == 0) {
                res.status(403);
                res.set("Content-Type", "application/json");
                res.json({
                    status: results[0].Reason
                });
            }
            else {
                var patients = []

                for (var i = 0; i < results.length; i++) {
                    const result = results[i];
                    const patient = new Patient(result.PatientEmail, result.PatientFirstName, result.PatientLastName);
                    patients[i] = patient;
                }

                res.status(200);
                res.set("Content-Type", "application/json");
                res.json({
                    status: "Success",
                    patients: patients
                });
            }

            mysqlConection.end();
        });
    });
});

router.get('/getPatientAssignments', auths.verifyUser, auths.verifyTherapist, (req, res, next) => {
    const TherapistEmail = mysql.escape(req.user.email);
    const PatientEmail = mysql.escape(req.query.PatientEmail);

    const sqlQuery = `call rehapp.getPatientAssignments(${TherapistEmail}, ${PatientEmail})`;
    const sqlConnection = mysql.createConnection(mysqlConfig);

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) next(error);

        sqlConnection.query('select * from rehapp.getPatientAssignmentsResult', (error, results, fields) => {
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
                res.set("Content-Type", "application/json");
                res.json({
                    status: results[0].Reason
                });
            }
            else {
                var patientAssignments = []

                for (var i = 0; i < results.length; i++) {
                    const result = results[i];
                    var assignment = new Assignment(
                        result.AssignmentID, 
                        result.PatientEmail, 
                        result.TherapistEmail, 
                        result.ExerciseName, 
                        result.ExerciseDescription, 
                        result.ExercisePicture, 
                        result.ExerciseVideo, 
                        result.ExpectedTime, 
                        result.ExerciseFrequency,
                        result.ExerciseStatus,
                        result.ReportedDuration,
                        result.ReportedDifficulty,
                        result.PatientComment
                    );
                    patientAssignments[i] = assignment;
                }

                res.status(200);
                res.set("Content-Type", "application/json");
                res.json({
                    status: "Success",
                    assignments: patientAssignments
                });
            }

            sqlConnection.end();
        });
    });
});

router.post("/createPatientAssignment", auths.verifyUser, auths.verifyTherapist, (req, res, next) => {
    const TherapistEmail = req.user.email;
    const PatientEmail = req.body.PatientEmail;
    const ExerciseID = req.body.ExerciseID;
    const ExerciseName = req.body.ExerciseName;
    const ExerciseDescription = req.body.ExerciseDescription;
    const ExercisePicture = req.body.ExercisePicture;
    const ExerciseVideo = req.body.ExerciseVideo;
    const ExpectedDuration = req.body.ExpectedDuration;
    const ExerciseFrequency = req.body.ExerciseFrequency;

    const sqlQuery = {
        sql: `call rehapp.createPatientAssignment(?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        values: [TherapistEmail, PatientEmail, ExerciseID, ExerciseName, ExerciseDescription, ExercisePicture, ExerciseVideo, ExpectedDuration, ExerciseFrequency]
    };
    const sqlConnection = mysql.createConnection(mysqlConfig);

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) next(error);

        sqlConnection.query('select * from rehapp.createPatientAssignmentResult', (error, results, fields) => {
            if (error) next(error);

            var status;
            if (results[0].Success == 0) {
                status = 403;
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

router.put("/modifyPatientAssignment", auths.verifyUser, auths.verifyTherapist, (req, res, next) => {
    const AssignmentID = req.body.AssignmentID;
    const TherapistEmail = req.user.email;
    const PatientEmail = req.body.PatientEmail;
    const ExerciseName = req.body.ExerciseName;
    const ExerciseDescription = req.body.ExerciseDescription;
    const ExerciseVideo = req.body.ExerciseVideo;
    const ExpectedDuration = req.body.ExpectedDuration;
    const ExerciseFrequency = req.body.ExerciseFrequency;

    const sqlQuery = {
        sql: `call rehapp.modifyPatientAssignment(?, ?, ?, ?, ?, ?, ?, ?)`,
        values: [AssignmentID, TherapistEmail, PatientEmail, ExerciseName, ExerciseDescription, ExerciseVideo, ExpectedDuration, ExerciseFrequency]
    };
    const sqlConnection = mysql.createConnection(mysqlConfig);

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) next(error);

        sqlConnection.query('select * from rehapp.modifyPatientAssignmentResult', (error, results, fields) => {
            if (error) next(error);

            var status;
            if (results[0].Success == 0) {
                status = 403;
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

router.delete("/deletePatientAssignment", auths.verifyUser, auths.verifyTherapist, (req, res, next) => {
    const therapistEmail = req.user.email;
    const assignmentID = req.body.AssignmentID;

    const sqlQuery = {
        sql: `call rehapp.deletePatientAssignment(?, ?)`,
        values: [therapistEmail, assignmentID]
    };

    const sqlConnection = mysql.createConnection(mysqlConfig);

    sqlConnection.query(sqlQuery, (error, _, __) => {
        if (error) next(error);

        sqlConnection.query('select * from rehapp.deletePatientAssignmentResult', (error, results, fields) => {
            if (error) next(error);

            var status;
            if (results[0].Success == 0) {
                status = 403;
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