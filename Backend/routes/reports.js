// routes/reports.js — generates a CSV report and streams it as a download
const express = require("express");
const pool    = require("../db");

const router = express.Router();

// GET /api/reports/download
router.get("/download", async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT id, name, category, amount, type, icon, created_at FROM transactions ORDER BY created_at DESC"
    );

    const headers = ["id", "name", "category", "amount", "type", "icon", "created_at"];
    const csv = [
      headers.join(","),
      ...rows.map(r =>
        headers.map(h => JSON.stringify(r[h] ?? "")).join(",")
      ),
    ].join("\n");

    const filename = `budget-report-${new Date().toISOString().slice(0, 10)}.csv`;

    res.setHeader("Content-Type", "text/csv");
    res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);
    res.status(200).send(csv);
  } catch (err) {
    console.error("Report generation failed:", err);
    res.status(500).json({ error: "Failed to generate report" });
  }
});

module.exports = router;
