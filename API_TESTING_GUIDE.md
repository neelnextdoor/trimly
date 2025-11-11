# API Testing Guide

Complete guide to test all APIs with dummy examples.

## Prerequisites

1. Make sure the server is running:
   ```bash
   npm run start:dev
   ```

2. Server should be accessible at: `http://localhost:3000`

---

## Complete User Flow Examples

### 1. Signup Flow

#### Step 1: Signup (Send OTP)
```bash
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "name": "John Doe"
  }'
```

**⚠️ Important:** Phone must be a **string** with proper phone format (e.g., `"+1234567890"`), not a number!

**Expected Response:**
```json
{
  "message": "OTP sent successfully",
  "userId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Note:** Check your console/terminal for the OTP (it will be logged there)

#### Step 2: Verify Signup OTP
```bash
curl -X POST http://localhost:3000/auth/signup/verify \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "otp": "123456"
  }'
```

**Expected Response:**
```json
{
  "message": "Signup verified successfully",
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "mpinSet": false
}
```

#### Step 3: Set MPIN
```bash
curl -X POST http://localhost:3000/auth/mpin/set \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "mpin": "1234"
  }'
```

**Expected Response:**
```json
{
  "message": "MPIN set successfully"
}
```

---

### 2. Login Flow (OTP)

#### Step 1: Request Login OTP
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com"
  }'
```

**Or with phone:**
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+1234567890"
  }'
```

**Expected Response:**
```json
{
  "message": "OTP sent successfully",
  "userId": "550e8400-e29b-41d4-a716-446655440000"
}
```

#### Step 2: Verify Login OTP (Get JWT Token)
```bash
curl -X POST http://localhost:3000/auth/login/verify \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "otp": "123456"
  }'
```

**Expected Response:**
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "john.doe@example.com",
    "name": "John Doe",
    "mpinSet": true
  }
}
```

**Save the token** for protected routes!

---

### 3. Login Flow (MPIN)

#### Login with MPIN
```bash
curl -X POST http://localhost:3000/auth/mpin/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "mpin": "1234"
  }'
```

**Or with phone:**
```bash
curl -X POST http://localhost:3000/auth/mpin/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+1234567890",
    "mpin": "1234"
  }'
```

**Expected Response:**
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "john.doe@example.com",
    "name": "John Doe"
  }
}
```

---

### 4. Protected User Routes

**All user routes require JWT token in Authorization header**

#### Get User Profile
```bash
curl -X GET http://localhost:3000/user/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "john.doe@example.com",
  "phone": "+1234567890",
  "name": "John Doe",
  "mpinSet": true,
  "isVerified": true,
  "createdAt": "2025-11-11T01:00:00.000Z",
  "updatedAt": "2025-11-11T01:00:00.000Z"
}
```

#### Update User Profile
```bash
curl -X PUT http://localhost:3000/user/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated Doe"
  }'
```

**Expected Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "john.doe@example.com",
  "phone": "+1234567890",
  "name": "John Updated Doe",
  "mpinSet": true,
  "isVerified": true,
  "createdAt": "2025-11-11T01:00:00.000Z",
  "updatedAt": "2025-11-11T01:05:00.000Z"
}
```

---

## Complete Test Script

Save this as `test-apis.sh` and run it:

```bash
#!/bin/bash

BASE_URL="http://localhost:3000"

echo "=== Testing Signup Flow ==="
echo ""

# Step 1: Signup
echo "1. Signing up..."
SIGNUP_RESPONSE=$(curl -s -X POST $BASE_URL/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.user@example.com",
    "phone": "+1987654321",
    "name": "Test User"
  }')

echo "Signup Response: $SIGNUP_RESPONSE"
USER_ID=$(echo $SIGNUP_RESPONSE | grep -o '"userId":"[^"]*' | cut -d'"' -f4)
echo "User ID: $USER_ID"
echo ""

# Step 2: Verify OTP (You need to check console for actual OTP)
echo "2. Verifying OTP (check console for OTP)..."
echo "Enter OTP from console: "
read OTP

VERIFY_RESPONSE=$(curl -s -X POST $BASE_URL/auth/signup/verify \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"$USER_ID\",
    \"otp\": \"$OTP\"
  }")

echo "Verify Response: $VERIFY_RESPONSE"
echo ""

# Step 3: Set MPIN
echo "3. Setting MPIN..."
MPIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/mpin/set \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"$USER_ID\",
    \"mpin\": \"5678\"
  }")

echo "MPIN Response: $MPIN_RESPONSE"
echo ""

# Step 4: Login with MPIN
echo "4. Logging in with MPIN..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/mpin/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.user@example.com",
    "mpin": "5678"
  }')

echo "Login Response: $LOGIN_RESPONSE"
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "Token: $TOKEN"
echo ""

# Step 5: Get Profile
echo "5. Getting user profile..."
PROFILE_RESPONSE=$(curl -s -X GET $BASE_URL/user/profile \
  -H "Authorization: Bearer $TOKEN")

echo "Profile Response: $PROFILE_RESPONSE"
echo ""

echo "=== Testing Complete ==="
```

---

## Using Postman/Insomnia

### Import Collection

You can import these endpoints into Postman:

**Base URL:** `http://localhost:3000`

**Endpoints:**

1. **POST** `/auth/signup`
   - Body: `{ "email": "user@example.com", "phone": "+1234567890", "name": "User Name" }`

2. **POST** `/auth/signup/verify`
   - Body: `{ "userId": "uuid-here", "otp": "123456" }`

3. **POST** `/auth/mpin/set`
   - Body: `{ "userId": "uuid-here", "mpin": "1234" }`

4. **POST** `/auth/login`
   - Body: `{ "email": "user@example.com" }` or `{ "phone": "+1234567890" }`

5. **POST** `/auth/login/verify`
   - Body: `{ "userId": "uuid-here", "otp": "123456" }`

6. **POST** `/auth/mpin/login`
   - Body: `{ "email": "user@example.com", "mpin": "1234" }`

7. **GET** `/user/profile`
   - Headers: `Authorization: Bearer <token>`

8. **PUT** `/user/profile`
   - Headers: `Authorization: Bearer <token>`
   - Body: `{ "name": "Updated Name" }`

---

## Quick Test Commands

### Test Health Endpoint
```bash
curl http://localhost:3000/health
```

### Complete Flow in One Go (after getting OTP from console)
```bash
# 1. Signup
USER_ID=$(curl -s -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","phone":"+1234567890","name":"Test"}' \
  | grep -o '"userId":"[^"]*' | cut -d'"' -f4)

# 2. Verify (replace 123456 with actual OTP from console)
curl -X POST http://localhost:3000/auth/signup/verify \
  -H "Content-Type: application/json" \
  -d "{\"userId\":\"$USER_ID\",\"otp\":\"123456\"}"

# 3. Set MPIN
curl -X POST http://localhost:3000/auth/mpin/set \
  -H "Content-Type: application/json" \
  -d "{\"userId\":\"$USER_ID\",\"mpin\":\"1234\"}"

# 4. Login with MPIN
TOKEN=$(curl -s -X POST http://localhost:3000/auth/mpin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","mpin":"1234"}' \
  | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# 5. Get Profile
curl -X GET http://localhost:3000/user/profile \
  -H "Authorization: Bearer $TOKEN"
```

---

## Common Errors & Solutions

### 401 Unauthorized
- Make sure you're including the JWT token in the Authorization header
- Token format: `Bearer <token>`

### 400 Bad Request
- Check that all required fields are provided
- Verify email format and phone format
- OTP must be 6 digits
- MPIN must be 4 digits

### 404 Not Found
- Make sure the server is running
- Check the endpoint URL

### 500 Internal Server Error
- Check server logs
- Verify database connection
- Check that MySQL is running

---

## Notes

1. **OTP Display**: OTPs are currently logged to the console. Check your terminal where `npm run start:dev` is running.

2. **Token Expiry**: JWT tokens expire after 7 days (configurable in `.env`).

3. **OTP Expiry**: OTPs expire after 10 minutes (configurable in `.env`).

4. **Database**: Make sure MySQL is running and the `intellect` database exists.

