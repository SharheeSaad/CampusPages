import os
import json
from flask import Flask, render_template, send_from_directory, Response, jsonify
from dotenv import load_dotenv
from src.db import get_db_connection

load_dotenv()

def fetch_mysql_state():
    """Queries the 14 MySQL tables and formats them for the CampusPages frontend store."""
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # 1. Programmes & Forecast Params
            cursor.execute("""
                SELECT p.programme_id AS id, p.code, p.name,
                       COALESCE(fp.buy_rate, 0.650) AS buyRate,
                       COALESCE(fp.buffer, 5) AS buffer
                FROM programmes p
                LEFT JOIN forecast_params fp ON p.programme_id = fp.programme_id
                ORDER BY p.programme_id ASC;
            """)
            programmes = cursor.fetchall()
            for p in programmes:
                p["buyRate"] = float(p["buyRate"])

            # 2. Courses (including credits)
            cursor.execute("""
                SELECT course_id AS id, programme_id AS programmeId,
                       course_code AS code, title, semester_no AS semester, credits
                FROM courses
                ORDER BY course_id ASC;
            """)
            courses = cursor.fetchall()

            # 3. Books + Editions + Course Books + Stock
            cursor.execute("""
                SELECT 
                    e.edition_id AS id,
                    c.course_id AS courseId,
                    c.course_code AS courseCode,
                    c.title AS courseTitle,
                    c.programme_id AS programmeId,
                    c.semester_no AS semester,
                    c.credits AS credits,
                    b.title,
                    b.author,
                    e.edition_no AS edition,
                    e.isbn,
                    e.new_price AS newPrice,
                    COALESCE(s.qty_new, 0) AS qtyNew,
                    COALESCE(s.qty_reserved, 0) AS qtyReserved,
                    cb.expected_enrolment AS enrolment,
                    cb.term,
                    COALESCE(u.full_name, 'Dr. Syllabus Instructor (FAC001)') AS confirmedBy,
                    CAST(cb.confirmed_at AS CHAR) AS confirmedAt
                FROM course_books cb
                JOIN courses c ON cb.course_id = c.course_id
                JOIN editions e ON cb.edition_id = e.edition_id
                JOIN books b ON e.book_id = b.book_id
                LEFT JOIN stock s ON e.edition_id = s.edition_id
                LEFT JOIN users u ON cb.confirmed_by = u.user_id
                ORDER BY e.edition_id ASC;
            """)
            books = cursor.fetchall()
            for b in books:
                b["newPrice"] = float(b["newPrice"])

            # 4. Used Listings
            cursor.execute("""
                SELECT 
                    ul.listing_id AS id,
                    ul.edition_id AS bookId,
                    ul.seller_id AS sellerId,
                    u.full_name AS sellerName,
                    u.email AS sellerEmail,
                    COALESCE(u.student_no, 'STU2024001') AS sellerStudentId,
                    ul.declared_condition AS declaredCondition,
                    COALESCE(ul.condition_grade, ul.declared_condition) AS conditionGrade,
                    ul.asking_price AS askingPrice,
                    COALESCE(ul.approved_price, ul.asking_price) AS approvedPrice,
                    ul.status,
                    CAST(ul.created_at AS CHAR) AS createdAt
                FROM used_listings ul
                JOIN users u ON ul.seller_id = u.user_id
                ORDER BY ul.listing_id ASC;
            """)
            used_listings = cursor.fetchall()
            for ul in used_listings:
                ul["askingPrice"] = float(ul["askingPrice"])
                ul["approvedPrice"] = float(ul["approvedPrice"])

            # 5. Reservations & Items
            cursor.execute("""
                SELECT 
                    r.reservation_id AS numericId,
                    COALESCE(u.student_no, 'STU2025002') AS studentId,
                    u.full_name AS studentName,
                    u.email AS studentEmail,
                    COALESCE(p.code, 'BCS') AS programCode,
                    r.status,
                    r.payment_method AS paymentMethod,
                    r.qr_token AS qrToken,
                    CAST(r.created_at AS CHAR) AS createdAt
                FROM reservations r
                JOIN users u ON r.student_id = u.user_id
                LEFT JOIN programmes p ON u.programme_id = p.programme_id
                ORDER BY r.reservation_id DESC;
            """)
            reservations = cursor.fetchall()

            for res in reservations:
                res["id"] = f"RES-2026-{str(res['numericId']).zfill(3)}"
                cursor.execute("""
                    SELECT 
                        ri.edition_id AS bookId,
                        b.title,
                        e.edition_no AS edition,
                        COALESCE(c.course_code, 'COURSE') AS courseCode,
                        ri.listing_id AS listingId,
                        ri.unit_price AS price
                    FROM reservation_items ri
                    JOIN editions e ON ri.edition_id = e.edition_id
                    JOIN books b ON e.book_id = b.book_id
                    LEFT JOIN course_books cb ON e.edition_id = cb.edition_id
                    LEFT JOIN courses c ON cb.course_id = c.course_id
                    WHERE ri.reservation_id = %s;
                """, (res["numericId"],))
                items = cursor.fetchall()
                total = 0.0
                for item in items:
                    item["price"] = float(item["price"])
                    item["isUsed"] = item["listingId"] is not None
                    total += item["price"]
                res["items"] = items
                res["totalAmount"] = total

            # 6. Waitlist
            cursor.execute("""
                SELECT 
                    w.waitlist_id AS id,
                    w.edition_id AS bookId,
                    COALESCE(u.student_no, 'STU2025002') AS studentId,
                    u.email AS studentEmail,
                    CAST(w.joined_at AS CHAR) AS joinedAt
                FROM waitlist w
                JOIN users u ON w.student_id = u.user_id
                ORDER BY w.waitlist_id ASC;
            """)
            waitlist = cursor.fetchall()

            # 7. Transactions
            cursor.execute("""
                SELECT 
                    t.txn_id,
                    t.reservation_id,
                    t.listing_id AS listingId,
                    t.txn_type AS type,
                    t.amount,
                    CAST(t.created_at AS CHAR) AS createdAt,
                    r.payment_method
                FROM transactions t
                LEFT JOIN reservations r ON t.reservation_id = r.reservation_id
                ORDER BY t.txn_id DESC;
            """)
            txns_raw = cursor.fetchall()
            transactions = []
            for t in txns_raw:
                amt = float(t["amount"])
                res_code = f"RES-2026-{str(t['reservation_id']).zfill(3)}" if t["reservation_id"] else None
                method = (t["payment_method"] or "bKash").upper()
                transactions.append({
                    "id": f"TXN-2026-{str(t['txn_id']).zfill(3)}",
                    "reservationId": res_code,
                    "listingId": t["listingId"],
                    "type": t["type"],
                    "method": method,
                    "amount": amt,
                    "fee": round(amt * 0.10),
                    "sellerPayout": round(amt * 0.90),
                    "createdAt": t["createdAt"],
                    "details": f"Verified {t['type']} via {method} for {res_code or 'Listing'}"
                })

            # 8. Notifications
            cursor.execute("""
                SELECT notification_id AS id, message, is_read, CAST(created_at AS CHAR) AS time
                FROM notifications
                ORDER BY notification_id DESC;
            """)
            notifs_raw = cursor.fetchall()
            notifications = []
            for n in notifs_raw:
                notifications.append({
                    "id": n["id"],
                    "title": "CampusPages System Alert",
                    "message": n["message"],
                    "time": n["time"],
                    "read": bool(n["is_read"])
                })

            return {
                "role": "student",
                "activeSemester": 4,
                "totalSemesters": 9,
                "theme": "light",
                "activeProgrammeId": 1,
                "forecastParams": {"buyRate": 0.65, "buffer": 5},
                "programmes": programmes,
                "courses": courses,
                "books": books,
                "usedListings": used_listings,
                "reservations": reservations,
                "waitlist": waitlist,
                "transactions": transactions,
                "notifications": notifications
            }
    finally:
        conn.close()

def create_app():
    app = Flask(__name__)
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "campuspages-dev-secret-key-2026")

    @app.route("/")
    def index():
        return render_template("index.html")

    @app.route("/css/<path:filename>")
    def serve_css(filename):
        return send_from_directory(os.path.join(app.root_path, "static", "css"), filename)

    @app.route("/js/data.js")
    def serve_dynamic_data_js():
        """Injects live MySQL database records directly into the frontend store."""
        db_state = fetch_mysql_state()
        js_code = f"""
const STORAGE_KEY = 'campuspages_mysql_state_v2';
const INITIAL_SEED_DATA = {json.dumps(db_state, indent=2)};

class StateManager {{
  constructor() {{
    this.state = this.load();
  }}
  load() {{
    try {{
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {{
        return JSON.parse(stored);
      }}
    }} catch (e) {{
      console.warn('Could not read from localStorage, using MySQL seed data.', e);
    }}
    return JSON.parse(JSON.stringify(INITIAL_SEED_DATA));
  }}
  save() {{
    try {{
      localStorage.setItem(STORAGE_KEY, JSON.stringify(this.state));
    }} catch (e) {{
      console.error('Failed to save state', e);
    }}
  }}
  reset() {{
    localStorage.removeItem(STORAGE_KEY);
    this.state = JSON.parse(JSON.stringify(INITIAL_SEED_DATA));
    this.save();
  }}
  get() {{
    return this.state;
  }}
}}
window.CampusPagesStore = new StateManager();
"""
        return Response(js_code, mimetype="application/javascript")

    @app.route("/js/<path:filename>")
    def serve_js(filename):
        return send_from_directory(os.path.join(app.root_path, "static", "js"), filename)

    @app.route("/api/state")
    def api_state():
        return jsonify(fetch_mysql_state())

    return app

app = create_app()

if __name__ == "__main__":
    app.run(debug=True, port=5000)