import os
import pymysql
from pymysql.cursors import DictCursor
from dotenv import load_dotenv

load_dotenv()

def get_db_connection(use_db=True):
    """Establishes and returns an active MySQL connection."""
    kwargs = {
        "host": os.getenv("DB_HOST", "127.0.0.1"),
        "port": int(os.getenv("DB_PORT", 3306)),
        "user": os.getenv("DB_USER", "root"),
        "password": os.getenv("DB_PASSWORD", ""),
        "cursorclass": DictCursor,
        "autocommit": False,
        "charset": "utf8mb4",
        "client_flag": pymysql.constants.CLIENT.MULTI_STATEMENTS
    }
    if use_db:
        kwargs["database"] = os.getenv("DB_NAME", "campuspages_db")
    return pymysql.connect(**kwargs)

def init_database():
    """Executes database/schema.sql and database/seed.sql into MySQL."""
    conn = get_db_connection(use_db=False)
    try:
        with conn.cursor() as cursor:
            with open("database/schema.sql", "r", encoding="utf-8") as f:
                cursor.execute(f.read())
            with open("database/seed.sql", "r", encoding="utf-8") as f:
                cursor.execute(f.read())
        conn.commit()
        print("[OK] schema.sql and seed.sql executed successfully!")
    finally:
        conn.close()

def test_connection():
    """Validates database reachability and counts seeded rows."""
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS total_programmes FROM programmes;")
            progs = cursor.fetchone()["total_programmes"]
            cursor.execute("SELECT COUNT(*) AS total_courses FROM courses;")
            courses = cursor.fetchone()["total_courses"]
            print(f"[OK] Database connected. Found {progs} programmes and {courses} courses.")
        conn.close()
        return True
    except Exception as e:
        print(f"[ERROR] Database connection failed: {e}")
        return False

if __name__ == "__main__":
    init_database()
    test_connection()