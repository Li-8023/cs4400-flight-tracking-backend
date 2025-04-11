const db = require("./db");

async function testConnection() {
  try {
    const [rows] = await db.query("SELECT 1 + 1 AS result");
    console.log("数据库连接成功，测试结果：", rows[0].result); 
  } catch (err) {
    console.error("数据库连接失败：", err.message);
  }
}

testConnection();
