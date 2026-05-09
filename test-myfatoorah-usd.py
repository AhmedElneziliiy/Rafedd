"""
Test MyFatoorah Production with USD currency
"""

import http.client
import json

print("=" * 80)
print("TESTING PRODUCTION WITH USD CURRENCY")
print("=" * 80)

# Read configuration
with open('d:\\Rafedd-master\\Rafedd\\appsettings.json', 'r') as f:
    config = json.load(f)
    myfatoorah_config = config.get('MyFatoorah', {})
    api_token = myfatoorah_config.get('ApiToken')

host = 'api.myfatoorah.com'

print(f"\nConfiguration:")
print(f"  Base URL: https://{host}")
print(f"  API Token: {api_token[:15]}...{api_token[-10:]}")
print(f"  Environment: PRODUCTION")
print(f"  Currency: USD")

# Test InitiatePayment with USD
print("\n" + "=" * 80)
print("Testing InitiatePayment API with USD")
print("=" * 80)

initiate_request = {
    "InvoiceAmount": 50.0,
    "CurrencyIso": "USD"
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
        print(f"\n  Available Payment Methods:")
        for pm in payment_methods:
            print(f"    - {pm.get('PaymentMethodEn')} (ID: {pm.get('PaymentMethodId')})")

        print("\n" + "=" * 80)
        print(f"[SUCCESS] Production works with USD! {len(payment_methods)} payment methods available!")
        print("=" * 80)
    else:
        print("\n[FAILED] Still 0 payment methods with USD")
else:
    print(f"\n[FAILED] API Error")
