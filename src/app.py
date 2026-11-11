import os
from flask import Flask, render_template, session, redirect, url_for
from dotenv import load_dotenv
from src.db import get_db_connection

load_dotenv()

def create_app():
    app = Flask(__name__)
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "campuspages-dev-secret-key-2026")

    @app.route("/")
    def index():
        conn = get_db_connection()
        programmes = []
        try:
            with conn.cursor() as cursor:
                cursor.execute("SELECT programme_id, code, name FROM programmes ORDER BY programme_id ASC;")
                programmes = cursor.fetchall()
        finally:
            conn.close()

        return render_template("index.html", programmes=programmes)

    return app

app = create_app()

if __name__ == "__main__":
    app.run(debug=True, port=5000)