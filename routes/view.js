const express = require("express");
const router = express.Router();
const viewController = require("../controllers/views");

// 示例：获取某个视图
router.get("/view1", viewController.getView1);
router.get("/view2", viewController.getView2);
// 加到 view7...

module.exports = router;
