import express from 'express';
import bcrypt from 'bcryptjs';
import validator from 'validator';
import connectDB from '../db/database_service.js';

const registerUserRoute = express.Router();

registerUserRoute.post('/', async (req, res) => {
    const { name, email, phone, password } = req.body;

    // Validate fields
    if (!name || !email || !phone || !password) {
        return res.status(400).json({ msg: "All fields are required" });
    }

    // Validate name
    if (!validator.isAlpha(name.replace(/\s+/g, ''), 'en-US', { ignore: ' ' })) {
        return res.status(400).json({ msg: "Name should contain only letters and spaces" });
    }

    // Validate email
    if (!validator.isEmail(email)) {
        return res.status(400).json({ msg: "Invalid email address" });
    }

    // Validate phone
    if (!validator.isMobilePhone(phone, 'any', { strictMode: false })) {
        return res.status(400).json({ msg: "Invalid phone number" });
    }

    // Validate password
    if (password.length < 6) {
        return res.status(400).json({ msg: "Password must be at least 6 characters long" });
    }

    const conn = connectDB();
    if (!conn) {
        return res.status(500).json({ msg: "Database connection problem" });
    }

    try {
        // Create table if it doesn't exist
        await new Promise((resolve, reject) => {
            conn.query(
                `CREATE TABLE IF NOT EXISTS users (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(50) NOT NULL,
                    email VARCHAR(50) UNIQUE NOT NULL,
                    imageURL VARCHAR(255),
                    phone VARCHAR(15) UNIQUE NOT NULL,
                    password VARCHAR(255) NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );`,
                (err, result) => {
                    if (err) {
                        console.error('Error while creating table:', err);
                        reject(err);
                    } else {
                        resolve(result);
                    }
                }
            );
        });

        // Check if user already exists
        const existingUsers = await new Promise((resolve, reject) => {
            conn.query(
                `SELECT * FROM users WHERE email = ? OR phone = ?`,
                [email, phone],
                (err, results) => {
                    if (err) {
                        console.error('Database query error:', err);
                        reject(err);
                    } else {
                        resolve(results);
                    }
                }
            );
        });

        if (existingUsers.length > 0) {
            return res.status(400).json({ msg: "User already exists with the provided email or phone number" });
        }

        // Hash the password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Insert new user with hashed password
        await new Promise((resolve, reject) => {
            conn.query(
                `INSERT INTO users (name, email, phone, password) VALUES (?, ?, ?, ?)`,
                [name, email, phone, hashedPassword],
                (err, result) => {
                    if (err) {
                        console.error('Error while inserting user:', err);
                        reject(err);
                    } else {
                        resolve(result);
                    }
                }
            );
        });

        // Send success response
        res.status(200).json({
            msg: "User created successfully!",
            data: { name, email, phone }
        });

    } catch (err) {
        console.error('Error while processing request:', err);
        res.status(500).json({ msg: "Error while processing request", error: err });
    } finally {
        conn.end(err => {
            if (err) console.error('Error while closing database connection:', err);
        });
    }
});

export default registerUserRoute;
