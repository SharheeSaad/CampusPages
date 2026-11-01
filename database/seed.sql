-- =====================================================================
-- CampusPages Seed Data (run AFTER schema.sql)
-- Demo login for ALL accounts: Password123!   (hashes verified with Werkzeug)
-- Data rules satisfied:
--   * student_no/programme_id only on role='student'
--   * stock.qty_reserved = number of NEW copies held by open reservations
--   * used listing 2 is 'reserved' because reservation 2 holds it
--   * waitlist is for edition 4, which has 0 copies in stock
-- =====================================================================

USE campuspages_db;

-- 1. programmes
INSERT INTO programmes (programme_id, code, name) VALUES
(1, 'BCS', 'BSc (Hons) Computer Science'),
(2, 'BIT', 'Bachelor of Information Technology'),
(3, 'BBA', 'Bachelor of Business Administration');

-- 2. forecast_params
INSERT INTO forecast_params (programme_id, buy_rate, buffer) VALUES
(1, 0.650, 5),
(2, 0.600, 4),
(3, 0.700, 6);

-- 3. users
INSERT INTO users (user_id, email, password_hash, full_name, role, student_no, programme_id, current_semester) VALUES
(1, 'owner@campuspages.test', 'scrypt:32768:8:1$c0cLaOJ6fOXTMLky$4adf564c4b94d7cabc7ac2579924c7cdb8999f134e2eebfb34254bb3081b4f20917ff7fa882e5af67b3660648d5dcad2a0c85e5bc1d356723b2b790854d46d3d', 'Campus Store Admin', 'owner', NULL, NULL, NULL),
(2, 'instructor@campuspages.test', 'scrypt:32768:8:1$CAxuu3QWIAAkaugx$67664b0805fac8a7f9e62c44169fc8c828b654ba1dc74ddb9ad6c48b507dd9d1e7b5cf86896cebb5de98757a901bb4a2c0c06a776a4efe034fd4aca3514e0256', 'Dr. Syllabus Instructor', 'instructor', NULL, NULL, NULL),
(3, 'student1@campuspages.test', 'scrypt:32768:8:1$hkwH1k9qecwTUTDf$5f7535b8bfc47cc103b1d21b127426dfcd145bb3e28d4a881d1beae329fbc84c8b292c2321067ba2661efc069a66a2b69aaddb9f0f98b2c376081a3f72aa201e', 'Senior Resale Student', 'student', 'STU2024001', 1, 4),
(4, 'student2@campuspages.test', 'scrypt:32768:8:1$Gzae18CtsGes3JZe$ccddfaaccfcf7c627dd90594a1177948d65077e18058e80664ddb1b752ae77e44f7302c1879db1f53d5f6d7632ad5eaa9fe71d26ecc3f669b57e534ae3e31e7b', 'Junior Enrolled Student', 'student', 'STU2025002', 1, 2);

-- 4. courses
INSERT INTO courses (course_id, programme_id, course_code, title, semester_no) VALUES
(1, 1, 'BIC3203', 'Business Case Project', 4),
(2, 1, 'BIC2104', 'Data Structures and Algorithms', 3),
(3, 1, 'BIC2102', 'Database Management Systems', 3),
(4, 2, 'BIT1101', 'Introduction to Networking', 1);

-- 5. books
INSERT INTO books (book_id, title, author) VALUES
(1, 'Systems Analysis and Design', 'Kendall & Kendall'),
(2, 'Data Structures and Algorithm Analysis in Java', 'Mark Allen Weiss'),
(3, 'Database System Concepts', 'Silberschatz, Korth & Sudarshan'),
(4, 'Computer Networking: A Top-Down Approach', 'Kurose & Ross');

-- 6. editions (verify ISBNs against the real books before the final demo)
INSERT INTO editions (edition_id, book_id, isbn, edition_no, new_price) VALUES
(1, 1, '978-0134785554', '10th Global Edition', 1850.00),
(2, 2, '978-0132576277', '3rd Edition', 1600.00),
(3, 3, '978-0078022159', '7th Edition', 2100.00),
(4, 4, '978-0136681557', '8th Edition', 2400.00);

-- 7. course_books
INSERT INTO course_books (course_id, edition_id, term, expected_enrolment, is_required, confirmed_by, confirmed_at) VALUES
(1, 1, 'September 2026', 45, TRUE, 2, '2026-09-01 10:00:00'),
(2, 2, 'September 2026', 60, TRUE, 2, '2026-09-01 10:00:00'),
(3, 3, 'September 2026', 55, TRUE, 2, '2026-09-01 10:00:00'),
(4, 4, 'September 2026', 40, TRUE, 2, '2026-09-01 10:00:00');

-- 8. stock (qty_new = on hand, qty_reserved = held for open reservations)
INSERT INTO stock (edition_id, qty_new, qty_reserved) VALUES
(1, 15, 1),
(2, 10, 1),
(3, 6, 0),
(4, 0, 0);

-- 9. used_listings (all sold by user 3, the senior student)
INSERT INTO used_listings (listing_id, seller_id, edition_id, declared_condition, condition_grade, asking_price, approved_price, status) VALUES
(1, 3, 2, 'good', 'good', 1000.00, 950.00, 'available'),
(2, 3, 3, 'good', 'like_new', 1400.00, 1300.00, 'reserved'),
(3, 3, 1, 'fair', NULL, 900.00, NULL, 'pending_inspection');

-- 10. reservations (QR tokens are random, as the app will generate them)
INSERT INTO reservations (reservation_id, student_id, status, payment_method, qr_token, created_at) VALUES
(1, 4, 'unpaid_reserved', 'cash', 'oGoqycNl5zbLiPk9oCswKEZC7AelYNvJ', '2026-10-15 14:30:00'),
(2, 4, 'paid_reserved', 'bkash', 'i1Hf9yiN_THXEYhhM8wdeP5tf9rTLUh9', '2026-10-16 11:15:00');

-- 11. reservation_items (listing_id NULL = new copy)
INSERT INTO reservation_items (item_id, reservation_id, edition_id, listing_id, unit_price) VALUES
(1, 1, 1, NULL, 1850.00),
(2, 1, 2, NULL, 1600.00),
(3, 2, 3, 2, 1300.00);

-- 12. waitlist (edition 4 is out of stock)
INSERT INTO waitlist (waitlist_id, student_id, edition_id, joined_at, notified_at) VALUES
(1, 4, 4, '2026-10-14 09:20:00', NULL);

-- 13. transactions (ledger is append-only: no UPDATE/DELETE after insert)
INSERT INTO transactions (txn_id, reservation_id, listing_id, txn_type, amount, created_at) VALUES
(1, 2, NULL, 'payment', 1300.00, '2026-10-16 11:15:00');

-- 14. notifications
INSERT INTO notifications (notification_id, user_id, message, is_read, created_at) VALUES
(1, 4, 'Your reservation is confirmed. Show your QR slip at the pickup desk.', FALSE, '2026-10-15 14:30:00'),
(2, 3, 'Your used book listing for Data Structures and Algorithm Analysis in Java is verified and now available.', TRUE, '2026-10-15 16:00:00');