// server.js — Express entry point
const express = require("express");
const pool    = require("./db");

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Auto-create tables on startup
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

// Health-check used by the HEALTHCHECK in Dockerfile.backend
app.get("/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.status(200).json({ status: "ok", db: "connected" });
  } catch (err) {
    res.status(503).json({ status: "error", db: "unreachable" });
  }
});

// Import and mount route modules
const transactionRoutes = require("./routes/transactions");
const reportRoutes      = require("./routes/reports");
app.use("/api/transactions", transactionRoutes);
app.use("/api/reports", reportRoutes);

app.listen(PORT, async () => {
  await initDB();
  console.log(`Backend listening on port ${PORT}`);
});
