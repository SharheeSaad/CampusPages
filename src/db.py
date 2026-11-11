import os
import pymysql
from pymysql.cursors import DictCursor
from dotenv import load_dotenv

load_dotenv()

def get_db_connection():
    """Establishes and returns an active MySQL connection."""
    return pymysql.connect(
        host=os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("DB_PORT", 3306)),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "campuspages_db"),
        cursorclass=DictCursor,
        autocommit=False,
        charset="utf8mb4"
    )

def test_connection():
    """Validates database reachability and table accessibility."""
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS total_programmes FROM programmes;")
            result = cursor.fetchone()
            print(f"[OK] Database connected. Found {result['total_programmes']} programmes.")
        conn.close()
        return True
    except Exception as e:
        print(f"[ERROR] Database connection failed: {e}")
        return False

if __name__ == "__main__":
    test_connection()