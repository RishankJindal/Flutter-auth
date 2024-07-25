import mysql2 from 'mysql2';
import 'dotenv/config';

function connectDB() {
    const conn = mysql2.createConnection({
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        user: process.env.DB_USER,
        password: process.env.DB_PASS,
        database: process.env.DB_NAME
    });

    conn.connect((err) => {
        if (err) {
            console.error(`Database connection error: ${err.message}`);
            return;
        }
        console.log('Database connected successfully');
    });

    // Returning the connection object for further use
    return conn;
}

export default connectDB;
