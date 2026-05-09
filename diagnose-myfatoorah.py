import http.client
import json

print("=" * 80)
print("MyFatoorah Payment Integration Diagnostic Tool")
print("=" * 80)
print("\nThis tool will capture the exact API calls for MyFatoorah support.\n")

# Configuration
API_HOST = "localhost"
API_PORT = 5041

# Step 1: Login
print("\n[STEP 1] Logging in...")
print("-" * 80)
conn = http.client.HTTPConnection(API_HOST, API_PORT)
login_body = json.dumps({
    'emailOrPhone': 'manager@rafeed.com',
    'password': 'manager123'
})
conn.request('POST', '/api/v1/auth/login', login_body, {'Content-Type': 'application/json'})
resp = conn.getresponse()
login_response = json.loads(resp.read())
token = login_response.get('token')

if token:
    print("[OK] Login successful")
    print(f"Token: {token[:20]}...")
else:
    print("[FAILED] Login failed")
    print(f"Response: {json.dumps(login_response, indent=2)}")
    exit(1)

# Step 2: Initiate Payment
print("\n[STEP 2] Initiating MyFatoorah Payment...")
print("-" * 80)

conn2 = http.client.HTTPConnection(API_HOST, API_PORT)
payment_request = {
    'subscriptionId': 1,
    'amount': 50.0,
    'currency': 'KWD',
    'paymentMethod': 'myfatoorah',
    'description': 'Diagnostic test payment for MyFatoorah support'
}

print("\n📤 REQUEST TO OUR API:")
print(f"Endpoint: POST http://{API_HOST}:{API_PORT}/api/v1/payment/myfatoorah/initiate")
print(f"Request Body:\n{json.dumps(payment_request, indent=2)}")

conn2.request('POST', '/api/v1/payment/myfatoorah/initiate',
              json.dumps(payment_request),
              {
                  'Authorization': f'Bearer {token}',
                  'Content-Type': 'application/json'
              })

resp2 = conn2.getresponse()
response_text = resp2.read().decode('utf-8')

print(f"\n📥 RESPONSE FROM OUR API:")
print(f"Status: {resp2.status} {resp2.reason}")

try:
    payment_response = json.loads(response_text)
    print(f"Response Body:\n{json.dumps(payment_response, indent=2)}")

    if resp2.status == 200 and payment_response.get('success'):
        print("\n" + "=" * 80)
        print("[SUCCESS] Payment initiated successfully!")
        print("=" * 80)
        data = payment_response.get('data', {})
        print(f"\nInvoice ID: {data.get('invoiceId')}")
        print(f"Payment URL: {data.get('paymentUrl')}")

    else:
        print("\n" + "=" * 80)
        print("[FAILED] PAYMENT INITIATION FAILED")
        print("=" * 80)

except json.JSONDecodeError:
    print(f"Raw Response:\n{response_text}")

# Step 3: Display information for MyFatoorah Support
print("\n" + "=" * 80)
print("INFORMATION FOR MYFATOORAH SUPPORT (Islam Mohamed)")
print("=" * 80)

# Read configuration to show what's being used
print("\n📋 Current Configuration (from appsettings.json):")
try:
    with open('d:\\Rafedd-master\\Rafedd\\appsettings.json', 'r') as f:
        config = json.load(f)
        myfatoorah_config = config.get('MyFatoorah', {})

        api_token = myfatoorah_config.get('ApiToken', 'NOT_CONFIGURED')
        base_url = myfatoorah_config.get('BaseUrl', 'NOT_CONFIGURED')

        # Mask the token for security
        masked_token = api_token[:10] + '...' + api_token[-10:] if len(api_token) > 20 else api_token

        print(f"  Base URL: {base_url}")
        print(f"  API Token: {masked_token}")

        # Determine environment
        if 'apitest' in base_url.lower():
            print(f"  Environment: TEST (Sandbox)")
        else:
            print(f"  Environment: PRODUCTION")

except Exception as e:
    print(f"  Could not read configuration: {e}")

print("\n" + "=" * 80)
print("LOGS TO CHECK FOR MYFATOORAH API CALLS")
print("=" * 80)
print("""
Look in your API server console output for lines containing:

1. "MyFatoorah InitiatePayment Request" - This shows the FIRST API call
2. "MyFatoorah ExecutePayment Request: {Request}" - This shows the SECOND API call

These log entries will show you:
[OK] The API URL you sent the request to
[OK] The complete JSON request you sent to MyFatoorah
[OK] The JSON response returned from MyFatoorah

Share THESE LOG LINES with MyFatoorah support.
""")

print("\n" + "=" * 80)
print("WHAT TO SEND TO MYFATOORAH SUPPORT:")
print("=" * 80)
print("""
Dear Islam Mohamed,

Thank you for your assistance. Here is the requested information:

1. API URLs we are calling:
   - InitiatePayment: {base_url}/v2/InitiatePayment
   - ExecutePayment: {base_url}/v2/ExecutePayment

2. Complete JSON Request (see below from server logs)

3. JSON Response (see below from server logs)

Issue: [DESCRIBE YOUR ISSUE - e.g., "Getting 0 payment methods" or "Payment failing"]

[PASTE THE LOG LINES FROM YOUR API SERVER CONSOLE HERE]

Best regards,
Khaled
""")

print("\n" + "=" * 80)
print("NEXT STEPS:")
print("=" * 80)
print("""
1. Run your API server: cd d:\\Rafedd-master\\Rafedd && dotnet run
2. Look for log lines in the console that contain:
   - "MyFatoorah InitiatePayment Error" OR
   - "MyFatoorah ExecutePayment Request" OR
   - "MyFatoorah API Error"
3. Copy those complete log lines
4. Send them to MyFatoorah support (Islam Mohamed)
""")

print("\n" + "=" * 80)
print("Diagnostic complete!")
print("=" * 80)
