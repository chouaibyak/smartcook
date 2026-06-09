const path = require('path');
const mysql = require('mysql2');

require('dotenv').config({
    path: path.join(__dirname, '..', '.env'),
    quiet: true
});

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: Number(process.env.DB_PORT) || 3306,
    waitForConnections: true,
    connectionLimit: 10
});

module.exports = pool.promise();
