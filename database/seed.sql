-- CampusPages Seed Data (Aligned with ERD & 3NF Schema)
-- Target DBMS: MySQL Community Server 8.0+ / SQLite compatible

USE campuspages_db;

-- 1. Programmes (D2 Academic Catalogue)
INSERT INTO programmes (programme_id, code, name) VALUES
(1, 'BCS', 'BSc (Hons) Computer Science'),
(2, 'BIT', 'Bachelor of Information Technology'),
(3, 'BBA', 'Bachelor of Business Administration');

-- 2. Forecast Parameters (D3 Syllabus & Forecast Parameters)
-- Scoped directly to Programme per ERD
INSERT INTO forecast_params (programme_id, buy_rate, buffer) VALUES
(1, 0.650, 5),
(2, 0.600, 4),
(3, 0.700, 6);

-- 3. Users (D1 User Accounts)
-- Plaintext password for all seeded users is: Password123!
INSERT INTO users (user_id, email, password_hash, full_name, role, student_no, programme_id, current_semester) VALUES
(1, 'sharhee@ucsiuniversity.edu.my', 'scrypt:32768:8:1$u7zQ9wX2y1$c7c64be7c51cb5cf216e9fbb5333f0249219bfe9d9d4439c3e2300b9736c1e13788ff3f1c8ce073286f9ad72b78ce13db1403e1cb992770335e9d997235b6b85', 'Sharhee Saad Imam', 'owner', '1702400203', 1, 4),
(2, 'rokeya@ucsiuniversity.edu.my', 'scrypt:32768:8:1$u7zQ9wX2y1$c7c64be7c51cb5cf216e9fbb5333f0249219bfe9d9d4439c3e2300b9736c1e13788ff3f1c8ce073286f9ad72b78ce13db1403e1cb992770335e9d997235b6b85', 'Rokeya Akanda Sriti', 'instructor', 'FAC001', 1, NULL),
(3, 'amaan@ucsiuniversity.edu.my', 'scrypt:32768:8:1$u7zQ9wX2y1$c7c64be7c51cb5cf216e9fbb5333f0249219bfe9d9d4439c3e2300b9736c1e13788ff3f1c8ce073286f9ad72b78ce13db1403e1cb992770335e9d997235b6b85', 'Amaan Ahmad', 'student', '1702300064', 1, 4),
(4, 'aminur@ucsiuniversity.edu.my', 'scrypt:32768:8:1$u7zQ9wX2y1$c7c64be7c51cb5cf216e9fbb5333f0249219bfe9d9d4439c3e2300b9736c1e13788ff3f1c8ce073286f9ad72b78ce13db1403e1cb992770335e9d997235b6b85', 'Md. Aminur Rahman Eusha', 'student', '1702400154', 1, 4);

-- 4. Courses (D2 Academic Catalogue)
INSERT INTO courses (course_id, programme_id, course_code, title, semester_no) VALUES
(1, 1, 'BIC3203', 'Business Case Project', 4),
(2, 1, 'BIC2104', 'Data Structures and Algorithms', 3),
(3, 1, 'BIC2102', 'Database Management Systems', 3),
(4, 2, 'BIT1101', 'Introduction to Networking', 1);

-- 5. Books (D2 Academic Catalogue)
INSERT INTO books (book_id, title, author) VALUES
(1, 'Systems Analysis and Design', 'Kendall & Kendall'),
(2, 'Data Structures and Algorithm Analysis in Java', 'Mark Allen Weiss'),
(3, 'Database System Concepts', 'Silberschatz, Korth & Sudarshan'),
(4, 'Computer Networking: A Top-Down Approach', 'Kurose & Ross');

-- 6. Editions (D2 Academic Catalogue)
INSERT INTO editions (edition_id, book_id, isbn, edition_no, new_price) VALUES
(1, 1, '978-0134785554', '10th Global Edition', 1850.00),
(2, 2, '978-0132576277', '3rd Edition', 1600.00),
(3, 3, '978-0078022159', '7th Edition', 2100.00),
(4, 4, '978-0136681557', '8th Edition', 2400.00);

-- 7. Course Books (D3 Syllabus & Forecast Parameters)
-- Composite PK: (course_id, edition_id, term)
INSERT INTO course_books (course_id, edition_id, term, expected_enrolment, is_required, confirmed_by, confirmed_at) VALUES
(1, 1, 'September 2026', 45, TRUE, 2, '2026-09-01 10:00:00'),
(2, 2, 'September 2026', 60, TRUE, 2, '2026-09-01 10:00:00'),
(3, 3, 'September 2026', 55, TRUE, 2, '2026-09-01 10:00:00'),
(4, 4, 'September 2026', 40, TRUE, 2, '2026-09-01 10:00:00');

-- 8. Stock (D4 Stock)
-- 1:1