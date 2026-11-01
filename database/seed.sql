-- CampusPages Seed Data
-- Target DBMS: MySQL Community Server 8.0+ / SQLite compatible

USE campuspages_db;

-- 1. Programmes
INSERT INTO programmes (programme_id, name, code) VALUES
(1, 'BSc (Hons) Computer Science', 'BCS'),
(2, 'Bachelor of Information Technology', 'BIT'),
(3, 'Bachelor of Business Administration', 'BBA');

-- 2. Users (Passwords hashed via Werkzeug PBKDF2:sha256 - plaintext is 'Password123!')
INSERT INTO users (user_id, name, email, password_hash, role, student_id, programme_id, current_semester) VALUES
(1, 'Sharhee Saad Imam', 'sharhee@ucsiuniversity.edu.my', 'scrypt:32768:8:1$u7zQ9wX2y1$c7c64be7c51cb5cf216e9fbb5333f0249219bfe9d9d4439c3e2300b9736c1e13788ff3f1c8ce073286f9ad72b78ce13db1403e1cb992770335e9d997235b6b85', 'owner', '1702400203', 1, 4),
(2, 'Rokeya Akanda Sriti', 'rokeya@ucsiuniversity.edu.my', 'scrypt:32768:8:1$u7zQ9wX2y1$c7c64be7c51cb5cf216e9fbb5333f0249219bfe9d9d4439c3e2300b9736c1e13788ff3f1c8ce073286f9ad72b78ce13db1403e1cb992770335e9d997235b6b85', 'instructor', 'FAC001', 1, NULL),
(3, 'Amaan Ahmad', 'amaan@ucsiuniversity.edu.my', 'scrypt:32768:8:1$u7zQ9wX2y1$c7c64be7c51cb5cf216e9fbb5333f0249219bfe9d9d4439c3e2300b9736c1e13788ff3f1c8ce073286f9ad72b78ce13db1403e1cb992770335e9d997235b6b85', 'student', '1702300064', 1, 4),
(4, 'Md. Aminur Rahman Eusha', 'aminur@ucsiuniversity.edu.my', 'scrypt:32768:8:1$u7zQ9wX2y1$c7c64be7c51cb5cf216e9fbb5333f0249219bfe9d9d4439c3e2300b9736c1e13788ff3f1c8ce073286f9ad72b78ce13db1403e1cb992770335e9d997235b6b85', 'student', '1702400154', 1, 4);

-- 3. Courses
INSERT INTO courses (course_id, code, title, programme_id, semester_no) VALUES
(1, 'BIC3203', 'Business Case Project', 1, 4),
(2, 'BIC2104', 'Data Structures and Algorithms', 1, 3),
(3, 'BIC2102', 'Database Management Systems', 1, 3),
(4, 'BIT1101', 'Introduction to Networking', 2, 1);

-- 4. Books
INSERT INTO books (book_id, title, author) VALUES
(1, 'Systems Analysis and Design', 'Kendall & Kendall'),
(2, 'Data Structures and Algorithm Analysis in Java', 'Mark Allen Weiss'),
(3, 'Database System Concepts', 'Silberschatz, Korth & Sudarshan'),
(4, 'Computer Networking: A Top-Down Approach', 'Kurose & Ross');

-- 5. Editions
INSERT INTO editions (edition_id, book_id, edition_label, isbn, publication_year, new_price) VALUES
(1, 1, '10th Global Edition', '978-0134785554', 2020, 1850.00),
(2, 2, '3rd Edition', '978-0132576277', 2012, 1600.00),
(3, 3, '7th Edition', '978-0078022159', 2019, 2100.00),
(4, 4, '8th Edition', '978-0136681557', 2021, 2400.00);

-- 6. Course Books (Syllabus Linkage & Projected Enrolment)
INSERT INTO course_books (course_book_id, course_id, edition_id, term, expected_enrolment) VALUES
(1, 1, 1, 'September 2026', 45),
(2, 2, 2, 'September 2026', 60),
(3, 3, 3, 'September 2026', 55),
(4, 4, 4, 'September 2026', 40);

-- 7. Initial New Stock
INSERT INTO stock (stock_id, edition_id, qty_new, reorder_level) VALUES
(1, 1, 18, 5),
(2, 2, 12, 5),
(3, 3, 8, 5),
(4, 4, 15, 5);

-- 8. Used Listings (Senior Sell-Back)
INSERT INTO used_listings (listing_id, seller_id, edition_id, condition_grade, price, status) VALUES
(1, 3, 2, 'good', 950.00, 'available'),
(2, 4, 3, 'like_new', 1300.00, 'available'),
(3, 3, 1, 'fair', 900.00, 'pending_inspection');

-- 9. Forecast Parameters (Calibrated from Survey Baseline)
INSERT INTO forecast_params (param_id, course_id, buy_rate, buffer, source) VALUES
(1, 1, 0.700, 5, 'survey'),
(2, 2, 0.650, 6, 'survey'),
(3, 3, 0.600, 5, 'estimate'),
(4, 4, 0.750, 4, 'estimate');