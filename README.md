# Barber Authentication Boilerplate - NestJS

A complete NestJS authentication boilerplate with OTP-based signup/login and MPIN authentication using JWT tokens, following **Screaming Architecture** folder structure with **MySQL** database.

## Features

- ✅ OTP-based signup and login
- ✅ MPIN setup and authentication
- ✅ JWT token generation and validation
- ✅ Protected routes with authentication guards
- ✅ Screaming Architecture folder structure
- ✅ TypeScript with full type safety
- ✅ MySQL with TypeORM
- ✅ Class-validator for DTO validation
- ✅ Passport JWT strategy

## Project Structure (Screaming Architecture)

```
src/
├── auth/                    # Authentication domain
│   ├── auth.controller.ts   # Auth endpoints
│   ├── auth.service.ts      # Auth business logic
│   ├── auth.repository.ts   # Data access layer
│   ├── auth.model.ts        # User entity (TypeORM)
│   ├── auth.types.ts        # Type definitions
│   ├── auth.module.ts       # NestJS module
│   ├── jwt.strategy.ts      # Passport JWT strategy
│   ├── jwt-auth.guard.ts    # JWT authentication guard
│   └── dto/                 # Data Transfer Objects
│       ├── signup.dto.ts
│       ├── verify-signup-otp.dto.ts
│       ├── login.dto.ts
│       ├── verify-login-otp.dto.ts
│       ├── set-mpin.dto.ts
│       └── login-with-mpin.dto.ts
├── user/                    # User domain
│   ├── user.controller.ts   # User endpoints
│   ├── user.service.ts      # User business logic
│   ├── user.repository.ts   # Data access layer
│   ├── user.model.ts        # User model (re-exported from auth)
│   ├── user.types.ts        # Type definitions
│   ├── user.module.ts       # NestJS module
│   └── dto/
│       └── update-profile.dto.ts
├── app.module.ts            # Root module
└── main.ts                  # Application entry point
```

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file:
```bash
PORT=3000
HOST=127.0.0.1
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASS=your_new_password
DB_NAME=intellect
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d
OTP_EXPIRY_MINUTES=10
NODE_ENV=development
```

3. Make sure MySQL is running and create the database:
```sql
CREATE DATABASE intellect;
```

4. Start the development server:
```bash
npm run start:dev
```

**Note:** TypeORM will automatically create the tables on first run (synchronize is enabled in development mode).

## API Endpoints

### Authentication

#### Signup Flow
1. **POST /auth/signup**
   - Send OTP for signup
   - Body: `{ email, phone, name }`
   - Returns: `{ message, userId }`

2. **POST /auth/signup/verify**
   - Verify OTP and complete signup
   - Body: `{ userId, otp }`
   - Returns: `{ message, userId, mpinSet }`

3. **POST /auth/mpin/set**
   - Set MPIN after signup
   - Body: `{ userId, mpin }` (4-digit number)
   - Returns: `{ message }`

#### Login Flow (OTP)
1. **POST /auth/login**
   - Send OTP for login
   - Body: `{ email }` or `{ phone }`
   - Returns: `{ message, userId }`

2. **POST /auth/login/verify**
   - Verify OTP and get JWT token
   - Body: `{ userId, otp }`
   - Returns: `{ message, token, user }`

#### Login Flow (MPIN)
1. **POST /auth/mpin/login**
   - Login with MPIN
   - Body: `{ email/phone, mpin }`
   - Returns: `{ message, token, user }`

### User (Protected Routes)

All user routes require JWT token in Authorization header:
```
Authorization: Bearer <token>
```

1. **GET /user/profile**
   - Get current user profile
   - Returns: `{ id, email, phone, name, mpinSet, isVerified, createdAt, updatedAt }`

2. **PUT /user/profile**
   - Update user profile
   - Body: `{ name? }`
   - Returns: `{ id, email, phone, name, mpinSet, isVerified, createdAt, updatedAt }`

## Usage Examples

### Signup Flow
```bash
# 1. Signup
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","phone":"+1234567890","name":"John Doe"}'

# 2. Verify OTP (check console for OTP)
curl -X POST http://localhost:3000/auth/signup/verify \
  -H "Content-Type: application/json" \
  -d '{"userId":"USER_ID","otp":"123456"}'

# 3. Set MPIN
curl -X POST http://localhost:3000/auth/mpin/set \
  -H "Content-Type: application/json" \
  -d '{"userId":"USER_ID","mpin":"1234"}'
```

### Login with MPIN
```bash
curl -X POST http://localhost:3000/auth/mpin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","mpin":"1234"}'
```

### Access Protected Route
```bash
curl -X GET http://localhost:3000/user/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Environment Variables

- `PORT`: Server port (default: 3000)
- `HOST`: Server host (default: 127.0.0.1)
- `DB_HOST`: MySQL host (default: localhost)
- `DB_PORT`: MySQL port (default: 3306)
- `DB_USER`: MySQL username (default: root)
- `DB_PASS`: MySQL password
- `DB_NAME`: MySQL database name (default: intellect)
- `JWT_SECRET`: Secret key for JWT tokens
- `JWT_EXPIRES_IN`: Token expiration time (default: 7d)
- `OTP_EXPIRY_MINUTES`: OTP validity period (default: 10)
- `NODE_ENV`: Environment (development/production)

## Database Schema

The `users` table is automatically created by TypeORM with the following structure:

- `id` (UUID, Primary Key)
- `email` (VARCHAR(255), Unique, Indexed)
- `phone` (VARCHAR(20), Unique, Indexed)
- `name` (VARCHAR(255))
- `otp` (VARCHAR(6), Nullable)
- `otpExpiry` (DATETIME, Nullable)
- `mpin` (VARCHAR(255), Nullable, Hashed)
- `mpinSet` (BOOLEAN, Default: false)
- `isVerified` (BOOLEAN, Default: false)
- `createdAt` (TIMESTAMP, Auto-generated)
- `updatedAt` (TIMESTAMP, Auto-updated)

## Screaming Architecture Benefits

This project follows **Screaming Architecture** principles:

- **Domain-focused**: Each folder represents a business domain (auth, user)
- **Self-contained**: Each domain has all its related files (controller, service, repository, model, types)
- **Scalable**: Easy to add new domains (e.g., orders, inventory)
- **Maintainable**: Clear separation of concerns within each domain
- **Testable**: Each domain can be tested independently

## Production Considerations

1. **OTP Delivery**: Integrate with actual SMS/Email service:
   - SMS: Twilio, AWS SNS, etc.
   - Email: Nodemailer with SMTP, SendGrid, etc.

2. **Security**:
   - Use strong JWT_SECRET
   - Enable HTTPS
   - Rate limiting for OTP requests
   - Input validation and sanitization
   - Set `synchronize: false` in production (use migrations)

3. **Database**:
   - Use connection pooling
   - Add indexes for frequently queried fields
   - Regular backups
   - Use TypeORM migrations in production

4. **Error Handling**:
   - Implement proper error logging
   - Don't expose sensitive information in errors

## Scripts

- `npm run start:dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm run start:prod` - Start production server
- `npm run lint` - Run ESLint
- `npm run test` - Run unit tests
- `npm run test:e2e` - Run end-to-end tests

## License

ISC

# trimly
Trimly is a sleek, modern barber shop app designed to simplify and enhance the grooming experience for both barbers and customers internationally. It offers easy appointment scheduling, personalized grooming profiles, and seamless online payments.
