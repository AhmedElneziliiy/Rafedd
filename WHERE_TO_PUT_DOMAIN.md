# 🌐 Where to Put Your Domain When You Publish

## Quick Answer

When you get your production domain (e.g., `https://rafedd.com` or `https://api.rafedd.com`), you need to update it in **ONE place**:

### 📍 Location: `appsettings.json`

**File**: `d:\Rafedd-master\Rafedd\appsettings.json`

**Line to Change**: Line 44

```json
{
  "AppSettings": {
    "BaseUrl": "https://your-actual-domain.com"  // ← CHANGE THIS LINE
  }
}
```

**Change to**:
```json
{
  "AppSettings": {
    "BaseUrl": "https://rafedd.com"  // Your actual domain
  }
}
```

---

## 📋 Complete Step-by-Step Guide

### Step 1: Get Your Domain

When you publish your app, you'll get a domain. It could be:
- **Your own domain**: `https://rafedd.com`
- **Azure domain**: `https://rafedd.azurewebsites.net`
- **VPS server**: `https://217.217.255.74` or `https://api.yourcompany.com`
- **Any hosting service**: `https://yourapp.herokuapp.com`

### Step 2: Open appsettings.json

**Location**: `d:\Rafedd-master\Rafedd\appsettings.json`

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Hangfire": "Information"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=.\\SQLEXPRESS;Database=RafeddSystemDB;Trusted_Connection=true;MultipleActiveResultSets=true;TrustServerCertificate=True"
  },
  "Jwt": {
    "Secret": "c792cb12ebb7bd6599b42f326d504d16a59379aee8e14d932a39e97c20d1e5fb",
    "Issuer": "RafeddAPI",
    "Audience": "Rafedd",
    "ExpireHours": "24"
  },
  "Gemini": {
    "ApiKey": "AIzaSyDWHGeWYyjJOoEsX3vG6y3wHAunpklMGYA",
    "ModelName": "gemini-2.5-flash"
  },
  "Stripe": {
    "PublishableKey": "YOUR_STRIPE_PUBLISHABLE_KEY_HERE",
    "SecretKey": "YOUR_STRIPE_SECRET_KEY_HERE",
    "WebhookSecret": "YOUR_STRIPE_WEBHOOK_SECRET_HERE"
  },
  "MyFatoorah": {
    "ApiToken": "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2",
    "BaseUrl": "https://apitest.myfatoorah.com"
  },
  "PayTabs": {
    "ProfileId": "YOUR_PAYTABS_PROFILE_ID_HERE",
    "ServerKey": "YOUR_PAYTABS_SERVER_KEY_HERE",
    "ClientKey": "YOUR_PAYTABS_CLIENT_KEY_HERE",
    "BaseUrl": "https://secure.paytabs.com"
  },
  "AppSettings": {
    "BaseUrl": "https://your-actual-domain.com"  // ← CHANGE THIS!
  }
}
```

### Step 3: Replace with Your Domain

**Before** (current):
```json
"AppSettings": {
  "BaseUrl": "https://your-actual-domain.com"
}
```

**After** (example with your domain):
```json
"AppSettings": {
  "BaseUrl": "https://rafedd.com"
}
```

**Or if you're using Azure**:
```json
"AppSettings": {
  "BaseUrl": "https://rafedd.azurewebsites.net"
}
```

**Or if you're using your VPS** (from R-LOGIN_DATA.txt):
```json
"AppSettings": {
  "BaseUrl": "https://217.217.255.74"
}
```

### Step 4: Save and Deploy

1. Save the file
2. Deploy/publish your application
3. Done! ✅

---

## 🎯 Why This is Important

The `BaseUrl` is used for:

### 1. **Payment Callbacks** (MyFatoorah)
When a customer completes payment, MyFatoorah needs to notify your server:
- **Callback URL**: `https://rafedd.com/api/v1/payment/myfatoorah/callback`
- **Error URL**: `https://rafedd.com/api/v1/payment/myfatoorah/error`

### 2. **Email Links**
Any emails sent to users will include links to your domain

### 3. **API Documentation**
Swagger/API docs will show your actual domain

### 4. **Frontend Integration**
Your frontend will know where to send API requests

---

## 🔧 Different Environments

You can have different URLs for different environments:

### For Development (Local)
**File**: `appsettings.Development.json`
```json
{
  "AppSettings": {
    "BaseUrl": "http://localhost:5041"
  }
}
```

### For Testing/Staging
**File**: `appsettings.Staging.json`
```json
{
  "AppSettings": {
    "BaseUrl": "https://test.rafedd.com"
  }
}
```

### For Production
**File**: `appsettings.Production.json`
```json
{
  "AppSettings": {
    "BaseUrl": "https://rafedd.com"
  }
}
```

ASP.NET Core automatically loads the right file based on the environment.

---

## 📦 If You're Deploying to Azure

### Using Azure App Service

1. **Don't put the domain in appsettings.json**
2. **Use Application Settings instead** (more secure)

In Azure Portal:
1. Go to your App Service
2. Click **Configuration** → **Application Settings**
3. Add new setting:
   - **Name**: `AppSettings__BaseUrl`
   - **Value**: `https://rafedd.azurewebsites.net`
4. Save

Azure will automatically override the appsettings.json value.

---

## 📦 If You're Deploying to VPS (Your Server)

You have a VPS server from R-LOGIN_DATA.txt:
- **IP**: 217.217.255.74
- **Panel**: https://217.217.255.74:22648/0c4502b0

### Option 1: Use IP Address (Quick)
```json
{
  "AppSettings": {
    "BaseUrl": "https://217.217.255.74"
  }
}
```

### Option 2: Configure Domain (Recommended)

1. **Buy a domain** (e.g., `rafedd.com` from Namecheap, GoDaddy)

2. **Point domain to your server**:
   - Add A Record: `rafedd.com` → `217.217.255.74`
   - Add A Record: `api.rafedd.com` → `217.217.255.74`

3. **Install SSL certificate** (free from Let's Encrypt):
   ```bash
   # On your VPS
   sudo certbot --nginx -d rafedd.com -d api.rafedd.com
   ```

4. **Update appsettings.json**:
   ```json
   {
     "AppSettings": {
       "BaseUrl": "https://rafedd.com"
     }
   }
   ```

---

## 🔒 SSL Certificate (HTTPS)

**Important**: Always use `https://` (not `http://`) in production!

### Why?
- MyFatoorah **requires HTTPS** for callbacks
- Payment data must be secure
- Google penalizes HTTP sites

### How to get SSL?
1. **Free**: Let's Encrypt (certbot)
2. **Paid**: Buy from SSL provider
3. **Automatic**: Azure/AWS handle it for you

---

## 🧪 Testing Callbacks Locally

During development, your local machine (`localhost`) can't receive callbacks from MyFatoorah because it's not publicly accessible.

### Solution: Use ngrok

1. **Install ngrok**:
   - Download from https://ngrok.com/download
   - Extract to a folder

2. **Start your API**:
   ```bash
   cd d:\Rafedd-master\Rafedd
   dotnet run
   ```

3. **Start ngrok** (in another terminal):
   ```bash
   ngrok http 5041
   ```

4. **Copy the ngrok URL**:
   ```
   Forwarding  https://abc123.ngrok.io -> http://localhost:5041
   ```

5. **Update appsettings.json temporarily**:
   ```json
   {
     "AppSettings": {
       "BaseUrl": "https://abc123.ngrok.io"
     }
   }
   ```

6. **Restart API and test payments**

Now MyFatoorah can reach your local machine through the ngrok tunnel!

---

## 📝 Complete Example

### Scenario: Deploying to Azure

**Before deployment**:
```json
{
  "AppSettings": {
    "BaseUrl": "https://your-actual-domain.com"
  }
}
```

**After getting Azure URL**:
```json
{
  "AppSettings": {
    "BaseUrl": "https://rafedd.azurewebsites.net"
  }
}
```

**After configuring custom domain**:
```json
{
  "AppSettings": {
    "BaseUrl": "https://rafedd.com"
  }
}
```

---

## ✅ Checklist When You Publish

- [ ] Get your production domain/URL
- [ ] Open `appsettings.json`
- [ ] Change `AppSettings.BaseUrl` to your domain
- [ ] Make sure it starts with `https://`
- [ ] No trailing slash (e.g., `https://rafedd.com` not `https://rafedd.com/`)
- [ ] Save the file
- [ ] Deploy/publish the application
- [ ] Test a payment to verify callbacks work
- [ ] Check MyFatoorah dashboard to see callback logs

---

## 🆘 Troubleshooting

### Problem: Callbacks not working after deployment

**Check**:
1. Is your domain accessible? Visit `https://yourdomain.com/api/health`
2. Is SSL certificate valid? Check for padlock in browser
3. Did you update `AppSettings.BaseUrl`?
4. Did you restart the API after changing settings?

### Problem: MyFatoorah says "Invalid callback URL"

**Solution**:
1. Make sure URL starts with `https://` (not `http://`)
2. Make sure domain is publicly accessible (not localhost)
3. Check domain spelling

### Problem: Getting 404 on callback

**Check**: Your API is configured to handle the callback route:
- Route should be: `/api/v1/payment/myfatoorah/callback`
- Full URL: `https://yourdomain.com/api/v1/payment/myfatoorah/callback`

---

## 📞 Summary

### The ONE thing you need to do:

**Change this line in `appsettings.json`:**

```json
"BaseUrl": "https://your-actual-domain.com"
```

**To your real domain:**

```json
"BaseUrl": "https://rafedd.com"
```

That's it! Everything else is already configured. 🎉

---

## 🎓 Example Domains

Here are examples of what your domain might look like:

| Hosting | Example Domain |
|---------|----------------|
| **Azure** | https://rafedd.azurewebsites.net |
| **AWS** | https://rafedd.us-east-1.elasticbeanstalk.com |
| **Heroku** | https://rafedd.herokuapp.com |
| **Your VPS** | https://217.217.255.74 or https://api.rafedd.com |
| **Custom Domain** | https://rafedd.com or https://api.rafedd.com |

Pick one and put it in `AppSettings.BaseUrl`! 🚀
