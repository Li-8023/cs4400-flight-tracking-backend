const express = require("express");
const router = express.Router();
const proceduresController = require("../controllers/procedures");

router.post("/add_airplane", proceduresController.addAirplane);
router.post("/add_airport", proceduresController.addAirport);
router.post("/add_person", proceduresController.addPerson);
router.post("/grant_or_revoke_pilot_license", proceduresController.grantOrRevokePilotLicense);



module.exports = router;
