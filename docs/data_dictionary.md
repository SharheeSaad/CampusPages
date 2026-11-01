# CampusPages Data Dictionary
**Version:** 2.0.0 | **DBMS:** MySQL 8.0+ Community Edition / Relational Engine  
**Architecture:** 14 Tables (3NF with Controlled 2NF Exception on `course_books`)  

---

### 1. `programmes` (D2 Academic Catalogue)
Stores official academic degree programmes offered by the university.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `programme_id` | INT | No | PK | Auto-increment unique programme identifier. |
| `code` | VARCHAR(20) | No | UQ | Short programme abbreviation (e.g., `BCS`, `BIT`, `BBA`). |
| `name` | VARCHAR(150) | No | | Full formal degree title. |

---

### 2. `forecast_params` (D3 Syllabus & Forecast Parameters)
Calibrated algorithmic reorder multipliers scoped at the degree programme level.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `programme_id` | INT | No | PK, FK | References `programmes(programme_id)` `ON DELETE CASCADE`. |
| `buy_rate` | DECIMAL(4,3)| No | | Probability multiplier from survey baseline. `CHECK (buy_rate >= 0.000 AND buy_rate <= 1.000)`. Default `0.650`. |
| `buffer` | INT | No | | Contingency safety stock units. `CHECK (buffer >= 0)`. Default `5`. |

---

### 3. `users` (D1 User Accounts)
Unified user authentication entity enforcing role-based permissions (`student`, `instructor`, `owner`).

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `user_id` | INT | No | PK | Auto-increment unique account identifier. |
| `email` | VARCHAR(120) | No | UQ | Institutional or demo email format. |
| `password_hash` | VARCHAR(255) | No | | Werkzeug salted hash (PBKDF2/scrypt). Plaintext is never stored. |
| `full_name` | VARCHAR(100) | No | | Registered full name. |
| `role` | ENUM | No | | RBAC boundary: `'student'`, `'instructor'`, `'owner'`. |
| `student_no` | VARCHAR(50) | Yes | UQ | Unique university student ID. Must be `NOT NULL` for students, `NULL` for instructors/owners. |
| `programme_id` | INT | Yes | FK | References `programmes(programme_id)` `ON DELETE RESTRICT`. Required for students. |
| `current_semester` | INT | Yes | | Enrolled semester index. `CHECK (current_semester IS NULL OR (current_semester >= 1 AND current_semester <= 12))`. |
| `created_at` | TIMESTAMP | No | | Account registration timestamp. Default `CURRENT_TIMESTAMP`. |

*Table Constraint:* `ck_users_role_fields` guarantees that `(role = 'student' AND student_no IS NOT NULL AND programme_id IS NOT NULL)` OR `(role <> 'student' AND student_no IS NULL)`.

---

### 4. `courses` (D2 Academic Catalogue)
Curricular units tied to degree programmes and semester schedules.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `course_id` | INT | No | PK | Auto-increment unique course record ID. |
| `programme_id` | INT | No | FK | References `programmes(programme_id)` `ON DELETE CASCADE`. |
| `course_code` | VARCHAR(20) | No | UQ | Academic course syllabus code (e.g., `BIC3203`). |
| `title` | VARCHAR(150) | No | | Course module name. |
| `semester_no` | INT | No | | Semester sequence number. `CHECK (semester_no >= 1 AND semester_no <= 12)`. |

---

### 5. `books` (D2 Academic Catalogue)
Conceptual intellectual works independent of publication formats.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `book_id` | INT | No | PK | Auto-increment unique book identifier. |
| `title` | VARCHAR(200) | No | | Standard textbook title. |
| `author` | VARCHAR(150) | No | | Author(s) or editor attribution. |

---

### 6. `editions` (D2 Academic Catalogue)
Specific physical printings and curricular editions of conceptual books.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `edition_id` | INT | No | PK | Auto-increment unique edition identifier. |
| `book_id` | INT | No | FK | References `books(book_id)` `ON DELETE CASCADE`. |
| `isbn` | VARCHAR(20) | Yes | UQ | Standard 10 or 13-digit ISBN barcode format. |
| `edition_no` | VARCHAR(50) | No | | Edition version string (e.g., `10th Global Edition`). |
| `new_price` | DECIMAL(10,2)| No | | Retail price in BDT. `CHECK (new_price > 0)`. |

---

### 7. `course_books` (D3 Syllabus & Forecast Parameters)
Instructor-validated textbook adoptions per course and academic semester.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `course_id` | INT | No | PK, FK | References `courses(course_id)` `ON DELETE CASCADE`. |
| `edition_id` | INT | No | PK, FK | References `editions(edition_id)` `ON DELETE RESTRICT`. |
| `term` | VARCHAR(30) | No | PK | Academic semester term string (e.g., `September 2026`). |
| `expected_enrolment` | INT | No | | Projected class size. `CHECK (expected_enrolment >= 0)`. Default `0`. *(Controlled 2NF exception)*. |
| `is_required` | BOOLEAN | No | | `TRUE` for mandatory core textbooks, `FALSE` for supplementary reading. Default `TRUE`. |
| `confirmed_by` | INT | Yes | FK | References `users(user_id)` `ON DELETE SET NULL` (Faculty Instructor ID). |
| `confirmed_at` | DATETIME | Yes | | Timestamp of instructor validation. Default `CURRENT_TIMESTAMP`. |

*Primary Key:* Composite `(course_id, edition_id, term)`.

---

### 8. `stock` (D4 Stock)
Physical new inventory on hand and active reservation hold tracking.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `edition_id` | INT | No | PK, FK | References `editions(edition_id)` `ON DELETE RESTRICT`. 1:1 identifying relationship. |
| `qty_new` | INT | No | | Physical new copies physically on shelf. `CHECK (qty_new >= 0)`. Default `0`. |
| `qty_reserved`| INT | No | | Copies held for open uncollected reservations. `CHECK (qty_reserved >= 0)`. Default `0`. |

*Stock Semantics:*
* Net available units for new orders $= \text{qty\_new} - \text{qty\_reserved}$.
* Reservation placed: `qty_reserved` increments by 1.
* Reservation cancelled: `qty_reserved` decrements by 1.
* In-person collection completed: both `qty_new` and `qty_reserved` decrement by 1.
* Constraint: `CHECK (qty_reserved <= qty_new)`.

---

### 9. `used_listings` (D5 Used Listings)
Peer-to-peer textbook resale intake, grading, and approval lifecycle.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `listing_id` | INT | No | PK | Auto-increment unique used book listing ID. |
| `seller_id` | INT | No | FK | References `users(user_id)` `ON DELETE RESTRICT` (Student seller). |
| `edition_id` | INT | No | FK | References `editions(edition_id)` `ON DELETE RESTRICT`. |
| `declared_condition` | ENUM | No | | Student seller appraisal: `'good'`, `'fair'`, `'acceptable'`. |
| `condition_grade` | ENUM | Yes | | Store owner verified physical grade: `'like_new'`, `'good'`, `'fair'`. |
| `asking_price` | DECIMAL(10,2)| No | | Seller's requested payout price in BDT. `CHECK (asking_price > 0)`. |
| `approved_price` | DECIMAL(10,2)| Yes | | Store owner approved listing price in BDT. `CHECK (approved_price IS NULL OR approved_price > 0)`. |
| `status` | ENUM | No | | Listing lifecycle: `'pending_inspection'`, `'available'`, `'reserved'`, `'sold'`, `'paid_out'`, `'rejected'`, `'withdrawn'`. Default `'pending_inspection'`. |
| `created_at` | TIMESTAMP | No | | Submission timestamp. Default `CURRENT_TIMESTAMP`. |

*Integrity Rule:* `ck_used_graded` enforces that a listing cannot transition to `'available'`, `'reserved'`, `'sold'`, or `'paid_out'` unless `condition_grade` and `approved_price` are both populated.

---

### 10. `waitlist` (D6 Reservations & Queues)
Prioritized FIFO restock waiting list for titles out of stock.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `waitlist_id` | INT | No | PK | Auto-increment unique queue entry identifier. |
| `student_id` | INT | No | FK | References `users(user_id)` `ON DELETE CASCADE`. |
| `edition_id` | INT | No | FK | References `editions(edition_id)` `ON DELETE CASCADE`. |
| `joined_at` | DATETIME | No | | Enqueue timestamp. Default `CURRENT_TIMESTAMP`. |
| `notified_at` | DATETIME | Yes | | Timestamp when stock availability alert was dispatched. `NULL` while awaiting stock. |

*Unique Key:* `uq_student_edition_waitlist (student_id, edition_id)` prevents duplicate queue entries by the same student.

---

### 11. `notifications` (D8 Notifications)
In-app communication feed for queue alerts, intake confirmations, and pickup notices.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `notification_id`| INT | No | PK | Auto-increment unique message ID. |
| `user_id` | INT | No | FK | References `users(user_id)` `ON DELETE CASCADE`. |
| `message` | TEXT | No | | Plaintext notification payload. |
| `is_read` | BOOLEAN | No | | Read receipt flag. Default `FALSE`. |
| `created_at` | DATETIME | No | | Dispatch timestamp. Default `CURRENT_TIMESTAMP`. |

---

### 12. `reservations` (D6 Reservations)
Master reservation order entity for new bundles or individual titles.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `reservation_id` | INT | No | PK | Auto-increment unique reservation order ID. |
| `student_id` | INT | No | FK | References `users(user_id)` `ON DELETE RESTRICT`. |
| `status` | ENUM | No | | Order status: `'unpaid_reserved'`, `'paid_reserved'`, `'completed'`, `'cancelled'`. Default `'unpaid_reserved'`. |
| `payment_method` | ENUM | No | | Payment selection: `'cash'`, `'bkash'`, `'nagad'`. |
| `qr_token` | VARCHAR(64) | No | UQ | Cryptographically secure URL-safe alphanumeric token generated via `secrets.token_urlsafe()`. Encoded into QR pass. |
| `created_at` | DATETIME | No | | Order submission timestamp. Default `CURRENT_TIMESTAMP`. |

---

### 13. `reservation_items` (D6 Reservations)
Individual line items attached to a reservation order.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `item_id` | INT | No | PK | Auto-increment unique line item ID. |
| `reservation_id` | INT | No | FK | References `reservations(reservation_id)` `ON DELETE CASCADE`. |
| `edition_id` | INT | No | FK | References `editions(edition_id)` `ON DELETE RESTRICT`. |
| `listing_id` | INT | Yes | FK | References `used_listings(listing_id)` `ON DELETE RESTRICT`. `NULL` denotes new copy allocated from `stock`. |
| `unit_price` | DECIMAL(10,2)| No | | Captured historical price snapshot locked at reservation creation. `CHECK (unit_price > 0)`. |

*Concurrency Rule:* Multiple reservations may reference the same `listing_id` across historical records (e.g., after an earlier cancellation), but concurrency is guarded atomically via `used_listings.status = 'reserved'`.

---

### 14. `transactions` (D7 Transaction Ledger)
Immutable financial audit ledger logging all wallet payments, physical cash settlements, refunds, platform commissions, and seller disbursements.

| Attribute | Data Type | Nullable | Key | Constraints & Business Rules |
| :--- | :--- | :--- | :--- | :--- |
| `txn_id` | INT | No | PK | Auto-increment sequential ledger audit ID. |
| `reservation_id` | INT | Yes | FK | References `reservations(reservation_id)` `ON DELETE RESTRICT`. Populated for student payments/refunds. |
| `listing_id` | INT | Yes | FK | References `used_listings(listing_id)` `ON DELETE RESTRICT`. Populated for seller payouts/commissions. |
| `txn_type` | ENUM | No | | Ledger entry type: `'payment'`, `'cash_settlement'`, `'refund'`, `'commission'`, `'payout'`. |
| `amount` | DECIMAL(10,2)| No | | Transaction value in BDT. `CHECK (amount > 0)`. |
| `created_at` | DATETIME | No | | Immutable creation timestamp. Default `CURRENT_TIMESTAMP`. |

*Ledger Immutability Enforcement:*
* Database triggers `trg_transactions_no_update` and `trg_transactions_no_delete` intercept and block any `UPDATE` or `DELETE` statements with SQLState `'45000'`.
* Constraint: `ck_tx_link` guarantees that `(reservation_id IS NOT NULL OR listing_id IS NOT NULL)`.