// routes/reports.js — queues a report generation job into SQS
const express  = require("express");
const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");
const { randomUUID } = require("crypto");

const router = express.Router();
const sqs    = new SQSClient({ region: process.env.AWS_REGION || "us-east-1" });

// POST /api/reports
router.post("/", async (req, res) => {
  const { userEmail, reportType = "monthly" } = req.body;

  if (!userEmail) {
    return res.status(400).json({ error: "userEmail is required" });
  }

  const requestId = randomUUID();

  try {
    await sqs.send(new SendMessageCommand({
      QueueUrl:    process.env.SQS_QUEUE_URL,
      MessageBody: JSON.stringify({ userEmail, reportType, requestId }),
    }));

    res.status(202).json({
      requestId,
      message: "Report queued — you will receive an email when it is ready",
    });
  } catch (err) {
    console.error("SQS send failed:", err);
    res.status(500).json({ error: "Failed to queue report" });
  }
});

module.exports = router;
