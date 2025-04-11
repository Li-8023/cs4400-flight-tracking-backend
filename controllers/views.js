const db = require("../db/db");

// 示例 view1 查询
exports.getView1 = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM view1");
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "读取视图失败" });
  }
};
