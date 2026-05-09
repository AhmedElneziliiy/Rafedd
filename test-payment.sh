#!/bin/bash

echo "Waiting for API..."
sleep 8

echo "Getting auth token..."
TOKEN=$(curl -s -X POST "http://localhost:5041/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"emailOrPhone":"manager@rafeed.com","password":"manager123"}' \
  | python -c "import sys,json; print(json.load(sys.stdin)['token'])")

echo "Token: ${TOKEN:0:50}..."
echo ""
echo "Testing MyFatoorah payment initiation..."
echo ""

curl -s -X POST "http://localhost:5041/api/v1/payment/myfatoorah/initiate" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"subscriptionId":1,"amount":50.0,"currency":"USD","paymentMethod":"myfatoorah","description":"Subscription payment - Beginner Plan"}' \
  | python -m json.tool 2>/dev/null

echo ""
