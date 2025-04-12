const express = require("express");
const router = express.Router();
const viewsController = require("../controllers/views");

router.get("/flights_in_the_air", viewsController.getFlightsInTheAir);
router.get("/flights_on_the_ground", viewsController.getFlightsOnTheGround);
router.get("/people_in_the_air", viewsController.getPeopleInTheAir);
router.get("/people_on_the_ground", viewsController.getPeopleOnTheGround);
router.get("/route_summary", viewsController.getRouteSummary);
router.get("/alternative_airports", viewsController.getAlternativeAirports);

module.exports = router;