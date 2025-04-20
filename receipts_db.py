from sqlalchemy import create_engine, Column, Integer, String, Float, Date, ForeignKey, BLOB
from sqlalchemy.orm import declarative_base, relationship, sessionmaker

Base = declarative_base()

class Store(Base):
   __tablename__ = 'stores' 
   id = Column(Integer, primary_key=True)
   name = Column(String, unique=True)
   receipts = relationship("Receipt", back_populates="store")   

class Category(Base):
   __tablename__ = 'categories' 
   id = Column(Integer, primary_key=True)
   name = Column(String, unique=True)
   receipts = relationship("Receipt", back_populates="category")

class PaymentMethod(Base):
   __tablename__ = 'payment_methods'  
   id = Column(Integer, primary_key=True)
   method = Column(String, unique=True)
   receipts = relationship("Receipt", back_populates="payment_method")

class Receipt(Base):
    __tablename__ = 'receipts'
    id = Column(Integer, primary_key=True)
    store_id = Column(Integer, ForeignKey('stores.id')) # Int -> string
    category_id = Column(Integer, ForeignKey('categories.id'))
    payment_method_id = Column(Integer, ForeignKey('payment_methods.id')) # Int -> string
    total_amount = Column(Float)
    purchase_date = Column(Date)
    image_path = Column(BLOB, nullable=True)  

    store = relationship("Store", back_populates="receipts")
    category = relationship("Category", back_populates="receipts")
    payment_method = relationship("PaymentMethod", back_populates="receipts")

def create_database(db_url="sqlite:///receipts.db"):
   engine = create_engine(db_url)
   Base.metadata.create_all(engine)
   Session = sessionmaker(bind=engine)
   return Session()