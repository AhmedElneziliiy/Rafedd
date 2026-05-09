# Rafedd — AI-Powered Team Performance & Goal Management

**Rafedd** is an **ASP.NET Core 8 Web API** platform for Arabic-speaking businesses to manage teams, set goals, track performance, and handle subscriptions — all powered by **Google Gemini AI**.

## What it does

Rafedd helps companies track their workforce performance through AI-generated monthly plans, task assignments, performance reports, and a subscription-based access model with integrated online payments.

## Key Features

- **AI Planning (Gemini)** — Auto-generate weekly/monthly performance plans and analyze team tasks using Google Gemini AI
- **Task Management** — Managers assign tasks to employees; employees submit reports upon completion
- **Performance Reports** — Monthly and annual performance analysis per employee and team
- **Subscription System** — Plans with employee limits; companies must have an active subscription to use the platform
- **Online Payments** — Integrated with **MyFatoorah** payment gateway (supports KWD, USD and more)
- **Role Hierarchy** — Admin → Manager → Employee with scoped permissions
- **Hangfire Background Jobs** — Scheduled background tasks (plan generation, subscription checks)
- **Notifications** — In-app notification system for managers and employees
- **Suggestions** — Employees can submit suggestions to management

## Tech Stack

- ASP.NET Core 8 Web API
- Entity Framework Core + SQL Server
- ASP.NET Identity + JWT Bearer
- Hangfire (background jobs with SQL Server storage)
- Google Gemini AI API
- MyFatoorah Payment Gateway
- Swagger / OpenAPI

## Architecture

The project follows a clean **3-layer architecture**:

```
DAL/    → Data Access Layer (EF Core models, migrations, repositories)
BLL/    → Business Logic Layer (services, AI integration, payment logic)
Shared/ → Shared DTOs, exceptions, common models
Rafedd/ → API Layer (controllers, middleware, Program.cs)
```

## Main Controllers

| Controller | Responsibility |
|---|---|
| `AuthController` | Register, login, forgot/reset password |
| `AdminController` | System admin operations |
| `ManagerController` | Manager dashboard, team management |
| `EmployeeController` | Employee profile, tasks, reports |
| `TasksController` | Create, assign, and track tasks |
| `ReportsController` | Performance reports |
| `SubscriptionController` | Plans, subscriptions, invoices |
| `PaymentController` | MyFatoorah payment initiation & callbacks |
| `NotificationsController` | In-app notifications |

## Getting Started

1. Configure `appsettings.json` with your SQL Server connection string, JWT secret, Gemini API key, and MyFatoorah token
2. Run: `dotnet ef database update`
3. Seed initial data using the provided SQL seed scripts
4. Run and open `/swagger` to explore the full API
