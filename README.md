# Ordera - Multi-Tenant Restaurant System

A professional, real-time restaurant ordering system with a shared cloud backend. 

[**View Future Roadmap & Checklist**](./ROADMAP.md)

## 🌎 Synchronization & Cloud Setup
Ordera is now ready to run across multiple devices (Tablets, Phones, Kitchen Displays) using a shared database.

### 🐳 Production Deployment (Docker)
The easiest way to sync all devices is to run the backend in Docker:
1. Ensure **Docker Desktop** is installed.
2. Run: `docker-compose up --build`
3. This launches:
   - **Postgres Database**: Global source of truth.
   - **Redis**: Real-time message broker for instant kitchen sync.
   - **FastAPI/Starlette Backend**: The high-performance API.

### � Connecting Devices
1. In `frontend/lib/config/config.dart`, update `prodHost` to your server's IP or Domain.
2. Apps running on any device will now see the same orders and menu items in real-time.

---

## 🚀 Recent Upgrades
- 🔄 **Global Sync**: Powered by Redis and PostgreSQL for multi-server reliability.
- 🐳 **Dockerization**: One-click deployment for the entire infrastructure.
- ⚡ **Real-time Engine**: Upgraded WebSocket system ensures 100% message delivery.
- 🛡️ **Error Tracking**: Integrated Sentry for pro-active debugging in production.
- 📊 **Enhanced Dashboard**: Real-time sales indicators and order tracking.

## Features
- 🏪 **Multi-Tenant**: Secure data isolation for multiple branches.
- 🗂️ **Category Management**: Deep organization for menu items.
- 📱 **Kiosk Mode**: High-end consumer interface with smooth cart logic.
- 🍳 **Kitchen Display (KDS)**: Real-time ticket management for chefs.
- 📊 **Admin Portal**: Insights, inventory, and order history.

## Quick Start (Development)
Double-click `start.bat` in the project root to launch a local dev environment.

## 🪜 Usage Walkthrough
1. **Signup**: Create your restaurant branch (e.g., *Sizzling Bistro - Soho*).
2. **Setup**: Create your categories and add products with high-quality images.
3. **Operations**: 
   - Customers place orders via the **Kiosk**.
   - Kitchen staff receive instant notifications on the **KDS**.
   - Managers track live revenue on the **Dashboard**.

## Tech Stack
- **Backend**: Python 3.10 (Starlette, SQLAlchemy, PostgreSQL)
- **Infrastructure**: Redis (Pub/Sub), Docker, Docker-Compose
- **Frontend**: Flutter (3.x)
- **Monitoring**: Sentry
- **CI/CD**: GitHub Actions

## Database Schema
- `Restaurant` -> `User` -> `Category` -> `Product` -> `Order` -> `OrderItem`
- Optimized for horizontal scaling and multi-region deployment.
