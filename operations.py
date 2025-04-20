import receipts_db as rdb
from datetime import date

# adding without receipt use for debugging rn 
def save_receipt_without_image(session, store_name, category_name, payment_method, total_amount, purchase_date):
    # Try to get or create store
    store = session.query(rdb.Store).filter_by(name=store_name).first()
    if not store:
        store = rdb.Store(name=store_name)
        session.add(store)
        session.commit()  # commit here to generate store.id for the foreign key

    # Try to get or create category
    category = session.query(rdb.Category).filter_by(name=category_name).first()
    if not category:
        category = rdb.Category(name=category_name)
        session.add(category)
        session.commit()

    # Try to get or create payment method
    payment_method_instance = session.query(rdb.PaymentMethod).filter_by(method=payment_method).first()
    if not payment_method_instance:
        payment_method_instance = rdb.PaymentMethod(method=payment_method)
        session.add(payment_method_instance)
        session.commit()

    # Now all foreign key references are guaranteed to exist
    new_receipt = rdb.Receipt(
        store=store,
        category=category,
        payment_method=payment_method_instance,
        total_amount=total_amount,
        purchase_date=purchase_date,
        image_path=None
    )
    session.add(new_receipt)
    session.commit()

# Function to save receipt with image
def save_receipt_with_image(session, store_name, category_name, payment_Method, total_amount, purchase_date, image_path):
    with open(image_path, 'rb') as img_file:
        image_data = img_file.read()

    # Get or create foreign key references
    store = session.query(rdb.Store).filter_by(name=store_name).first()
    if not store:
        store = rdb.Store(name=store_name)
        session.add(store)
        session.commit()

    category = session.query(rdb.Category).filter_by(name=category_name).first()
    if not category:
        category = rdb.Category(name=category_name)
        session.add(category)
        session.commit()

    payment_method_instance = session.query(rdb.PaymentMethod).filter_by(method=payment_Method).first()
    if not payment_method_instance:
        payment_method_instance = rdb.PaymentMethod(method=payment_Method)
        session.add(payment_method_instance)
        session.commit()

    # Create new receipt object using foreign key relationships
    new_receipt = rdb.Receipt(
        store=store,
        category=category,
        payment_method=payment_method_instance,
        total_amount=total_amount,
        purchase_date=purchase_date,
        image_path=image_data  # Save the image as binary data
    )
    session.add(new_receipt)
    session.commit()


# Function to retrieve the image from the database
def retrieve_image_from_receipt(session, receipt_id, save_path):
    receipt = session.query(rdb.Receipt).filter_by(id=receipt_id).first()

    if receipt and receipt.image_data:
        with open(save_path, 'wb') as img_file:
            img_file.write(receipt.image_data)  # Save the binary image data to a file

# Function to retrieve or create objects
def get_or_create(model, **kwargs):
    instance = session.query(model).filter_by(**kwargs).first()
    if not instance:
        instance = model(**kwargs)
        session.add(instance)
        session.commit()
    return instance

# Function to delete a receipt
def delete_receipt(receipt_id):
    receipt = session.query(rdb.Receipt).get(receipt_id)
    if receipt:  # Check if the receipt exists
        session.delete(receipt)
        session.commit()
        print(f"Deleted receipt with ID: {receipt_id}")
    else:
        print(f"No receipt found with ID: {receipt_id}")

def list_all():
    receipts = session.query(rdb.Receipt).all()
    for r in receipts:
        print(f"{r.id} | {r.store.name} | {r.category.name} | {r.payment_method.method} | {r.purchase_date} | ${r.total_amount}")
        
session = rdb.create_database()




