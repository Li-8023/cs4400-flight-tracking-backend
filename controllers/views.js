const db = require("../db/db");

//people_on_the_ground
exports.getPeopleOnTheGround = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM people_on_the_ground");
    res.status(200).json({ data: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "Failed to fetch people on the ground",
      details: err.message,
    });
  }
};
