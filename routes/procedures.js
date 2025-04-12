const express = require("express");
const router = express.Router();
const proceduresController = require("../controllers/procedures");

router.post("/add_airplane", proceduresController.addAirplane);
router.post("/add_airport", proceduresController.addAirport);
router.post("/add_person", proceduresController.addPerson);
router.post("/grant_or_revoke_pilot_license", proceduresController.grantOrRevokePilotLicense);
router.post("/offer_flight", proceduresController.offerFlight);
router.post("/retire_flight", proceduresController.retireFlight);
router.post("/flight_landing", proceduresController.flightLanding);
router.post("/flight_takeoff", proceduresController.flightTakeoff);
router.post("/passengers_board", proceduresController.passengersBoard);
router.post("/passengers_disembark", proceduresController.passengersDisembark);
router.post("/assign_pilot", proceduresController.assignPilot);
router.post("/recycle_crew", proceduresController.recycleCrew);
router.post("/retire_flight", proceduresController.retireFlight);
router.post("/simulation_cycle", proceduresController.simulationCycle);

module.exports = router;
