"""
Direct MyFatoorah API Test
Tests MyFatoorah API directly without going through our API
"""

import http.client
import json

print("=" * 80)
print("DIRECT MYFATOORAH API TEST")
print("=" * 80)

# Read configuration
with open('d:\\Rafedd-master\\Rafedd\\appsettings.json', 'r') as f:
    config = json.load(f)
    myfatoorah_config = config.get('MyFatoorah', {})
    api_token = myfatoorah_config.get('ApiToken')
    base_url = myfatoorah_config.get('BaseUrl')

print(f"\nConfiguration:")
print(f"  Base URL: {base_url}")
print(f"  API Token: {api_token[:15]}...{api_token[-10:]}")

# Determine host and path
if 'apitest' in base_url:
    host = 'apitest.myfatoorah.com'
    environment = 'TEST'
else:
    host = 'api.myfatoorah.com'
    environment = 'PRODUCTION'

print(f"  Environment: {environment}")

# Step 1: Test InitiatePayment
print("\n" + "=" * 80)
print("STEP 1: Testing InitiatePayment API")
print("=" * 80)

initiate_request = {
    "InvoiceAmount": 50.0,
    "CurrencyIso": "KWD"
}

print(f"\n[REQUEST]")
print(f"API URL: https://{host}/v2/InitiatePayment")
print(f"Method: POST")
print(f"Headers:")
print(f"  Authorization: Bearer {api_token[:15]}...")
print(f"  Content-Type: application/json")
print(f"Request Body:")
print(json.dumps(initiate_request, indent=2))

conn = http.client.HTTPSConnection(host)
headers = {
    'Authorization': f'Bearer {api_token}',
    'Content-Type': 'application/json'
}

conn.request('POST', '/v2/InitiatePayment', json.dumps(initiate_request), headers)
response = conn.getresponse()
response_data = response.read().decode('utf-8')

print(f"\n[RESPONSE]")
print(f"Status: {response.status} {response.reason}")
print(f"Response Body:")

try:
    response_json = json.loads(response_data)
    print(json.dumps(response_json, indent=2))

    # Check for payment methods
    if response.status == 200:
        if response_json.get('IsSuccess'):
            payment_methods = response_json.get('Data', {}).get('PaymentMethods', [])
            print(f"\n[RESULT]")
            print(f"  Success: YES")
            print(f"  Payment Methods Available: {len(payment_methods)}")

            if len(payment_methods) > 0:
                print(f"\n  Available Payment Methods:")
                for pm in payment_methods:
                    print(f"    - {pm.get('PaymentMethodEn')} (ID: {pm.get('PaymentMethodId')})")

                # Step 2: Test ExecutePayment with first payment method
                print("\n" + "=" * 80)
                print("STEP 2: Testing ExecutePayment API")
                print("=" * 80)

                first_payment_method = payment_methods[0]
                execute_request = {
                    "PaymentMethodId": first_payment_method.get('PaymentMethodId'),
                    "InvoiceValue": 50.0,
                    "CallBackUrl": "https://example.com/callback",
                    "ErrorUrl": "https://example.com/error",
                    "CustomerName": "Test Customer",
                    "CustomerEmail": "test@example.com",
                    "Language": "en",
                    "DisplayCurrencyIso": "KWD"
                }

                print(f"\n[REQUEST]")
                print(f"API URL: https://{host}/v2/ExecutePayment")
                print(f"Method: POST")
                print(f"Request Body:")
                print(json.dumps(execute_request, indent=2))

                conn2 = http.client.HTTPSConnection(host)
                conn2.request('POST', '/v2/ExecutePayment', json.dumps(execute_request), headers)
                response2 = conn2.getresponse()
                response2_data = response2.read().decode('utf-8')

                print(f"\n[RESPONSE]")
                print(f"Status: {response2.status} {response2.reason}")
                print(f"Response Body:")

                try:
                    response2_json = json.loads(response2_data)
                    print(json.dumps(response2_json, indent=2))

                    if response2.status == 200 and response2_json.get('IsSuccess'):
                        print(f"\n[RESULT]")
                        print(f"  Success: YES")
                        print(f"  Invoice ID: {response2_json.get('Data', {}).get('InvoiceId')}")
                        print(f"  Payment URL: {response2_json.get('Data', {}).get('PaymentURL')}")

                        print("\n" + "=" * 80)
                        print("[OVERALL RESULT: SUCCESS]")
                        print("=" * 80)
                        print("MyFatoorah integration is working correctly!")
                        print("You can now deploy to production.")
                    else:
                        print(f"\n[RESULT]")
                        print(f"  Success: NO")
                        print(f"  Error: ExecutePayment failed")

                except json.JSONDecodeError:
                    print(response2_data)
            else:
                print(f"\n[RESULT]")
                print(f"  Success: NO")
                print(f"  Problem: 0 payment methods available")
                print(f"\n[ACTION REQUIRED]")
                print(f"  You need to enable payment methods in MyFatoorah portal")
                print(f"  Portal URL: https://{'portal-test' if environment == 'TEST' else 'portal'}.myfatoorah.com")
                print(f"  Navigate to: Settings > Payment Methods")
                print(f"  Enable at least one payment method (e.g., KNET, VISA/MASTER)")
        else:
            print(f"\n[RESULT]")
            print(f"  Success: NO")
            print(f"  Error: {response_json.get('Message')}")
    else:
        print(f"\n[RESULT]")
        print(f"  Success: NO")
        print(f"  HTTP Error: {response.status}")

except json.JSONDecodeError:
    print(response_data)

print("\n" + "=" * 80)
print("INFORMATION FOR MYFATOORAH SUPPORT")
print("=" * 80)
print("""
Copy everything above and send to Islam Mohamed at MyFatoorah support.

Specifically include:
1. The API URLs (both InitiatePayment and ExecutePayment if tested)
2. The complete Request Body for each API call
3. The complete Response Body for each API call
4. Your environment (TEST or PRODUCTION)
""")
