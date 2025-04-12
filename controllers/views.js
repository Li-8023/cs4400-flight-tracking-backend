const db = require("../db/db");

exports.getFlightsInTheAir = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM flights_in_the_air");
    res.status(200).json({ data: rows });
  } catch (err) {
    res
      .status(500)
      .json({
        error: "Failed to fetch flights_in_the_air",
        details: err.message,
      });
  }
};

exports.getFlightsOnTheGround = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM flights_on_the_ground");
    res.status(200).json({ data: rows });
  } catch (err) {
    res
      .status(500)
      .json({
        error: "Failed to fetch flights_on_the_ground",
        details: err.message,
      });
  }
};

exports.getPeopleInTheAir = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM people_in_the_air");
    res.status(200).json({ data: rows });
  } catch (err) {
    res
      .status(500)
      .json({
        error: "Failed to fetch people_in_the_air",
        details: err.message,
      });
  }
};

exports.getPeopleOnTheGround = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM people_on_the_ground");
    res.status(200).json({ data: rows });
  } catch (err) {
    res
      .status(500)
      .json({
        error: "Failed to fetch people_on_the_ground",
        details: err.message,
      });
  }
};

exports.getRouteSummary = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM route_summary");
    res.status(200).json({ data: rows });
  } catch (err) {
    res
      .status(500)
      .json({ error: "Failed to fetch route_summary", details: err.message });
  }
};

exports.getAlternativeAirports = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM alternative_airports");
    res.status(200).json({ data: rows });
  } catch (err) {
    res
      .status(500)
      .json({
        error: "Failed to fetch alternative_airports",
        details: err.message,
      });
  }
};
