# CampusPages Data Dictionary
**Version:** 1.0.0 | **DBMS:** MySQL 8.0 / Relational Engine  

---

| Table Name | Attribute | Data Type | Nullable | Key | Description / Constraints |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **programmes** | programme_id | INT | No | PK | Auto-increment unique programme identifier |
| | name | VARCHAR(150) | No | | Full degree name (e.g., BSc Computer Science) |
| | code | VARCHAR(20) | No | UQ | Short programme code (e.g., BCS, BIT) |
| **users** | user_id | INT | No | PK | Auto-increment unique user account ID |
| | name | VARCHAR(100) | No | | Full legal name |
| | email | VARCHAR(120) | No | UQ | Official university email address |
| | password_hash | VARCHAR(255) | No | | Werkzeug salted PBKDF2/scrypt hash |
| | role | ENUM | No | | Role boundary: `student`, `instructor`, `owner` |
| | student_id | VARCHAR(50) | Yes | | University registration/student ID |
| | programme_id | INT | Yes | FK | References `programmes(programme_id)` |
| | current_semester | INT | Yes | | Current semester index (1 to 9) |
| **courses** | course_id | INT | No | PK | Unique course identifier |
| | code | VARCHAR(20) | No | UQ | Course syllabus code (e.g., BIC3203) |
| | title | VARCHAR(150) | No | | Formal course title |
| | programme_id | INT | No | FK | References `programmes(programme_id)` |
| | semester_no | INT | No | | Scheduled academic semester |
| **books** | book_id | INT | No | PK | Conceptual title identifier |
| | title | VARCHAR(200) | No | | Standard book title |
| | author | VARCHAR(150) | No | | Author(s) names |
| **editions** | edition_id | INT | No | PK | Physical curricular edition identifier |
| | book_id | INT | No | FK | References `books(book_id)` |
| | edition_label | VARCHAR(50) | No | | Edition version (e.g., 10th Global Edition) |
| | isbn | VARCHAR(20) | Yes | UQ | Unique ISBN-10 or ISBN-13 barcode number |
| | publication_year | INT | Yes | | Year published |
| | new_price | DECIMAL(10,2)| No | | Retail price in Bangladeshi Taka (BDT) |
| **course_books**| course_book_id | INT | No | PK | Unique syllabus assignment ID |
| | course_id | INT | No | FK | References `courses(course_id)` |
| | edition_id | INT | No | FK | References `editions(edition_id)` |
| | term | VARCHAR(30) | No | | Target semester term (e.g., September 2026) |
| | expected_enrolment | INT | No | | Projected student enrollment figure |
| **stock** | stock_id | INT | No | PK | Inventory row ID |
| | edition_id | INT | No | FK, UQ| References `editions(edition_id)` |
| | qty_new | INT | No | | Unallocated physical new copies on hand |
| | reorder_level | INT | No | | Minimum safety threshold triggering reorder alert |
| **used_listings** | listing_id | INT | No | PK | Used textbook listing record |
| | seller_id | INT | No | FK | References `users(user_id)` |
| | edition_id | INT | No | FK | References `editions(edition_id)` |
| | condition_grade | ENUM | Yes | | Physical grade: `like_new`, `good`, `fair` |
| | price | DECIMAL(10,2)| No | | Listed selling price in BDT |
| | status | ENUM | No | | Status: `pending_inspection`, `available`, `reserved`, `sold`, `paid_out` |
| **reservations**| reservation_id | INT | No | PK | Master reservation order ID |
| | student_id | INT | No | FK | References `users(user_id)` |
| | status | ENUM | No | | Status: `unpaid_reserved`, `paid_reserved`, `completed`, `cancelled` |
| | payment_method | ENUM | No | | Method: `cash`, `bkash`, `nagad` |
| | pickup_code | VARCHAR(64) | No | UQ | Secure alphanumeric token encoded into QR slip |
| **reservation_items** | item_id | INT | No | PK | Line item ID |
| | reservation_id | INT | No | FK | References `reservations(reservation_id)` |
| | edition_id | INT | No | FK | References `editions(edition_id)` |
| | copy_type | ENUM | No | | `new` (from stock) or `used` (from used_listings) |
| | listing_id | INT | Yes | FK | References `used_listings(listing_id)` |
| | unit_price | DECIMAL(10,2)| No | | Unit line price locked at reservation time |
| **waitlist** | waitlist_id | INT | No | PK | Waitlist queue ID |
| | student_id | INT | No | FK | References `users(user_id)` |
| | edition_id | INT | No | FK | References `editions(edition_id)` |
| | notified | BOOLEAN | No | | Flag indicating notification sent |
| **transactions**| txn_id | INT | No | PK | Ledger sequence ID |
| | reservation_id | INT | Yes | FK | References `reservations(reservation_id)` |
| | type | ENUM | No | | Transaction type: `payment`, `refund`, `commission`, `payout` |
| | method | ENUM | No | | Payment rail: `cash`, `bkash`, `nagad` |
| | amount | DECIMAL(10,2)| No | | Transaction magnitude in BDT |
| | status | ENUM | No | | `pending`, `completed`, `failed` |
| **notifications**| notification_id| INT | No | PK | Notification message ID |
| | user_id | INT | No | FK | References `users(user_id)` |
| | message | TEXT | No | | In-app notification payload |
| | is_read | BOOLEAN | No | | Status indicating whether recipient read message |
| **forecast_params** | param_id | INT | No | PK | Model parameter row ID |
| | course_id | INT | No | FK, UQ| References `courses(course_id)` |
| | buy_rate | DECIMAL(4,3)| No | | Calibrated buy probability (0.000 to 1.000) |
| | buffer | INT | No | | Static contingency safety buffer |
| | source | ENUM | No | | Source calibration: `survey` or `estimate` |