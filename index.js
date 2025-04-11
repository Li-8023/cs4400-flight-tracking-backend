const express = require("express");
const cors = require("cors");
const app = express();
const port = 8080;

const procedureRoutes = require("./routes/procedures");

app.use(cors());
app.use(express.json());

app.use("/api/procedures", procedureRoutes);

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
