#!/usr/bin/env bash

# Usage: bash tests/test_api.sh

API_HOST="${UVICORN_HOST:-localhost}"
API_PORT="${UVICORN_PORT:-9696}"
API_ENDPOINT="/predict"
API_URL="http://${API_HOST}:${API_PORT}${API_ENDPOINT}"

# Expected labels
SPAM="spam"
HAM="ham"

test_spam_detection() {
  local test_text="$1"
  local expected_label="$2"

  echo "======================================================"
  echo "🧪 Testing spam detection"
  echo "🌐 API URL: $API_URL"
  echo "📝 Input text: $test_text"
  echo "🎯 Expected label: $expected_label"
  echo "======================================================"

    # Encode the input text as JSON
    PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"text": sys.argv[1]}))' "$test_text")

    RESPONSE=$(curl -s -X POST "$API_URL" \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD")

  echo "📤 API Response: $RESPONSE"

  # Check if the output contains expected label
  if [[ $RESPONSE == *"$expected_label"* ]]; then
    echo "✅ Test Passed: Detected '$expected_label'"
    echo ""
    return 0
  else
    echo "❌ Test Failed: Expected '$expected_label' but got different result"
    echo ""
    return 1
  fi
}

test_spam_detection \
  $'Subject: Congratulations! You have been selected for a special offer!\n\nDear user,\n\nYou have been selected to receive a limited-time CASH REWARD of $5,000. Click the secure link below to confirm your account and claim your prize:\n\nhttps://fake-rewards.example.com/claim?id=12345\n\nIf you do not respond within 24 hours, your reward will be forfeited.\n\nBest regards,\nRewards Team' \
  "$SPAM"

test_spam_detection \
  $'Subject: Urgent action required – account suspended\n\nDear customer,\n\nWe detected unusual activity on your account and have temporarily suspended access. To restore full access, please verify your identity by logging in to the secure portal below:\n\nhttp://secure-login.example.com/update-info\n\nFailure to do so within 12 hours may result in permanent closure of your account.\n\nThank you,\nSecurity Team' \
  "$SPAM"

test_spam_detection \
  $'Subject: Standup notes\n\nHey team,\n\nThanks for the great discussion in standup today. I pushed the latest changes to the feature branch and updated the documentation. Let me know if you have any questions.\n\nBest,\nAlex' \
  "$HAM"

test_spam_detection \
  $'Subject: Re: Q4 planning meeting\n\nHi Maria,\n\nThanks for sharing the slides, they look good. I\x27ve added a few comments on the budget section and updated the timeline for the infrastructure migration.\n\nLet\x27s aim to finalize everything before Friday so we can send the deck to the leadership team on Monday.\n\nBest regards,\nDaniel\n\nOn Tue, Maria wrote:\n> Please find attached the first draft of the Q4 planning presentation.' \
  "$HAM"

test_spam_detection \
  $'Subject: FINAL NOTICE: Claim your $$ BONUS now!!!\n\nDear Friend,\n\nThis is your FINAL REMINDER to claim your exclusive BONUS payout. You have been pre-approved for a special financial reward. Reply to this email with your full name, address, and bank details to receive your transfer TODAY!\n\nDo not miss this once-in-a-lifetime opportunity.' \
  "$SPAM"

exit $?