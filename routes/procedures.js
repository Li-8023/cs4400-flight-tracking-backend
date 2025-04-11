const express = require("express");
const router = express.Router();
const proceduresController = require("../controllers/procedures");

router.post("/add_airplane", proceduresController.addAirplane);

module.exports = router;
