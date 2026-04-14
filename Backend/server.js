const express = require("express");
const pool    = require("./db");
const client  = require("prom-client");

const app  = express();
const PORT = process.env.PORT || 3000;

client.collectDefaultMetrics();

app.use(express.json());

async function initDB() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS transactions (
        id         INT AUTO_INCREMENT PRIMARY KEY,
        name       VARCHAR(255)    NOT NULL,
        category   VARCHAR(255)    NOT NULL,
        amount     DECIMAL(10,2)   NOT NULL,
        type       VARCHAR(50)     NOT NULL,
        icon       VARCHAR(50)     DEFAULT 'wallet',
        created_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("DB schema ready");
  } catch (err) {
    console.error("DB init failed:", err.message);
  }
}

app.get("/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.status(200).json({ status: "ok", db: "connected" });
  } catch (err) {
    res.status(503).json({ status: "error", db: "unreachable" });
  }
});

app.get("/metrics", async (_req, res) => {
  res.set("Content-Type", client.register.contentType);
  res.end(await client.register.metrics());
});

const transactionRoutes = require("./routes/transactions");
const reportRoutes      = require("./routes/reports");
app.use("/api/transactions", transactionRoutes);
app.use("/api/reports", reportRoutes);

(async () => {
  await initDB();
  app.listen(PORT, () => {
    console.log(`Backend listening on port ${PORT}`);
  });
})();
