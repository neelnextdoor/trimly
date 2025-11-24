# Testing Instructions

## Step 1: Restart the Server

The server needs to be restarted to pick up the latest code changes:

```bash
# Stop the current server (if running)
pkill -f "nest start"

# Start the server in development mode
npm run start:dev
```

Wait for the message: `Application is running on: http://localhost:3000`

## Step 2: Test the APIs

### Option A: Use the Manual Test Script (Recommended)

```bash
./test-api-manual.sh
```

This script will guide you through each step interactively.

### Option B: Test Manually with curl

#### 1. Signup (Send OTP)
```bash
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"phone":"+12345678901"}'
```

**Check the server console for the OTP code!**

#### 2. Verify OTP and Create Account
```bash
# Replace 123456 with the OTP from server console
curl -X POST http://localhost:3000/auth/signup/verify \
  -H "Content-Type: application/json" \
  -d '{"phone":"+12345678901","otp":"123456"}'
```

**Save the token from the response!**

#### 3. Complete Profile
```bash
# Replace TOKEN with the token from step 2
curl -X POST http://localhost:3000/auth/signup/complete \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email":"test@example.com",
    "firstName":"Test",
    "lastName":"User",
    "country":"USA",
    "state":"California",
    "city":"San Francisco"
  }'
```

#### 4. Get Profile
```bash
# Replace TOKEN with your token
curl -X GET http://localhost:3000/user/profile \
  -H "Authorization: Bearer TOKEN"
```

#### 5. Update Profile
```bash
# Replace TOKEN with your token
curl -X PUT http://localhost:3000/user/profile \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName":"Updated",
    "lastName":"Name",
    "city":"Los Angeles"
  }'
```

#### 6. Set MPIN
```bash
# Replace USER_ID with your user ID
curl -X POST http://localhost:3000/auth/mpin/set \
  -H "Content-Type: application/json" \
  -d '{
    "userId":"1",
    "mpin":"1234"
  }'
```

#### 7. Login with MPIN
```bash
curl -X POST http://localhost:3000/auth/mpin/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone":"+12345678901",
    "mpin":"1234"
  }'
```

## Step 3: Check Server Logs

If you encounter any errors, check the server console output for detailed error messages.

## Common Issues

1. **500 Internal Server Error**: Restart the server
2. **400 Bad Request**: Check the request body format
3. **401 Unauthorized**: Make sure you're sending a valid JWT token
4. **OTP not received**: Check the server console - OTP is logged there

## Full API Documentation

See `API_TESTING.md` for complete API documentation.

