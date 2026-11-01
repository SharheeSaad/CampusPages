-- CampusPages Database Schema (3NF)
-- Target DBMS: MySQL Community Server 8.0+
-- Course: BIC3203 Business Case Project

DROP DATABASE IF EXISTS campuspages_db;
CREATE DATABASE campuspages_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE campuspages_db;

-- 1. Programmes Table
CREATE TABLE programmes (
    programme_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    code VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Users Table (Supports RBAC: student, instructor, owner)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('student', 'instructor', 'owner') NOT NULL,
    student_id VARCHAR(50) DEFAULT NULL,
    programme_id INT DEFAULT NULL,
    current_semester INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_programme FOREIGN KEY (programme_id) REFERENCES programmes(programme_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 3. Courses Table
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    programme_id INT NOT NULL,
    semester_no INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_courses_programme FOREIGN KEY (programme_id) REFERENCES programmes(programme_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. Books Table (General Title Representation)
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 5. Editions Table (Specific Physical/Curricular Edition)
CREATE TABLE editions (
    edition_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    edition_label VARCHAR(50) NOT NULL,
    isbn VARCHAR(20) UNIQUE DEFAULT NULL,
    publication_year INT DEFAULT NULL,
    new_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_editions_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6. Course Books Table (Instructor-confirmed Syllabus Requirements)
CREATE TABLE course_books (
    course_book_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    edition_id INT NOT NULL,
    term VARCHAR(30) NOT NULL,
    expected_enrolment INT NOT NULL DEFAULT 0,
    confirmed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_course_edition_term (course_id, edition_id, term),
    CONSTRAINT fk_cb_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    CONSTRAINT fk_cb_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. Stock Table (Inventory for New Copies)
CREATE TABLE stock (
    stock_id INT AUTO_INCREMENT PRIMARY KEY,
    edition_id INT NOT NULL UNIQUE,
    qty_new INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 5,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_stock_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 8. Used Listings Table (Peer-to-Peer Resale Intake & Grading)
CREATE TABLE used_listings (
    listing_id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    edition_id INT NOT NULL,
    condition_grade ENUM('like_new', 'good', 'fair') DEFAULT NULL,
    price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending_inspection', 'available', 'reserved', 'sold', 'paid_out') NOT NULL DEFAULT 'pending_inspection',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_used_seller FOREIGN KEY (seller_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_used_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 9. Reservations Table (Master Order Record)
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    status ENUM('unpaid_reserved', 'paid_reserved', 'completed', 'cancelled') NOT NULL DEFAULT 'unpaid_reserved',
    payment_method ENUM('cash', 'bkash', 'nagad') NOT NULL,
    pickup_code VARCHAR(64) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_res_student FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 10. Reservation Items Table (Line Items: New vs Used)
CREATE TABLE reservation_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    edition_id INT NOT NULL,
    copy_type ENUM('new', 'used') NOT NULL,
    listing_id INT DEFAULT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_items_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_listing FOREIGN KEY (listing_id) REFERENCES used_listings(listing_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 11. Waitlist Table (Restock Notifications)
CREATE TABLE waitlist (
    waitlist_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    edition_id INT NOT NULL,
    notified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_student_edition_waitlist (student_id, edition_id),
    CONSTRAINT fk_waitlist_student FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_waitlist_edition FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 12. Transactions Table (Immutable Financial & Payout Ledger)
CREATE TABLE transactions (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT DEFAULT NULL,
    type ENUM('payment', 'refund', 'commission', 'payout') NOT NULL,
    method ENUM('cash', 'bkash', 'nagad') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'completed', 'failed') NOT NULL DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tx_reservation FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 13. Notifications Table (In-App Messaging)
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 14. Forecast Parameters Table (Demand Engine Calibration)
CREATE TABLE forecast_params (
    param_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL UNIQUE,
    buy_rate DECIMAL(4, 3) NOT NULL DEFAULT 0.650,
    buffer INT NOT NULL DEFAULT 5,
    source ENUM('survey', 'estimate') NOT NULL DEFAULT 'estimate',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_forecast_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
) ENGINE=InnoDB;