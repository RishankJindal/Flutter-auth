import express from 'express';
import bcrypt from 'bcryptjs';
import validator from 'validator';
import connectDB from '../db/database_service.js';

const loginRoute = express.Router();

loginRoute.post('/', async (req, res) => {
    const { phone, password } = req.body;

    // Validate fields
    if (!phone) {
        return res.status(400).json({ statusCode: 400, msg: "Phone number is required" });
    }
    if (!password) {
        return res.status(400).json({ statusCode: 400, msg: "Password is required" });
    }

    // Validate phone number
    if (!validator.isMobilePhone(phone, 'any', { strictMode: false })) {
        return res.status(400).json({ statusCode: 400, msg: "Invalid phone number" });
    }

    // Connection with database
    const conn = connectDB();
    if (!conn) {
        return res.status(500).json({ statusCode: 500, msg: "Database connection problem" });
    }

    try {
        // Find user by phone number
        const results = await new Promise((resolve, reject) => {
            const query = `SELECT * FROM users WHERE phone = ?`;
            conn.query(query, [phone], (err, results) => {
                if (err) {
                    console.error('Database query error:', err); // Log detailed error
                    reject(err);
                } else {
                    resolve(results);
                }
            });
        });

        console.log(results);

        // Ensure results is an array and has at least one user
        if (results.length === 0) {
            return res.status(400).json({ statusCode: 400, msg: "User not found" });
        }

        // Access the first user from the results
        const user = results[0];
        if (!user || !user["password"]) {
            return res.status(400).json({ statusCode: 400, msg: "User data is corrupted" });
        }

        // Compare provided password with hashed password in the database
        const isMatch = await bcrypt.compare(password, user["password"]);

        if (!isMatch) {
            return res.status(400).json({ statusCode: 400, msg: "Invalid password" });
        }

        // Send success response
        res.status(200).json({
            statusCode: 200,
            msg: "Login successful",
            data: {
                name: user.name,
                email: user.email,
                phone: user.phone
            }
        });

    } catch (err) {
        // Handle errors
        console.error('Error while processing request:', err); // Log detailed error
        res.status(500).json({ statusCode: 500, msg: "Error while processing request", data: err });
    } finally {
        // Close connection
        conn.end((err) => {
            if (err) console.error('Error while closing database connection:', err);
        });
    }
});

export default loginRoute;
