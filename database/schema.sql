-- CampusPages Database Schema (3NF)
-- Aligned with ERD, DFD Level 0, and System Architecture
-- Target DBMS: MySQL Community Server 8.0+

DROP DATABASE IF EXISTS campuspages_db;
CREATE DATABASE campuspages_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE campuspages_db;

-- 1. Programmes Table (D2 Academic Catalogue)
CREATE TABLE programmes (
    programme_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL
) ENGINE=InnoDB;

-- 2. Forecast Parameters Table (D3 Syllabus & Forecast Parameters)
-- Scoped directly to Programme per ERD
CREATE TABLE forecast_params (
    programme_id INT PRIMARY KEY,
    buy_rate DECIMAL(4, 3) NOT NULL DEFAULT 0.650,
    buffer INT NOT NULL DEFAULT 5,
    CONSTRAINT fk_forecast_programme FOREIGN KEY (programme_id) REFERENCES programmes(programme_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. Users Table (D1 User Accounts)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('student', 'instructor', 'owner') NOT NULL,
    student_no VARCHAR(50) UNIQUE DEFAULT NULL,
    programme_id INT DEFAULT NULL,
    current_semester INT DEFAULT NULL,
    CONSTRAINT fk_users_programme FOREIGN KEY (programme_id) REFERENCES programmes(programme_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 4. Courses Table (D2 Academic Catalogue)
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    programme_id INT NOT NULL,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    semester_no INT NOT NULL,
    CONSTRAINT fk_courses_programme FOREIGN KEY (programme_id) REFERENCES programmes(programme_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. Books Table (D2 Academic Catalogue)
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL
) ENGINE=InnoDB;

-- 6. Editions Table (D2 Academic Catalogue)
CREATE TABLE editions (
    edition_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    isbn VARCHAR(20) UNIQUE DEFAULT NULL,
    edition_no VARCHAR(50) NOT NULL,
    new_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_editions_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. Course Books Table (D3 Syllabus & Forecast Parameters)
-- Composite Primary Key: (course_id, edition_id, term)
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
    CONSTRAINT fk_cb_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE,
    CONSTRAINT fk_cb_confirmed_by FOREIGN KEY (confirmed_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 8. Stock Table (D4 Stock)
-- 1:1 identifying relationship with editions table
CREATE TABLE stock (
    edition_id INT PRIMARY KEY,
    qty_new INT NOT NULL DEFAULT 0,
    qty_reserved INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_stock_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 9. Used Listings Table (D5 Used Listings)
CREATE TABLE used_listings (
    listing_id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    edition_id INT NOT NULL,
    declared_condition ENUM('like_new', 'good', 'fair') NOT NULL,
    condition_grade ENUM('like_new', 'good', 'fair') DEFAULT NULL,
    asking_price DECIMAL(10, 2) NOT NULL,
    approved_price DECIMAL(10, 2) DEFAULT NULL,
    status ENUM('pending_inspection', 'available', 'reserved', 'sold', 'paid_out') NOT NULL DEFAULT 'pending_inspection',
    CONSTRAINT fk_used_seller FOREIGN KEY (seller_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_used_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 10. Waitlist Table (D6 Reservations & Queues)
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

-- 11. Notifications Table (D8 Notifications)
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 12. Reservations Table (D6 Reservations)
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    status ENUM('unpaid_reserved', 'paid_reserved', 'completed', 'cancelled') NOT NULL DEFAULT 'unpaid_reserved',
    payment_method ENUM('cash', 'bkash', 'nagad') NOT NULL,
    qr_token VARCHAR(64) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_res_student FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 13. Reservation Items Table (D6 Reservations)
CREATE TABLE reservation_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    edition_id INT NOT NULL,
    listing_id INT DEFAULT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_items_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_listing FOREIGN KEY (listing_id) REFERENCES used_listings(listing_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 14. Transactions Table (D7 Transaction Ledger)
CREATE TABLE transactions (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT DEFAULT NULL,
    listing_id INT DEFAULT NULL,
    txn_type ENUM('payment', 'refund', 'commission', 'payout') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tx_reservation FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE SET NULL,
    CONSTRAINT fk_tx_listing FOREIGN KEY (listing_id) REFERENCES used_listings(listing_id) ON DELETE SET NULL
) ENGINE=InnoDB;