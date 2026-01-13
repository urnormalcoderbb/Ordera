# Ordera - Multi-Tenant Restaurant System

A complete restaurant ordering system with multi-tenancy, category-based menu management, and real-time order processing.

[**View Future Roadmap & Checklist**](./ROADMAP.md)

## 🚀 Recent Upgrades
- 🛒 **Cart Management**: Increase/decrease quantity or remove items directly from the cart.
- 📊 **Enhanced Dashboard**: Modern sales reports with date-specific tracking.
- 📜 **Order History**: Click on past orders to see exact items and prices.
- 🏷️ **Naming Rules**: Enforced `Restaurant Name - Area` format for unique branch identification.
- 🛡️ **Hardened Type-Safety**: Robust null-safety to prevent app crashes during data sync.

## Features
- 🏪 **Multi-Tenant**: Support multiple restaurants with isolated data.
- 🗂️ **Category Management**: Organize menu items by categories.
- 📱 **Kiosk Mode**: Customer ordering interface with item thumbnails.
- 🍳 **Kitchen Display (KDS)**: Real-time order updates with full item names.
- 📊 **Manager Dashboard**: Menu management, order history, and daily sales overview.

## Quick Start

### Using Startup Scripts (Recommended)
Double-click `start.bat` in the project root to launch both backend and frontend automatically.

OR run from PowerShell:
```powershell
.\start.ps1
```

## 🪜 Usage Walkthrough
1. **Signup**: Create an account with your **Restaurant Name - Area** (e.g., *Pizza Parade - Downtown*) and City.
2. **Login**: Use your admin credentials.
3. **Manager Dashboard**: 
   - Go to **Manage Menu**.
   - First, create **Categories** (e.g., *Beverages*, *Main Course*).
   - Then, add **Products** with prices and optional images.
4. **Kiosk Mode**: 
   - Customers view categories and add items to the cart.
   - Use **+ / - buttons** in the cart to adjust quantities.
   - Click **PAY NOW** to send the order to the kitchen.
5. **Kitchen Display**: 
   - View incoming orders in real-time.
   - Tap **Mark Ready** when cooking is done.
   - Tap **Complete** to archival the order.
6. **Sales Tracking**: 
   - Check the **Order History** in the Admin panel for itemized receipts.
   - View **Today's Revenue** on the main dashboard.

## Tech Stack
- Backend: Python (Starlette, SQLAlchemy, SQLite)
- Frontend: Flutter (Web/Chrome)
- Real-time: WebSockets
- Auth: Custom JWT + SHA256

## Database Schema
- `Restaurant` (name, city)
- `Category` (name, restaurant_id)
- `User` (username, password_hash, restaurant_id)
- `Product` (name, price, image_url, category_id, restaurant_id)
- `Order` (total_amount, status, payment_status, restaurant_id)
- `OrderItem` (product_id, quantity, modifiers, order_id)
