const express = require("express");
const pool    = require("../db");
const router  = express.Router();

router.get("/", async (_req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT * FROM transactions ORDER BY created_at DESC"
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.post("/", async (req, res) => {
  const { name, category, amount, type, icon } = req.body;
  if (!name || !category || amount === undefined || !type) {
    return res.status(400).json({ error: "Missing required fields" });
  }
  try {
    const [result] = await pool.query(
      "INSERT INTO transactions (name, category, amount, type, icon) VALUES (?, ?, ?, ?, ?)",
      [name, category, amount, type, icon || "wallet"]
    );
    res.status(201).json({ id: result.insertId, name, category, amount, type, icon });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.delete("/:id", async (req, res) => {
  try {
    await pool.query("DELETE FROM transactions WHERE id = ?", [req.params.id]);
    res.status(204).end();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

module.exports = router;
