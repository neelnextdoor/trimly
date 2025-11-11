#!/bin/bash

# API Testing Script for Barber Authentication
# Make sure the server is running before executing this script

BASE_URL="http://localhost:3000"

echo "=========================================="
echo "  Barber Authentication API Testing"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test Health Endpoint
echo -e "${BLUE}Testing Health Endpoint...${NC}"
HEALTH=$(curl -s $BASE_URL/health)
echo "Response: $HEALTH"
echo ""

# Step 1: Signup
echo -e "${BLUE}Step 1: Signing up new user...${NC}"
SIGNUP_RESPONSE=$(curl -s -X POST $BASE_URL/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.user@example.com",
    "phone": "+1987654321",
    "name": "Test User"
  }')

echo "Response: $SIGNUP_RESPONSE"
echo ""

# Extract User ID
USER_ID=$(echo $SIGNUP_RESPONSE | grep -o '"userId":"[^"]*' | cut -d'"' -f4)

if [ -z "$USER_ID" ]; then
  echo -e "${RED}Error: Could not extract User ID. Check if user already exists.${NC}"
  echo "Trying with different email..."
  
  SIGNUP_RESPONSE=$(curl -s -X POST $BASE_URL/auth/signup \
    -H "Content-Type: application/json" \
    -d "{
      \"email\": \"test$(date +%s)@example.com\",
      \"phone\": \"+1$(date +%s)\",
      \"name\": \"Test User\"
    }")
  
  USER_ID=$(echo $SIGNUP_RESPONSE | grep -o '"userId":"[^"]*' | cut -d'"' -f4)
fi

echo -e "${GREEN}User ID: $USER_ID${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Check your server console for the OTP!${NC}"
echo ""

# Step 2: Verify OTP
echo -e "${BLUE}Step 2: Verifying OTP...${NC}"
echo "Enter the OTP from the server console: "
read OTP

VERIFY_RESPONSE=$(curl -s -X POST $BASE_URL/auth/signup/verify \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"$USER_ID\",
    \"otp\": \"$OTP\"
  }")

echo "Response: $VERIFY_RESPONSE"
echo ""

# Step 3: Set MPIN
echo -e "${BLUE}Step 3: Setting MPIN...${NC}"
MPIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/mpin/set \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"$USER_ID\",
    \"mpin\": \"5678\"
  }")

echo "Response: $MPIN_RESPONSE"
echo ""

# Step 4: Login with MPIN
echo -e "${BLUE}Step 4: Logging in with MPIN...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/mpin/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.user@example.com",
    "mpin": "5678"
  }')

echo "Response: $LOGIN_RESPONSE"
echo ""

# Extract Token
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo -e "${RED}Error: Could not extract token. Login may have failed.${NC}"
  exit 1
fi

echo -e "${GREEN}JWT Token: $TOKEN${NC}"
echo ""

# Step 5: Get Profile (Protected Route)
echo -e "${BLUE}Step 5: Getting user profile (Protected Route)...${NC}"
PROFILE_RESPONSE=$(curl -s -X GET $BASE_URL/user/profile \
  -H "Authorization: Bearer $TOKEN")

echo "Response: $PROFILE_RESPONSE"
echo ""

# Step 6: Update Profile
echo -e "${BLUE}Step 6: Updating user profile...${NC}"
UPDATE_RESPONSE=$(curl -s -X PUT $BASE_URL/user/profile \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Test User"
  }')

echo "Response: $UPDATE_RESPONSE"
echo ""

# Step 7: Test OTP Login Flow
echo -e "${BLUE}Step 7: Testing OTP Login Flow...${NC}"
LOGIN_OTP_RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.user@example.com"
  }')

echo "Response: $LOGIN_OTP_RESPONSE"
echo ""
echo -e "${YELLOW}⚠️  Check console for OTP, then verify with:${NC}"
echo "curl -X POST $BASE_URL/auth/login/verify \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"userId\":\"$USER_ID\",\"otp\":\"<OTP>\"}'"
echo ""

echo -e "${GREEN}=========================================="
echo "  Testing Complete!"
echo "==========================================${NC}"
echo ""
echo "Summary:"
echo "- User ID: $USER_ID"
echo "- JWT Token: ${TOKEN:0:50}..."
echo ""
echo "You can now use the token for protected routes:"
echo "curl -X GET $BASE_URL/user/profile \\"
echo "  -H \"Authorization: Bearer $TOKEN\""

