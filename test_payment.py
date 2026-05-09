import http.client
import json

# Login
conn = http.client.HTTPConnection('localhost', 5041)
body = json.dumps({'emailOrPhone': 'manager@rafeed.com', 'password': 'manager123'})
conn.request('POST', '/api/v1/auth/login', body, {'Content-Type': 'application/json'})
resp = conn.getresponse()
data = json.loads(resp.read())
token = data['token']

print("Login: SUCCESS")

# Initiate Payment
conn2 = http.client.HTTPConnection('localhost', 5041)
body2 = json.dumps({
    'subscriptionId': 1,
    'amount': 50.0,
    'currency': 'KWD',
    'paymentMethod': 'myfatoorah',
    'description': 'Test payment'
})
conn2.request('POST', '/api/v1/payment/myfatoorah/initiate', body2, {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
})
resp2 = conn2.getresponse()

if resp2.status == 200:
    data2 = json.loads(resp2.read())
    print("Payment: SUCCESS")
    print(f"  Invoice ID: {data2['data']['invoiceId']}")
    print(f"  Payment URL: {data2['data']['paymentUrl']}")
    print("\n=== ALL TESTS PASSED ===")
    print("READY TO PUBLISH!")
else:
    print(f"Payment Failed: {resp2.status} {resp2.reason}")
    print(resp2.read().decode())
