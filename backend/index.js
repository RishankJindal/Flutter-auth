import express, { urlencoded } from 'express';
import 'dotenv/config';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import registerUserRoute from './routes/register_route.js';
import loginRoute from './routes/login_route.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(express.json());
app.use(cors({ origin: process.env.CORS }));
app.use(urlencoded({ extended: true }));
app.use(cookieParser());

// Routes
app.use('/api/v1/user/register', registerUserRoute);
app.use('/api/v1/user/login', loginRoute);

app.listen(PORT, () => {
    console.log(`Server is listening on port: ${PORT}`);
})