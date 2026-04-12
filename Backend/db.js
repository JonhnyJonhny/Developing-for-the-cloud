// db.js — MySQL2 connection pool using env vars injected by K8s
const mysql = require("mysql2/promise");

const pool = mysql.createPool({
  host:               process.env.DB_HOST,
  port:               parseInt(process.env.DB_PORT || "3306", 10),
  database:           process.env.DB_NAME,
  user:               process.env.DB_USER,
  password:           process.env.DB_PASSWORD,
  waitForConnections: true,
  connectionLimit:    10,
  queueLimit:         0,
  ssl:                { rejectUnauthorized: true }, // enforce TLS to RDS
});

module.exports = pool;
