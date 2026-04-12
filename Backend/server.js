// server.js — Express entry point
const express = require("express");
const pool    = require("./db");

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

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
app.use("/api/transactions", transactionRoutes);

app.listen(PORT, () => {
  console.log(`Backend listening on port ${PORT}`);
});
