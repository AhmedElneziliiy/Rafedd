"""
Test MyFatoorah with TEST environment
"""

import http.client
import json

print("=" * 80)
print("TESTING WITH TEST ENVIRONMENT")
print("=" * 80)

# TEST credentials that worked before
api_token = "SK_KWT_vVZlnnAqu8jRByOWaRPNId4ShzEDNt256dvnjebuyzo52dXjAfRx2ixW5umjWSUx"
host = 'apitest.myfatoorah.com'

print(f"\nConfiguration:")
print(f"  Base URL: https://{host}")
print(f"  API Token: {api_token[:15]}...{api_token[-10:]}")
print(f"  Environment: TEST")

# Test InitiatePayment
print("\n" + "=" * 80)
print("Testing InitiatePayment API")
print("=" * 80)

initiate_request = {
    "InvoiceAmount": 50.0,
    "CurrencyIso": "KWD"
}

print(f"\n[REQUEST]")
print(f"API URL: https://{host}/v2/InitiatePayment")
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

response_json = json.loads(response_data)
print(f"Response Body:")
print(json.dumps(response_json, indent=2))

if response.status == 200 and response_json.get('IsSuccess'):
    payment_methods = response_json.get('Data', {}).get('PaymentMethods', [])
    print(f"\n[RESULT]")
    print(f"  Payment Methods Available: {len(payment_methods)}")

    if len(payment_methods) > 0:
        print(f"\n  Payment Methods:")
        for pm in payment_methods:
            print(f"    - {pm.get('PaymentMethodEn')} (ID: {pm.get('PaymentMethodId')})")

        print("\n" + "=" * 80)
        print("[SUCCESS] TEST environment works with " + str(len(payment_methods)) + " payment methods!")
        print("=" * 80)
    else:
        print("\n[FAILED] Even TEST environment has 0 payment methods")
