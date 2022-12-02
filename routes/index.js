const express = require('express');
const indexRouter = express.Router();

indexRouter.use(express.json());

indexRouter.get("/", (req, res, next) => {
    res.status(200);
    res.set("Content-Type", "application/json");
    res.json("Reapp Web API");
});

module.exports = indexRouter;