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
    console.error(err);
    res
      .status(500)
      .json({ error: "Failed to add airplane", details: err.message });
  }
};
