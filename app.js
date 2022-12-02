const express = require('express')
const mysql = require('mysql');
const dotenv = require('dotenv');
const azureDB = require("./AzureDB");

dotenv.config();
const SERVER_PORT = process.env.SERVER_PORT;

const index = require("./routes/index");
const exerciseRouter = require("./routes/exerciseRouter");
const patientRouter = require("./routes/patientRouter");
const therapistRouter = require("./routes/therapistRouter");
const authRouter = require("./authenticate");

const app = express();

app.use(express.json());

app.use('/', index);
app.use('/ExerciseBank', exerciseRouter);
app.use('/Patient', patientRouter);
app.use('/Therapist', therapistRouter);
app.use('/authenticate', authRouter);

app.use((err, req, res, next) => {
    res.status(500).send(err.message);
});

app.use((req, res, next) => {
    res.status(404).send("Sorry! That route does not exisit. Have a nice day!");
});

app.use((error, req, res, next) => {
    res.status(500).send(error.message);
});

app.listen(SERVER_PORT, () => {
    console.log(`Backend Server is running at http://localhost:${SERVER_PORT}`);
    azureDB.getAzureDatabaseSecret()
        .then(secret => {
            azureDB.config.password = secret.value;

            // connection with Azure database
            const azureSqlCon = mysql.createConnection(azureDB.config);

            azureSqlCon.connect((error) => {
                if (error) {
                    console.log(`Connection error: ${error}`);
                } else {
                    console.log(`Test connection to Azure database: Success`);
                }
            });

            azureSqlCon.end((error) => {
                if (error) {
                    console.log(error);
                } else {
                    console.log('Close test connection to Azure database: Success');
                }
            });
        })
        .catch(err => console.log(err));
});





