from starlette.requests import Request
from starlette.responses import JSONResponse
import database, models, auth, ws_manager
from sqlalchemy import func
import json

# Utility to get current user with context
def get_current_user_obj(request: Request):
    token = auth.get_current_user_token(request)
    if not token:
        return None
    # We need to manually verify locally since using same DB session
    # In endpoints we create new sessions, so we might need to decode token here 
    # and fetch user in the endpoint's session.
    # For optimization, we can just decode token and trust the ID/RestaurantID if we put it there.
    # Let's decode token.
    try:
        payload = auth.jwt.decode(token, auth.SECRET_KEY, algorithms=[auth.ALGORITHM])
        return payload # Returns dict typically
    except:
        return None

async def signup(request: Request):
    try:
        body = await request.json()
    except:
        return JSONResponse({"error": "Invalid JSON"}, status_code=400)
        
    restaurant_name = body.get("restaurant_name")
    city = body.get("city")
    username = body.get("username")
    password = body.get("password")
    
    # Enforce case-insensitive uniqueness logic
    # 1. Restaurant Name + City must be unique globally
    if not restaurant_name or not city or not username:
        return JSONResponse({"error": "Missing fields"}, status_code=400)

    restaurant_name = restaurant_name.strip()
    city = city.strip()
    username = username.strip()

    if " - " not in restaurant_name:
        return JSONResponse({"error": "Restaurant name must be in format: Name - Area"}, status_code=400)

    with database.get_db_context() as db:
        # Check if Restaurant Name + City exists (Case Insensitive)
        if db.query(models.Restaurant).filter(
            func.lower(models.Restaurant.name) == restaurant_name.lower(),
            func.lower(models.Restaurant.city) == city.lower()
        ).first():
             return JSONResponse({"error": "Restaurant Name in this City already taken"}, status_code=400)

        # Create Restaurant
        restaurant = models.Restaurant(name=restaurant_name, city=city)
        db.add(restaurant)
        db.commit()
        db.refresh(restaurant)
        
        # Create Admin User
        hashed_password = auth.get_password_hash(password)
        user = models.User(
            username=username, 
            hashed_password=hashed_password, 
            role="admin",
            restaurant_id=restaurant.id
        )
        db.add(user)
        db.commit()
        
        return JSONResponse({"message": "Signup successful", "restaurant_id": restaurant.id})

async def login(request: Request):
    try:
        try:
            body = await request.json()
        except:
            return JSONResponse({"error": "Invalid JSON"}, status_code=400)
            
        username = body.get("username")
        restaurant_name = body.get("restaurant_name")
        city = body.get("city")
        password = body.get("password")

        if not username or not restaurant_name or not city:
             return JSONResponse({"error": "Missing username, restaurant name, or city"}, status_code=400)

        username = username.strip()
        restaurant_name = restaurant_name.strip()
        city = city.strip()
        
        print(f"Login attempt for: {username} at {restaurant_name} ({city})")
        
        with database.get_db_context() as db:
            # 1. Find Restaurant (Case Sensitive Name, Case Insensitive City)
            restaurant = db.query(models.Restaurant).filter(
                models.Restaurant.name == restaurant_name,
                func.lower(models.Restaurant.city) == city.lower()
            ).first()
            
            if not restaurant:
                print(f"Restaurant '{restaurant_name}' in '{city}' not found")
                return JSONResponse({"error": "Restaurant not found"}, status_code=404)

            # 2. Find User in that Restaurant
            user = db.query(models.User).filter(
                models.User.username == username, 
                models.User.restaurant_id == restaurant.id
            ).first()

            if not user:
                print("User not found in this restaurant")
                return JSONResponse({"error": "Invalid credentials"}, status_code=401)
            
            print(f"User found: {user.username}, verifying password...")
            if not auth.verify_password(password, user.hashed_password):
                print("Password verification failed")
                return JSONResponse({"error": "Invalid credentials"}, status_code=401)
            
            print("Password verified, creating token...")
            # Include restaurant_id in token for easy filtering
            access_token = auth.create_access_token(data={
                "sub": user.username, 
                "role": user.role,
                "restaurant_id": user.restaurant_id
            })
            return JSONResponse({
                "access_token": access_token, 
                "token_type": "bearer",
                "restaurant_id": user.restaurant_id,
                "restaurant_name": user.restaurant.name,
                "restaurant_city": user.restaurant.city
            })
    except Exception as e:
        import traceback
        traceback.print_exc()
        return JSONResponse({"error": f"Internal Login Error: {str(e)}"}, status_code=500)

async def verify_password(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    try:
        body = await request.json()
        password = body.get("password")
        if not password:
            return JSONResponse({"authenticated": False, "error": "Password required"}, status_code=400)
        
        username = user_payload.get("sub")
        restaurant_id = user_payload.get("restaurant_id")
        
        with database.get_db_context() as db:
            user = db.query(models.User).filter(
                models.User.username == username,
                models.User.restaurant_id == restaurant_id
            ).first()
            
            if not user:
                return JSONResponse({"authenticated": False, "error": "User not found"}, status_code=404)
            
            is_valid = auth.verify_password(password, user.hashed_password)
            return JSONResponse({"authenticated": is_valid})
    except Exception as e:
        return JSONResponse({"authenticated": False, "error": str(e)}, status_code=500)

async def create_category(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    restaurant_id = user_payload.get("restaurant_id")
    
    try:
        body = await request.json()
    except:
        return JSONResponse({"error": "Invalid JSON"}, status_code=400)
    
    name = body.get("name")
    if not name:
        return JSONResponse({"error": "Category name required"}, status_code=400)
    
    with database.get_db_context() as db:
        # Check if category with same name exists in this restaurant
        existing = db.query(models.Category).filter(
            models.Category.restaurant_id == restaurant_id,
            func.lower(models.Category.name) == name.lower()
        ).first()
        
        if existing:
            return JSONResponse({"error": "Category already exists"}, status_code=400)
        
        category = models.Category(name=name.strip(), restaurant_id=restaurant_id)
        db.add(category)
        db.commit()
        db.refresh(category)
        
        return JSONResponse({
            "id": category.id,
            "name": category.name,
            "restaurant_id": category.restaurant_id
        })

async def update_category(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    restaurant_id = user_payload.get("restaurant_id")
    category_id = request.path_params['category_id']
    
    try:
        body = await request.json()
    except:
        return JSONResponse({"error": "Invalid JSON"}, status_code=400)
    
    name = body.get("name")
    if not name:
        return JSONResponse({"error": "Category name required"}, status_code=400)
    
    with database.get_db_context() as db:
        category = db.query(models.Category).filter(
            models.Category.id == category_id,
            models.Category.restaurant_id == restaurant_id
        ).first()
        
        if not category:
            return JSONResponse({"error": "Category not found"}, status_code=404)
        
        category.name = name.strip()
        db.commit()
        db.refresh(category)
        
        return JSONResponse({
            "id": category.id,
            "name": category.name,
            "restaurant_id": category.restaurant_id
        })

async def list_categories(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    restaurant_id = user_payload.get("restaurant_id")
    
    with database.get_db_context() as db:
        categories = db.query(models.Category).filter(models.Category.restaurant_id == restaurant_id).all()
        data = []
        for c in categories:
            data.append({
                "id": c.id,
                "name": c.name,
                "restaurant_id": c.restaurant_id
            })
        return JSONResponse(data)

async def delete_category(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    restaurant_id = user_payload.get("restaurant_id")
    category_id = request.path_params['category_id']
    
    with database.get_db_context() as db:
        category = db.query(models.Category).filter(
            models.Category.id == category_id,
            models.Category.restaurant_id == restaurant_id
        ).first()
        
        if not category:
            return JSONResponse({"error": "Category not found"}, status_code=404)
        
        # Check if there are products in this category
        products_count = db.query(models.Product).filter(models.Product.category_id == category_id).count()
        if products_count > 0:
            return JSONResponse({"error": f"Cannot delete category with {products_count} products"}, status_code=400)
        
        db.delete(category)
        db.commit()
        return JSONResponse({"status": "success"})

async def list_products(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
        
    restaurant_id = user_payload.get("restaurant_id")
    
    with database.get_db_context() as db:
        products = db.query(models.Product).filter(models.Product.restaurant_id == restaurant_id).all()
        data = []
        for p in products:
            data.append({
                "id": p.id,
                "name": p.name,
                "price": p.price,
                "description": p.description,
                "category_id": p.category_id,
                "category_name": p.category.name if p.category else None,
                "image_url": p.image_url,
                "is_available": p.is_available,
                "modifiers": p.modifiers
            })
        return JSONResponse(data)

async def create_product(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    restaurant_id = user_payload.get("restaurant_id")
    
    try:
        body = await request.json()
    except:
        return JSONResponse({"error": "Invalid JSON"}, status_code=400)
    
    name = body.get("name")
    price = body.get("price")
    category_id = body.get("category_id")
    
    if not name or price is None or not category_id:
        return JSONResponse({"error": "Name, price, and category_id required"}, status_code=400)
    
    with database.get_db_context() as db:
        # Verify category belongs to this restaurant
        category = db.query(models.Category).filter(
            models.Category.id == category_id,
            models.Category.restaurant_id == restaurant_id
        ).first()
        
        if not category:
            return JSONResponse({"error": "Category not found"}, status_code=404)
        
        product = models.Product(
            name=name.strip(),
            price=float(price),
            description=body.get("description", ""),
            image_url=body.get("image_url", ""),
            category_id=category_id,
            is_available=body.get("is_available", True),
            modifiers=body.get("modifiers", {}),
            restaurant_id=restaurant_id
        )
        db.add(product)
        db.commit()
        db.refresh(product)
        
        return JSONResponse({
            "id": product.id,
            "name": product.name,
            "price": product.price,
            "description": product.description,
            "category_id": product.category_id,
            "category_name": category.name,
            "image_url": product.image_url,
            "is_available": product.is_available,
            "modifiers": product.modifiers
        })

async def update_product(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    restaurant_id = user_payload.get("restaurant_id")
    product_id = request.path_params['product_id']
    
    try:
        body = await request.json()
    except:
        return JSONResponse({"error": "Invalid JSON"}, status_code=400)
    
    with database.get_db_context() as db:
        product = db.query(models.Product).filter(
            models.Product.id == product_id,
            models.Product.restaurant_id == restaurant_id
        ).first()
        
        if not product:
            return JSONResponse({"error": "Product not found"}, status_code=404)
        
        if "name" in body: product.name = body["name"].strip()
        if "price" in body: product.price = float(body["price"])
        if "description" in body: product.description = body["description"]
        if "image_url" in body: product.image_url = body["image_url"]
        if "category_id" in body: product.category_id = body["category_id"]
        if "is_available" in body: product.is_available = body["is_available"]
        if "modifiers" in body: product.modifiers = body["modifiers"]
        
        db.commit()
        db.refresh(product)
        
        return JSONResponse({
            "id": product.id,
            "name": product.name,
            "price": product.price,
            "description": product.description,
            "category_id": product.category_id,
            "image_url": product.image_url,
            "is_available": product.is_available,
            "modifiers": product.modifiers
        })

async def delete_product(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    restaurant_id = user_payload.get("restaurant_id")
    product_id = request.path_params['product_id']
    
    with database.get_db_context() as db:
        product = db.query(models.Product).filter(
            models.Product.id == product_id,
            models.Product.restaurant_id == restaurant_id
        ).first()
        
        if not product:
            return JSONResponse({"error": "Product not found"}, status_code=404)
        
        db.delete(product)
        db.commit()
        return JSONResponse({"status": "success"})

import os
import uuid

async def upload_image(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    # Get the uploads directory
    uploads_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
    os.makedirs(uploads_dir, exist_ok=True)
    
    try:
        form = await request.form()
        file = form.get("file")
        
        if not file:
            return JSONResponse({"error": "No file provided"}, status_code=400)
        
        # Generate unique filename
        ext = os.path.splitext(file.filename)[1] if file.filename else ".jpg"
        filename = f"{uuid.uuid4().hex}{ext}"
        filepath = os.path.join(uploads_dir, filename)
        
        # Save file
        contents = await file.read()
        with open(filepath, "wb") as f:
            f.write(contents)
        
        # Return the URL path
        image_url = f"/uploads/{filename}"
        return JSONResponse({"image_url": image_url})
        
    except Exception as e:
        return JSONResponse({"error": f"Upload failed: {str(e)}"}, status_code=500)

async def create_order(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    restaurant_id = user_payload.get("restaurant_id")

    try:
        body = await request.json()
    except:
         return JSONResponse({"error": "Invalid JSON"}, status_code=400)
    
    total_amount = body.get("total_amount")
    items_data = body.get("items", [])
    
    try:
        with database.get_db_context() as db:
            if total_amount is None or not items_data:
                return JSONResponse({"error": "Order total and items are required"}, status_code=400)

            # Calculate next order number for this restaurant
            last_order = db.query(models.Order).filter(models.Order.restaurant_id == restaurant_id).order_by(models.Order.id.desc()).first()
            next_order_number = (last_order.order_number + 1) if last_order and last_order.order_number else 1

            db_order = models.Order(
                order_number=next_order_number,
                total_amount=float(total_amount),
                payment_status=body.get("payment_status", "unpaid"),
                payment_method=body.get("payment_method", "cash"),
                status="pending",
                restaurant_id=restaurant_id
            )
            db.add(db_order)
            db.commit()
            db.refresh(db_order)
            
            for item in items_data:
                p_id = item.get("product_id")
                # Basic validation that product exists
                prod_check = db.query(models.Product).filter(models.Product.id == p_id).first()
                if not prod_check:
                    return JSONResponse({"error": f"Product with ID {p_id} does not exist"}, status_code=400)

                db_item = models.OrderItem(
                    order_id=db_order.id,
                    product_id=p_id,
                    quantity=item.get("quantity", 1),
                    selected_modifiers=item.get("selected_modifiers", {})
                )
                db.add(db_item)
            db.commit()
            
            # Prepare Response with full details
            enriched_items = []
            db.refresh(db_order) # Reload relationships
            for item in db_order.items:
                enriched_items.append({
                    "id": item.id,
                    "product_id": item.product_id,
                    "product": {
                        "id": item.product.id,
                        "name": item.product.name,
                        "price": item.product.price
                    } if item.product else None,
                    "quantity": item.quantity,
                    "selected_modifiers": item.selected_modifiers
                })

            response_data = {
                "id": db_order.id,
                "order_number": db_order.order_number,
                "status": db_order.status,
                "total_amount": db_order.total_amount,
                "payment_status": db_order.payment_status,
                "payment_method": db_order.payment_method,
                "items": enriched_items,
                "created_at": db_order.created_at.isoformat() if db_order.created_at else None
            }
            
        # Broadcast to ONLY this restaurant's room
        await ws_manager.manager.broadcast_to_restaurant(json.dumps({"event": "new_order", "order_id": response_data["id"]}), restaurant_id)
        
        return JSONResponse(response_data)
    except Exception as e:
        import traceback
        traceback.print_exc()
        return JSONResponse({"error": f"Order placement failed: {str(e)}"}, status_code=500)

async def list_orders(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    restaurant_id = user_payload.get("restaurant_id")

    with database.get_db_context() as db:
        orders = db.query(models.Order).filter(models.Order.restaurant_id == restaurant_id).all()
        if not orders:
            return JSONResponse([])
            
        data = []
        for o in orders:
            items = []
            for i in o.items:
                items.append({
                    "id": i.id,
                    "product_id": i.product_id,
                    "product": {
                        "id": i.product.id,
                        "name": i.product.name,
                        "price": i.product.price
                    } if i.product else None,
                    "quantity": i.quantity,
                    "selected_modifiers": i.selected_modifiers
                })
            data.append({
                "id": o.id,
                "order_number": o.order_number,
                "status": o.status,
                "total_amount": o.total_amount,
                "payment_status": o.payment_status,
                "payment_method": o.payment_method,
                "created_at": o.created_at.isoformat() if o.created_at else None,
                "items": items
            })
        return JSONResponse(data)

async def update_order_status(request: Request):
    user_payload = get_current_user_obj(request)
    if not user_payload:
        return JSONResponse({"error": "Unauthorized"}, status_code=401)
    
    restaurant_id = user_payload.get("restaurant_id")
    order_id = request.path_params['order_id']
    status = request.query_params.get("status_update")
    
    with database.get_db_context() as db:
        db_order = db.query(models.Order).filter(models.Order.id == order_id, models.Order.restaurant_id == restaurant_id).first()
        if not db_order:
            return JSONResponse({"error": "Order not found"}, status_code=404)
        
        db_order.status = status
        db.commit()
        
    await ws_manager.manager.broadcast_to_restaurant(json.dumps({"event": "order_update", "order_id": order_id, "status": status}), restaurant_id)
    return JSONResponse({"status": "success"})
