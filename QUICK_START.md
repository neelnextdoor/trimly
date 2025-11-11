# Quick Start Guide - Testing All APIs

## 🚀 Quick Start

### 1. Start the Server
```bash
npm run start:dev
```

### 2. Run the Test Script
```bash
./test-apis.sh
```

The script will guide you through all the API endpoints!

---

## 📋 Manual Testing

### Complete Signup & Login Flow

#### 1. Signup
```bash
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "phone": "+1234567890",
    "name": "John Doe"
  }'
```

**⚠️ Note:** Phone must be a **string** in phone format (with `+` prefix), not a number!

**Save the `userId` from response!**

#### 2. Check Console for OTP
Look at your terminal where `npm run start:dev` is running. You'll see:
```
OTP for john@example.com (+1234567890): 123456
```

#### 3. Verify Signup OTP
```bash
curl -X POST http://localhost:3000/auth/signup/verify \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "YOUR_USER_ID_HERE",
    "otp": "123456"
  }'
```

#### 4. Set MPIN
```bash
curl -X POST http://localhost:3000/auth/mpin/set \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "YOUR_USER_ID_HERE",
    "mpin": "1234"
  }'
```

#### 5. Login with MPIN
```bash
curl -X POST http://localhost:3000/auth/mpin/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "mpin": "1234"
  }'
```

**Save the `token` from response!**

#### 6. Get Profile (Protected Route)
```bash
curl -X GET http://localhost:3000/user/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### 7. Update Profile
```bash
curl -X PUT http://localhost:3000/user/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated"
  }'
```

---

## 🔄 Alternative: OTP Login Flow

#### 1. Request Login OTP
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com"
  }'
```

#### 2. Check Console for OTP

#### 3. Verify Login OTP
```bash
curl -X POST http://localhost:3000/auth/login/verify \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "YOUR_USER_ID_HERE",
    "otp": "123456"
  }'
```

**Save the `token` from response!**

---

## 📝 All Endpoints Summary

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/auth/signup` | Signup and send OTP | No |
| POST | `/auth/signup/verify` | Verify signup OTP | No |
| POST | `/auth/mpin/set` | Set MPIN after signup | No |
| POST | `/auth/login` | Request login OTP | No |
| POST | `/auth/login/verify` | Verify login OTP | No |
| POST | `/auth/mpin/login` | Login with MPIN | No |
| GET | `/user/profile` | Get user profile | Yes |
| PUT | `/user/profile` | Update user profile | Yes |
| GET | `/health` | Health check | No |

---

## 💡 Tips

1. **OTP Display**: OTPs are logged to the console where the server is running
2. **Token Storage**: Save the JWT token after login for protected routes
3. **User ID**: Save the userId after signup for OTP verification
4. **Error Handling**: Check the response for error messages

---

## 🧪 Test with Different Users

Create multiple test users:
```bash
# User 1
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"user1@test.com","phone":"+1111111111","name":"User One"}'

# User 2
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"user2@test.com","phone":"+2222222222","name":"User Two"}'
```

---

For detailed examples, see `API_TESTING_GUIDE.md`

