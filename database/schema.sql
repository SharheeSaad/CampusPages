-- =====================================================================
-- CampusPages Database Schema
-- Target DBMS : MySQL Community Server 8.0.16+ (CHECK constraints enforced)
-- Design      : 14 tables, 3NF (one controlled 2NF exception: course_books.expected_enrolment)
-- Run order   : schema.sql first, then seed.sql

DROP DATABASE IF EXISTS campuspages_db;
CREATE DATABASE campuspages_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE campuspages_db;

-- 1. programmes (D2 Academic Catalogue)
CREATE TABLE programmes (
    programme_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL
) ENGINE=InnoDB;

-- 2. forecast_params (D3 Syllabus & Forecast Parameters), one row per programme
CREATE TABLE forecast_params (
    programme_id INT PRIMARY KEY,
    buy_rate DECIMAL(4, 3) NOT NULL DEFAULT 0.650,
    buffer INT NOT NULL DEFAULT 5,
    CONSTRAINT fk_forecast_programme FOREIGN KEY (programme_id) REFERENCES programmes(programme_id) ON DELETE CASCADE,
    CONSTRAINT ck_forecast_buy_rate CHECK (buy_rate >= 0.000 AND buy_rate <= 1.000),
    CONSTRAINT ck_forecast_buffer CHECK (buffer >= 0)
) ENGINE=InnoDB;

-- 3. users (D1 User Accounts)
-- Students need a student_no and programme; instructors/owner have neither.
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('student', 'instructor', 'owner') NOT NULL,
    student_no VARCHAR(50) UNIQUE DEFAULT NULL,
    programme_id INT DEFAULT NULL,
    current_semester INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_programme FOREIGN KEY (programme_id) REFERENCES programmes(programme_id) ON DELETE RESTRICT,
    CONSTRAINT ck_users_semester CHECK (current_semester IS NULL OR (current_semester >= 1 AND current_semester <= 12)),
    CONSTRAINT ck_users_role_fields CHECK (
        (role = 'student' AND student_no IS NOT NULL AND programme_id IS NOT NULL)
        OR (role <> 'student' AND student_no IS NULL)
    )
) ENGINE=InnoDB;

-- 4. courses (D2 Academic Catalogue)
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    programme_id INT NOT NULL,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    semester_no INT NOT NULL,
    CONSTRAINT fk_courses_programme FOREIGN KEY (programme_id) REFERENCES programmes(programme_id) ON DELETE CASCADE,
    CONSTRAINT ck_courses_semester CHECK (semester_no >= 1 AND semester_no <= 12)
) ENGINE=InnoDB;

-- 5. books (D2 Academic Catalogue)
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL
) ENGINE=InnoDB;

-- 6. editions (D2 Academic Catalogue)
CREATE TABLE editions (
    edition_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    isbn VARCHAR(20) UNIQUE DEFAULT NULL,
    edition_no VARCHAR(50) NOT NULL,
    new_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_editions_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CONSTRAINT ck_editions_price CHECK (new_price > 0)
) ENGINE=InnoDB;

-- 7. course_books (D3 Syllabus & Forecast Parameters)
-- Key: (course_id, edition_id, term).
-- Controlled 2NF exception: expected_enrolment depends on (course_id, term) only,
-- kept here to hold the design at 14 tables.
CREATE TABLE course_books (
    course_id INT NOT NULL,
    edition_id INT NOT NULL,
    term VARCHAR(30) NOT NULL,
    expected_enrolment INT NOT NULL DEFAULT 0,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    confirmed_by INT DEFAULT NULL,
    confirmed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (course_id, edition_id, term),
    CONSTRAINT fk_cb_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    CONSTRAINT fk_cb_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE RESTRICT,
    CONSTRAINT fk_cb_confirmed_by FOREIGN KEY (confirmed_by) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT ck_cb_enrolment CHECK (expected_enrolment >= 0)
) ENGINE=InnoDB;

-- 8. stock (D4 Stock)
-- qty_new      = new copies physically on hand
-- qty_reserved = of those, copies held for open (not yet collected) reservations
-- available    = qty_new - qty_reserved
-- reserve: qty_reserved + 1 | cancel: qty_reserved - 1 | pickup: both - 1
CREATE TABLE stock (
    edition_id INT PRIMARY KEY,
    qty_new INT NOT NULL DEFAULT 0,
    qty_reserved INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_stock_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE RESTRICT,
    CONSTRAINT ck_stock_qty CHECK (qty_new >= 0 AND qty_reserved >= 0 AND qty_reserved <= qty_new)
) ENGINE=InnoDB;

-- 9. used_listings (D5 Used Listings)
-- A listing can only be available/reserved/sold/paid_out once it has an owner-assigned grade and price.
CREATE TABLE used_listings (
    listing_id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    edition_id INT NOT NULL,
    declared_condition ENUM('good', 'fair', 'acceptable') NOT NULL,
    condition_grade ENUM('like_new', 'good', 'fair') DEFAULT NULL,
    asking_price DECIMAL(10, 2) NOT NULL,
    approved_price DECIMAL(10, 2) DEFAULT NULL,
    status ENUM('pending_inspection', 'available', 'reserved', 'sold', 'paid_out', 'rejected', 'withdrawn')
        NOT NULL DEFAULT 'pending_inspection',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_used_seller FOREIGN KEY (seller_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_used_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE RESTRICT,
    CONSTRAINT ck_used_asking CHECK (asking_price > 0),
    CONSTRAINT ck_used_approved CHECK (approved_price IS NULL OR approved_price > 0),
    CONSTRAINT ck_used_graded CHECK (
        status NOT IN ('available', 'reserved', 'sold', 'paid_out')
        OR (condition_grade IS NOT NULL AND approved_price IS NOT NULL)
    )
) ENGINE=InnoDB;

-- 10. waitlist (D6 Reservations & Queues)
CREATE TABLE waitlist (
    waitlist_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    edition_id INT NOT NULL,
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    notified_at DATETIME DEFAULT NULL,
    UNIQUE KEY uq_student_edition_waitlist (student_id, edition_id),
    CONSTRAINT fk_waitlist_student FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_waitlist_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 11. notifications (D8 Notifications)
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 12. reservations (D6 Reservations)
-- qr_token must be unguessable: generate in the app with secrets.token_urlsafe(), never sequential.
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    status ENUM('unpaid_reserved', 'paid_reserved', 'completed', 'cancelled') NOT NULL DEFAULT 'unpaid_reserved',
    payment_method ENUM('cash', 'bkash', 'nagad') NOT NULL,
    qr_token VARCHAR(64) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_res_student FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 13. reservation_items (D6 Reservations)
-- listing_id NULL = new copy from stock; listing_id set = used copy.
-- No UNIQUE on listing_id: cancelled reservations keep their items as history.
-- The app must reserve a used copy atomically:
--   UPDATE used_listings SET status='reserved' WHERE listing_id=? AND status='available';
--   and proceed only if exactly 1 row was updated.
CREATE TABLE reservation_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    edition_id INT NOT NULL,
    listing_id INT DEFAULT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_items_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE RESTRICT,
    CONSTRAINT fk_items_listing FOREIGN KEY (listing_id) REFERENCES used_listings(listing_id) ON DELETE RESTRICT,
    CONSTRAINT ck_items_price CHECK (unit_price > 0)
) ENGINE=InnoDB;

-- 14. transactions (D7 Transaction Ledger, append-only; see triggers below)
-- payment         = wallet payment (bkash/nagad)
-- cash_settlement = cash collected at pickup
-- payout/commission rows reference listing_id (seller = used_listings.seller_id)
CREATE TABLE transactions (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT DEFAULT NULL,
    listing_id INT DEFAULT NULL,
    txn_type ENUM('payment', 'cash_settlement', 'refund', 'commission', 'payout') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tx_reservation FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE RESTRICT,
    CONSTRAINT fk_tx_listing FOREIGN KEY (listing_id) REFERENCES used_listings(listing_id) ON DELETE RESTRICT,
    CONSTRAINT ck_tx_amount CHECK (amount > 0),
    CONSTRAINT ck_tx_link CHECK (reservation_id IS NOT NULL OR listing_id IS NOT NULL)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Ledger immutability. Single-statement triggers: no DELIMITER needed,
-- so this file also runs through PyMySQL and test scripts.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_transactions_no_update BEFORE UPDATE ON transactions
FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Ledger is immutable: UPDATE on transactions is not allowed.';

CREATE TRIGGER trg_transactions_no_delete BEFORE DELETE ON transactions
FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Ledger is immutable: DELETE on transactions is not allowed.';