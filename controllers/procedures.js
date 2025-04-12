const db = require("../db/db");

//add_airplane
exports.addAirplane = async (req, res) => {
  try {
    const {
      airlineID,
      tail_num,
      seat_capacity,
      speed,
      locationID,
      plane_type,
      maintenanced,
      model,
      neo,
    } = req.body;

    const [result] = await db.query(
      "CALL add_airplane(?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        airlineID,
        tail_num,
        seat_capacity,
        speed,
        locationID,
        plane_type,
        maintenanced,
        model,
        neo,
      ]
    );

    res.json({ message: "Airplane added successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to add airport",
      details: sqlMessage,
    });
  }
};

//add_airport
exports.addAirport = async (req, res) => {
  try {
    const { airportID, airport_name, city, state, country, locationID } =
      req.body;

    const [result] = await db.query("CALL add_airport(?, ?, ?, ?, ?, ?)", [
      airportID,
      airport_name,
      city,
      state,
      country,
      locationID,
    ]);

    res.json({ message: "Airport added successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to add airport",
      details: sqlMessage,
    });
  }
};

//add_person
exports.addPerson = async (req, res) => {
  try {
    const {
      personID,
      first_name,
      last_name,
      locationID,
      taxID,
      experience,
      miles,
      funds,
    } = req.body;

    const [result] = await db.query("CALL add_person(?, ?, ?, ?, ?, ?, ?, ?)", [
      personID,
      first_name,
      last_name,
      locationID,
      taxID,
      experience,
      miles,
      funds,
    ]);

    res.status(200).json({ message: "Person added successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to add person",
      details: sqlMessage,
    });
  }
};

//grant_or_revoke_pilot_license 
exports.grantOrRevokePilotLicense = async (req, res) => {
  try {
    const { personID, license } = req.body;

    const [result] = await db.query(
      "CALL grant_or_revoke_pilot_license(?, ?)",
      [personID, license]
    );

    res.status(200).json({ message: "License updated successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to update license",
      details: sqlMessage,
    });
  }
};

//offer_flight
exports.offerFlight = async (req, res) => {
  try {
    const {
      flightID,
      routeID,
      support_airline,
      support_tail,
      progress,
      next_time,
      cost,
    } = req.body;

    const [result] = await db.query("CALL offer_flight(?, ?, ?, ?, ?, ?, ?)", [
      flightID,
      routeID,
      support_airline,
      support_tail,
      progress,
      next_time,
      cost,
    ]);

    res.status(200).json({ message: "Flight offered successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to offer flight",
      details: sqlMessage,
    });
  }
};


//retire_flight
exports.retireFlight = async (req, res) => {
  try {
    const { flightID } = req.body;

    const [result] = await db.query("CALL retire_flight(?)", [flightID]);

    res.status(200).json({ message: "Flight retired successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to retire flight",
      details: sqlMessage,
    });
  }
};

//flight_landing
exports.flightLanding = async (req, res) => {
  try {
    const { flightID } = req.body;

    const [result] = await db.query("CALL flight_landing(?)", [flightID]);

    res.status(200).json({ message: "Flight landed successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to land flight",
      details: sqlMessage,
    });
  }
};

//flight_takeoff
exports.flightTakeoff = async (req, res) => {
  try {
    const { flightID } = req.body;

    const [result] = await db.query("CALL flight_takeoff(?)", [flightID]);

    res.status(200).json({ message: "Flight takeoff processed", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to process flight takeoff",
      details: sqlMessage,
    });
  }
};

//passengers_board
exports.passengersBoard = async (req, res) => {
  try {
    const { flightID } = req.body;

    const [result] = await db.query("CALL passengers_board(?)", [flightID]);

    res
      .status(200)
      .json({ message: "Passengers boarded successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to board passengers",
      details: sqlMessage,
    });
  }
};

//passengers_disembark
exports.passengersDisembark = async (req, res) => {
  try {
    const { flightID } = req.body;

    const [result] = await db.query("CALL passengers_disembark(?)", [flightID]);

    res
      .status(200)
      .json({ message: "Passengers disembarked successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to disembark passengers",
      details: sqlMessage,
    });
  }
};

//assign_pilot
exports.assignPilot = async (req, res) => {
  try {
    const { flightID, personID } = req.body;

    const [result] = await db.query("CALL assign_pilot(?, ?)", [
      flightID,
      personID,
    ]);

    res.status(200).json({ message: "Pilot assigned successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to assign pilot",
      details: sqlMessage,
    });
  }
};

exports.recycleCrew = async (req, res) => {
  try {
    const { flightID } = req.body;

    const [result] = await db.query("CALL recycle_crew(?)", [flightID]);

    res.status(200).json({ message: "Crew recycled successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to recycle crew",
      details: sqlMessage,
    });
  }
};

exports.retireFlight = async (req, res) => {
  try {
    const { flightID } = req.body;

    const [result] = await db.query("CALL retire_flight(?)", [flightID]);

    res.status(200).json({ message: "Flight retired successfully", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Failed to retire flight",
      details: sqlMessage,
    });
  }
};

exports.simulationCycle = async (req, res) => {
  try {
    const [result] = await db.query("CALL simulation_cycle()");
    res.status(200).json({ message: "Simulation cycle completed", result });
  } catch (err) {
    const sqlMessage = err.sqlMessage || err.message;
    res.status(400).json({
      error: "Simulation cycle failed",
      details: sqlMessage,
    });
  }
};