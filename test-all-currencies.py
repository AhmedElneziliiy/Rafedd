"""
Test MyFatoorah Production with multiple currencies
"""

import http.client
import json

print("=" * 80)
print("TESTING PRODUCTION WITH MULTIPLE CURRENCIES")
print("=" * 80)

# Read configuration
with open('d:\\Rafedd-master\\Rafedd\\appsettings.json', 'r') as f:
    config = json.load(f)
    myfatoorah_config = config.get('MyFatoorah', {})
    api_token = myfatoorah_config.get('ApiToken')

host = 'api.myfatoorah.com'

# Common currencies in the region
currencies_to_test = [
    "KWD",  # Kuwaiti Dinar
    "USD",  # US Dollar
    "SAR",  # Saudi Riyal
    "AED",  # UAE Dirham
    "BHD",  # Bahraini Dinar
    "QAR",  # Qatari Riyal
    "OMR",  # Omani Rial
    "EUR",  # Euro
    "GBP"   # British Pound
]

print(f"\nTesting {len(currencies_to_test)} currencies...\n")

results = []

for currency in currencies_to_test:
    initiate_request = {
        "InvoiceAmount": 50.0,
        "CurrencyIso": currency
    }

    conn = http.client.HTTPSConnection(host)
    headers = {
        'Authorization': f'Bearer {api_token}',
        'Content-Type': 'application/json'
    }

    try:
        conn.request('POST', '/v2/InitiatePayment', json.dumps(initiate_request), headers)
        response = conn.getresponse()
        response_data = response.read().decode('utf-8')
        response_json = json.loads(response_data)

        if response.status == 200 and response_json.get('IsSuccess'):
            payment_methods = response_json.get('Data', {}).get('PaymentMethods', [])
            num_methods = len(payment_methods)

            if num_methods > 0:
                print(f"[OK] {currency}: {num_methods} payment methods available")
                results.append({
                    'currency': currency,
                    'count': num_methods,
                    'methods': [pm.get('PaymentMethodEn') for pm in payment_methods]
                })
            else:
                print(f"[NO] {currency}: 0 payment methods")
        else:
            print(f"[NO] {currency}: API Error - {response_json.get('Message')}")
    except Exception as e:
        print(f"[NO] {currency}: Exception - {str(e)}")

print("\n" + "=" * 80)
print("SUMMARY")
print("=" * 80)

if len(results) > 0:
    print(f"\n[SUCCESS] Found {len(results)} currency/currencies with payment methods enabled!\n")
    for result in results:
        print(f"{result['currency']}: {result['count']} methods")
        for method in result['methods']:
            print(f"  - {method}")
        print()
else:
    print("\n[FAILED] No payment methods available for any currency")
    print("\nThis confirms the account has no payment methods enabled at all.")
    print("You need to contact MyFatoorah support to enable payment methods.")
