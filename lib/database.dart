import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mysql_client/mysql_client.dart';
import 'package:project/models/user_model.dart';
import 'package:project/utils/api_response.dart';

class DatabaseService {
  Future<MySQLConnection> createConnection() async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: dotenv.env['DB_HOST'] ?? 'localhost',
        port: int.parse(dotenv.env['DB_PORT'] ?? '3306'),
        userName: dotenv.env['DB_USER'] ?? 'root',
        password: dotenv.env['DB_PASS'] ?? '',
        databaseName: dotenv.env['DB_NAME'] ?? '',
      );

      await conn.connect();
      return conn;
    } catch (e) {
      throw ApiResponse(
          statusCode: 500,
          msg: 'Failed to connect to the database. Error: $e',
          data: {});
    }
  }

  Future<ApiResponse> insertUser(User user) async {
    MySQLConnection? conn;
    try {
      conn = await createConnection();

      await conn.execute('USE ${dotenv.env['DB_NAME']}');

      await conn.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        email VARCHAR(50) UNIQUE NOT NULL,
        imageURL VARCHAR(255),
        phone VARCHAR(15) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

      var result = await conn.execute(
        'INSERT INTO users (name, email, phone, password) VALUES (:name, :email, :phone, :password)',
        {
          'name': user.userName,
          'email': user.email,
          'phone': user.phoneNumber,
          'password': user.password,
        },
      );

      print(result.affectedRows.toInt());

      if (result.affectedRows.toInt() > 0) {
        return ApiResponse(
            statusCode: 200, msg: 'User registered successfully!', data: {});
      } else {
        return ApiResponse(
            statusCode: 500,
            msg: 'Failed to insert data. No rows affected.',
            data: {});
      }
    } catch (e) {
      return ApiResponse(
          statusCode: 500, msg: 'An error occurred: $e', data: {});
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<ApiResponse> loginUser(String phone, String password) async {
    MySQLConnection? conn;
    try {
      conn = await createConnection();

      final results = await conn.execute(
        'SELECT * FROM users WHERE phone = :phone',
        {'phone': phone},
      );

      if (results.rows.isEmpty) {
        return ApiResponse(statusCode: 404, msg: "User not found!", data: {});
      }

      final hashedPass = results.rows.first.colAt(5);

      final isPasswordValid = BCrypt.checkpw(password, hashedPass!);

      if (isPasswordValid) {
        Map<String, String?> userData = {
          "name": results.rows.first.colAt(1),
          "email": results.rows.first.colAt(2),
          "phone": results.rows.first.colAt(4),
          "profile_img": results.rows.first.colAt(3)
        };
        return ApiResponse(
            statusCode: 200, msg: "Login successful!", data: userData);
      } else {
        return ApiResponse(statusCode: 401, msg: "Invalid password!", data: {});
      }
    } catch (e) {
      return ApiResponse(
          statusCode: 500,
          msg: "An error occurred while logging in. Error: $e",
          data: {});
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
