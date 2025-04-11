const express = require("express");
const router = express.Router();
const viewsController = require("../controllers/views");

router.get("/people_on_the_ground", viewsController.getPeopleOnTheGround);

module.exports = router;
