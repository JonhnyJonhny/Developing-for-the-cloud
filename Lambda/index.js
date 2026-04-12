// Lambda/index.js
// Triggered by SQS. Fetches transactions from RDS,
// generates a CSV report, saves to S3, notifies via SNS.

const mysql = require("mysql2/promise");
const { S3Client, PutObjectCommand, GetObjectCommand } = require("@aws-sdk/client-s3");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const s3  = new S3Client({ region: process.env.AWS_REGION });
const sns = new SNSClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  const results = await Promise.allSettled(
    event.Records.map(record => processRecord(record))
  );

  // Surface any failures so SQS retries the failed messages
  const failures = results.filter(r => r.status === "rejected");
  if (failures.length > 0) {
    failures.forEach(f => console.error("Record failed:", f.reason));
    throw new Error(`${failures.length} record(s) failed — check CloudWatch logs`);
  }
};

async function processRecord(record) {
  const body = JSON.parse(record.body);
  const { userEmail, reportType = "monthly", requestId } = body;

  if (!requestId) throw new Error("Missing requestId in SQS message body");

  console.log(`Processing report: ${requestId} for ${userEmail}`);

  // ── 1. Connect to RDS ──────────────────────────────────
  let db;
  try {
    db = await mysql.createConnection({
      host:     process.env.DB_HOST,
      port:     parseInt(process.env.DB_PORT || "3306"),
      database: process.env.DB_NAME,
      user:     process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      ssl:      { rejectUnauthorized: false },
    });
  } catch (err) {
    throw new Error(`DB connection failed: ${err.message}`);
  }

  // ── 2. Query transactions ──────────────────────────────
  let rows;
  try {
    [rows] = await db.query(
      "SELECT * FROM transactions ORDER BY created_at DESC"
    );
  } finally {
    await db.end().catch(() => {});
  }

  // ── 3. Generate CSV ────────────────────────────────────
  const csv = generateCSV(rows);

  // ── 4. Upload to S3 ────────────────────────────────────
  const key = `reports/${requestId}.csv`;
  try {
    await s3.send(new PutObjectCommand({
      Bucket:      process.env.S3_BUCKET,
      Key:         key,
      Body:        csv,
      ContentType: "text/csv",
    }));
  } catch (err) {
    throw new Error(`S3 upload failed: ${err.message}`);
  }

  // ── 5. Generate a pre-signed download URL (valid 7 days) ──
  const downloadUrl = await getSignedUrl(
    s3,
    new GetObjectCommand({ Bucket: process.env.S3_BUCKET, Key: key }),
    { expiresIn: 604800 }
  );

  // ── 6. Send SNS notification ───────────────────────────
  try {
    await sns.send(new PublishCommand({
      TopicArn: process.env.SNS_TOPIC_ARN,
      Subject:  "Your Budget Tracker Report is Ready",
      Message:  [
        `Hi,`,
        ``,
        `Your ${reportType} budget report is ready.`,
        ``,
        `Download it here (link valid for 7 days):`,
        downloadUrl,
        ``,
        `Summary:`,
        `  Total transactions: ${rows.length}`,
        `  Total income:  $${rows.filter(r => r.amount > 0).reduce((s, r) => s + Number(r.amount), 0).toFixed(2)}`,
        `  Total expenses: $${Math.abs(rows.filter(r => r.amount < 0).reduce((s, r) => s + Number(r.amount), 0)).toFixed(2)}`,
      ].join("\n"),
    }));
  } catch (err) {
    throw new Error(`SNS publish failed: ${err.message}`);
  }

  console.log(`Report ${requestId} complete. Uploaded to s3://${process.env.S3_BUCKET}/${key}`);
}

function generateCSV(rows) {
  const headers = ["id", "name", "category", "amount", "type", "icon", "created_at"];
  const lines   = [
    headers.join(","),
    ...rows.map(r =>
      headers.map(h => JSON.stringify(r[h] ?? "")).join(",")
    ),
  ];
  return lines.join("\n");
}
