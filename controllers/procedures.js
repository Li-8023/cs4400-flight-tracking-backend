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