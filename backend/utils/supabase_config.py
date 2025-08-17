import psycopg2
from supabase import create_client, Client
from dotenv import load_dotenv
import os

# Load environment variables from .env
load_dotenv()

# Method 1: Direct PostgreSQL connection (if you have direct DB credentials)
def connect_postgres():
    """Connect directly to PostgreSQL database"""
    USER = os.getenv("user")
    PASSWORD = os.getenv("password")
    HOST = os.getenv("host")
    PORT = os.getenv("port")
    DBNAME = os.getenv("dbname")

    try:
        connection = psycopg2.connect(
            user=USER,
            password=PASSWORD,
            host=HOST,
            port=PORT,
            database=DBNAME
        )
        print("PostgreSQL connection successful!")
        
        # Create a cursor to execute SQL queries
        cursor = connection.cursor()
        
        # Example query
        cursor.execute("SELECT NOW();")
        result = cursor.fetchone()
        print("Current Time:", result)

        # Close the cursor and connection
        cursor.close()
        connection.close()
        print("Connection closed.")
        
        return True

    except Exception as e:
        print(f"Failed to connect to PostgreSQL: {e}")
        return False

# Method 2: Supabase client connection (recommended)
def connect_supabase():
    """Connect using Supabase client"""
    try:
        url = os.getenv("SUPABASE_PROJECT_URL")
        key = os.getenv("SUPABASE_ANON_KEY")
        
        if not url or not key:
            print("Missing Supabase credentials in .env file")
            return None
            
        supabase: Client = create_client(url, key)
        print("Supabase client initialized successfully!")
        print(f"URL: {url}")
        print(f"Key: {key[:20]}...")
        
        return supabase
        
    except Exception as e:
        print(f"Failed to connect to Supabase: {e}")
        return None

if __name__ == "__main__":
    print("Testing database connections...")
    print("\n1. Testing Supabase connection:")
    supabase_client = connect_supabase()
    
    print("\n2. Testing direct PostgreSQL connection:")
    postgres_success = connect_postgres()