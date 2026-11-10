-- =====================================================================
-- CampusPages Seed Data (run AFTER schema.sql)
-- Demo login for ALL accounts: Password123!   (hashes verified with Werkzeug)
-- Complete Curricular Catalogue: 18 Undergraduate Programmes & Courses with Credits
-- =====================================================================

USE campuspages_db;

-- ---------------------------------------------------------------------
-- 1. programmes (D2 Academic Catalogue - All 18 Degree Programmes)
-- ---------------------------------------------------------------------
INSERT INTO programmes (programme_id, code, name) VALUES
(1,  'BCS',     'Bachelor of Computer Science (Honours)'),
(2,  'BAI',     'Bachelor of Computer Science in Artificial Intelligence with Honours'),
(3,  'BCY',     'Bachelor of Computer Science in Cyber Security with Honours'),
(4,  'BDS',     'Bachelor of Computer Science in Data Science with Honours'),
(5,  'BIS',     'BSc (Hons) Business Information Systems'),
(6,  'BMCN',    'Bachelor of Computer Science (Hons) Mobile Computing and Networking'),
(7,  'BBA',     'Bachelor of Arts (Hons) in Business Administration'),
(8,  'BAF',     'Bachelor of Arts (Hons) Accounting and Finance'),
(9,  'BMK',     'Bachelor of Arts (Hons) in Marketing'),
(10, 'BBA-BA',  'Bachelor of Arts (Hons) in Branding and Advertising'),
(11, 'BSCOM',   'Bachelor of Arts (Honours) Supply Chain Operations Management'),
(12, 'BFI',     'Bachelor of Science (Honours) Finance and Investment'),
(13, 'BHA',     'Bachelor of Hospitality Administration'),
(14, 'BPS',     'BA (Hons) Psychology'),
(15, 'BMC',     'BA (Hons) Mass Communication'),
(16, 'BELC',    'BA (Hons) English Language & Communication'),
(17, 'BGD',     'BA (Hons) Graphic Design'),
(18, 'BFDM',    'BA (Hons) Fashion Design with Marketing');

-- ---------------------------------------------------------------------
-- 2. forecast_params (D3 Syllabus & Forecast Parameters)
-- ---------------------------------------------------------------------
INSERT INTO forecast_params (programme_id, buy_rate, buffer) VALUES
(1,  0.650, 5),
(2,  0.650, 5),
(3,  0.650, 5),
(4,  0.650, 5),
(5,  0.600, 4),
(6,  0.600, 4),
(7,  0.700, 6),
(8,  0.700, 6),
(9,  0.650, 5),
(10, 0.650, 5),
(11, 0.650, 5),
(12, 0.700, 6),
(13, 0.600, 4),
(14, 0.600, 4),
(15, 0.600, 4),
(16, 0.600, 4),
(17, 0.600, 4),
(18, 0.600, 4);

-- ---------------------------------------------------------------------
-- 3. users (D1 User Accounts)
-- Plaintext login: Password123!
-- ---------------------------------------------------------------------
INSERT INTO users (user_id, email, password_hash, full_name, role, student_no, programme_id, current_semester) VALUES
(1, 'owner@campuspages.test', 'scrypt:32768:8:1$c0cLaOJ6fOXTMLky$4adf564c4b94d7cabc7ac2579924c7cdb8999f134e2eebfb34254bb3081b4f20917ff7fa882e5af67b3660648d5dcad2a0c85e5bc1d356723b2b790854d46d3d', 'Campus Store Admin', 'owner', NULL, NULL, NULL),
(2, 'instructor@campuspages.test', 'scrypt:32768:8:1$CAxuu3QWIAAkaugx$67664b0805fac8a7f9e62c44169fc8c828b654ba1dc74ddb9ad6c48b507dd9d1e7b5cf86896cebb5de98757a901bb4a2c0c06a776a4efe034fd4aca3514e0256', 'Dr. Syllabus Instructor', 'instructor', NULL, NULL, NULL),
(3, 'student1@campuspages.test', 'scrypt:32768:8:1$hkwH1k9qecwTUTDf$5f7535b8bfc47cc103b1d21b127426dfcd145bb3e28d4a881d1beae329fbc84c8b292c2321067ba2661efc069a66a2b69aaddb9f0f98b2c376081a3f72aa201e', 'Senior Resale Student', 'student', 'STU2024001', 1, 4),
(4, 'student2@campuspages.test', 'scrypt:32768:8:1$Gzae18CtsGes3JZe$ccddfaaccfcf7c627dd90594a1177948d65077e18058e80664ddb1b752ae77e44f7302c1879db1f53d5f6d7632ad5eaa9fe71d26ecc3f669b57e534ae3e31e7b', 'Junior Enrolled Student', 'student', 'STU2025002', 1, 2);

-- ---------------------------------------------------------------------
-- 4. courses (D2 Academic Catalogue - All Programmes with Credits & Semesters)
-- Format: (course_id, programme_id, course_code, title, semester_no, credits)
-- ---------------------------------------------------------------------
INSERT INTO courses (course_id, programme_id, course_code, title, semester_no, credits) VALUES
-- Test Baseline Anchor Courses (Preserving relational FK integrity for Course Books 1-4)
(1,  1, 'BIC3203',  'Business Case Project', 8, 3),
(2,  1, 'BIC2104',  'Data Structures and Algorithms', 4, 4),
(3,  1, 'BIC2102',  'Database Management Systems', 2, 4),
(4,  5, 'BIT1101',  'Introduction to Networking', 1, 3),

-- BCS: Bachelor of Computer Science (Honours) [Programme 1]
(5,  1, 'BIC1114',  'Introduction to Programming', 1, 4),
(6,  1, 'BIC1123',  'Discrete Mathematics', 1, 3),
(7,  1, 'BIC1134',  'Computer Organisation and Architecture', 1, 4),
(8,  1, 'MPU3113',  'Philosophy and Contemporary Issues', 1, 3),
(9,  1, 'BIC1224',  'Object-Oriented Programming', 2, 4),
(10, 1, 'BIC1234',  'Introduction to Internet Technologies', 2, 4),
(11, 1, 'MPU3221',  'University Life', 2, 1),
(12, 1, 'BIC1214',  'Object-Oriented Analysis and Design', 3, 4),
(13, 1, 'BIC1243',  'Database Administration', 3, 3),
(14, 1, 'BIC1993',  'Co-Operative Placement 1', 3, 3),
(15, 1, 'BIC1233',  'Introduction to Human Computer Interaction', 4, 3),
(16, 1, 'BIC2134',  'Operating Systems', 4, 4),
(17, 1, 'BIC2123',  'Database Design', 4, 3),
(18, 1, 'BIC2253',  'Networking', 5, 3),
(19, 1, 'BIC2113',  'Research Methods in Computing', 5, 3),
(20, 1, 'BIC2263',  'Software Project Management', 5, 3),
(21, 1, 'BIB3103',  'Mobile Commerce', 5, 3),
(22, 1, 'BIC2234',  'Multimedia Programming', 6, 4),
(23, 1, 'BIC2283',  'Business System Development Tools', 6, 3),
(24, 1, 'BIC3113',  'Cloud Computing', 6, 3),
(25, 1, 'BIC2323',  'Database Technology', 6, 3),
(26, 1, 'BIC2993',  'Co-Operative Placement 2', 6, 3),
(27, 1, 'BIC3124',  'Programming for Computer Science', 7, 4),
(28, 1, 'BIC3203M', 'Object-Oriented Methods', 7, 3),
(29, 1, 'BIC3143',  'Project Formulation', 7, 3),
(30, 1, 'BIC3163',  'Application Layer Programming', 7, 3),
(31, 1, 'BIC3223',  'Network Security Design', 8, 3),
(32, 1, 'BIC3233',  'Intelligent Systems', 8, 3),
(33, 1, 'BIC3254',  'Web Programming', 8, 4),
(34, 1, 'BIC3246',  'Project Design and Implementation', 9, 6),
(35, 1, 'BIC3993',  'Co-Operative Placement 3', 9, 3),

-- BAI: Bachelor of Computer Science in Artificial Intelligence [Programme 2]
(36, 2, 'BAI1113',  'Mathematics 1 for AI (Linear Algebra)', 1, 3),
(37, 2, 'BIC1114',  'Introduction to Programming', 1, 4),
(38, 2, 'BIC1123',  'Discrete Mathematics', 1, 3),
(39, 2, 'BIC1134',  'Computer Organisation and Architecture', 1, 4),
(40, 2, 'BIC1144',  'Database Management Systems', 2, 4),
(41, 2, 'BIC1224',  'Object-Oriented Programming', 2, 4),
(42, 2, 'BIC1234',  'Introduction to Internet Technologies', 2, 4),
(43, 2, 'BIC2323',  'Database Technology', 3, 3),
(44, 2, 'BIC2263',  'Software Project Management', 3, 3),
(45, 2, 'BIC1993',  'Co-Operative Placement 1', 3, 3),
(46, 2, 'BIC2214',  'Data Structures and Algorithms', 4, 4),
(47, 2, 'BIC2123',  'Database Design', 4, 3),
(48, 2, 'BIC2134',  'Operating Systems', 4, 4),
(49, 2, 'BAI2113',  'Mathematics 2 for AI (Calculus)', 4, 3),
(50, 2, 'BIC3124',  'Programming for Computer Science', 5, 4),
(51, 2, 'BIC1233',  'Introduction to Human Computer Interaction', 5, 3),
(52, 2, 'BAI2124',  'Machine Learning', 5, 4),
(53, 2, 'BAI2133',  'Ethics in AI', 5, 3),
(54, 2, 'BIC3113',  'Cloud Computing', 6, 3),
(55, 2, 'BIC3254',  'Web Programming', 6, 4),
(56, 2, 'BAI2213',  'Natural Language Processing', 6, 3),
(57, 2, 'BAI2223',  'Recommender Systems', 6, 3),
(58, 2, 'BIC2253',  'Networking', 6, 3),
(59, 2, 'BIC2993',  'Co-Operative Placement 2', 6, 3),
(60, 2, 'BAI3113',  'Fuzzy System and Evolutionary Computing', 7, 3),
(61, 2, 'BIC3143',  'Project Formulation', 7, 3),
(62, 2, 'BIC3163',  'Application Layer Programming', 7, 3),
(63, 2, 'BAI3123',  'Knowledge Representation and Reasoning', 7, 3),
(64, 2, 'BAI3213',  'Image Processing', 8, 3),
(65, 2, 'BIC3183',  'Information Systems Risk and Security', 8, 3),
(66, 2, 'BIC3233',  'Intelligent Systems', 8, 3),
(67, 2, 'BIC3246',  'Project Design and Implementation', 8, 6),
(68, 2, 'BIC3993',  'Co-Operative Placement 3', 9, 3),

-- BCY: Bachelor of Computer Science in Cyber Security [Programme 3]
(69, 3, 'BCY1113',  'Computer Security', 1, 3),
(70, 3, 'BIC1114',  'Introduction to Programming', 1, 4),
(71, 3, 'BIC1123',  'Discrete Mathematics', 1, 3),
(72, 3, 'BIC1134',  'Computer Organisation and Architecture', 1, 4),
(73, 3, 'BIC1224',  'Object-Oriented Programming', 2, 4),
(74, 3, 'BCY1213',  'Mathematics for Cyber Security', 2, 3),
(75, 3, 'BIC1234',  'Introduction to Internet Technologies', 2, 4),
(76, 3, 'BIC3113',  'Cloud Computing', 3, 3),
(77, 3, 'BIC1144',  'Database Management Systems', 3, 4),
(78, 3, 'BIC1993',  'Co-Operative Placement 1', 3, 3),
(79, 3, 'BIC2214',  'Data Structures and Algorithms', 4, 4),
(80, 3, 'BIC1233',  'Introduction to Human Computer Interaction', 4, 3),
(81, 3, 'BIC2134',  'Operating Systems', 4, 4),
(82, 3, 'BCY2113',  'Security Management', 4, 3),
(83, 3, 'BCY2123',  'Introduction to Cryptography', 5, 3),
(84, 3, 'BCY2133',  'Software Security', 5, 3),
(85, 3, 'BIB2014',  'System Analysis and Design', 5, 4),
(86, 3, 'BIC2253',  'Networking', 5, 3),
(87, 3, 'BIC2113',  'Research Methods in Computing', 6, 3),
(88, 3, 'BIC2123',  'Database Design', 6, 3),
(89, 3, 'BIC2263',  'Software Project Management', 6, 3),
(90, 3, 'BIC2993',  'Co-Operative Placement 2', 6, 3),
(91, 3, 'BIC3183',  'Information Systems Risk and Security', 7, 3),
(92, 3, 'BIC3143',  'Project Formulation', 7, 3),
(93, 3, 'BIC3163',  'Application Layer Programming', 7, 3),
(94, 3, 'BCY3113',  'Network Security', 7, 3),
(95, 3, 'BIC3223',  'Network Security Design', 8, 3),
(96, 3, 'BIC3233',  'Intelligent Systems', 8, 3),
(97, 3, 'BCY3213',  'Computer Forensics', 8, 3),
(98, 3, 'BCY3223',  'E-Commerce Security', 8, 3),
(99, 3, 'BIC3246',  'Project Design and Implementation', 9, 6),
(100, 3, 'BIC3993', 'Co-Operative Placement 3', 9, 3),

-- BDS: Bachelor of Computer Science in Data Science [Programme 4]
(101, 4, 'BIC1114', 'Introduction to Programming', 1, 4),
(102, 4, 'BIC1123', 'Discrete Mathematics', 1, 3),
(103, 4, 'BIC1134', 'Computer Organisation and Architecture', 1, 4),
(104, 4, 'BBS1063', 'Statistics and its Applications', 1, 3),
(105, 4, 'BIC1144', 'Database Management Systems', 2, 4),
(106, 4, 'BIC1214', 'Object-Oriented Analysis and Design', 2, 4),
(107, 4, 'BIC1224', 'Object-Oriented Programming', 2, 4),
(108, 4, 'BIC1233', 'Introduction to Human Computer Interaction', 3, 3),
(109, 4, 'BIC1254', 'Fundamentals of Data Science', 3, 4),
(110, 4, 'BIC1993', 'Co-Operative Placement 1', 3, 3),
(111, 4, 'BIC2114', 'Introduction to Cybersecurity', 4, 4),
(112, 4, 'BIC2123', 'Database Design', 4, 3),
(113, 4, 'BIC2134', 'Operating Systems', 4, 4),
(114, 4, 'BDS2113', 'Information Management for Data Science', 4, 3),
(115, 4, 'BIC2214', 'Data Structures and Algorithms', 5, 4),
(116, 4, 'BIC2224', 'Information and Network Security', 5, 4),
(117, 4, 'BER2033', 'Artificial Intelligence', 5, 3),
(118, 4, 'BDS2123', 'Data Mining', 5, 3),
(119, 4, 'BDS2213', 'Research Method for Data Science', 6, 3),
(120, 4, 'BDS2223', 'Statistics for Data Science', 6, 3),
(121, 4, 'BBB1013', 'Business Communication', 6, 3),
(122, 4, 'BBB1043', 'Fundamentals of Management', 6, 3),
(123, 4, 'BIC2993', 'Co-Operative Placement 2', 6, 3),
(124, 4, 'BBB3013', 'Entrepreneurship', 7, 3),
(125, 4, 'BIC3113', 'Cloud Computing', 7, 3),
(126, 4, 'BDS3113', 'Big Data', 7, 3),
(127, 4, 'BBM1023', 'Digital Marketing', 7, 3),
(128, 4, 'BDS3123', 'Independent Project 1', 7, 3),
(129, 4, 'BDS3214', 'Machine Learning for Data Science', 8, 4),
(130, 4, 'BDS3223', 'Business Analytics', 8, 3),
(131, 4, 'BBB3033', 'Strategic Management', 8, 3),
(132, 4, 'BDS3233', 'Independent Project 2', 8, 3),
(133, 4, 'BIC3993', 'Co-Operative Placement 3', 9, 3),

-- BIS: BSc (Hons) Business Information Systems [Programme 5]
(134, 5, 'BBA1093', 'Business Accounting', 1, 3),
(135, 5, 'BBB1013', 'Business Communication', 1, 3),
(136, 5, 'BBB1023', 'Microeconomics', 1, 3),
(137, 5, 'BIC1234', 'Introduction to Internet Technologies', 1, 4),
(138, 5, 'BBS1063', 'Statistics and its Applications', 2, 3),
(139, 5, 'BBB1033', 'Macroeconomics', 2, 3),
(140, 5, 'BIB1013', 'Concept of Analysis and Design', 2, 3),
(141, 5, 'BIB1024', 'Java Programming 1', 2, 4),
(142, 5, 'BBM1013', 'Fundamentals of Marketing', 3, 3),
(143, 5, 'BBB1043', 'Fundamentals of Management', 3, 3),
(144, 5, 'BIB1993', 'Co-Operative Placement 1', 3, 3),
(145, 5, 'BIB2014', 'Analysis and Design', 4, 4),
(146, 5, 'BIB2024', 'Java Programming 2', 4, 4),
(147, 5, 'BIB2034', 'Visual Basic .NET', 4, 4),
(148, 5, 'BIC2134', 'Operating Systems', 4, 4),
(149, 5, 'BIC2113', 'Research Methods in Computing', 5, 3),
(150, 5, 'BIC1144', 'Database Systems', 5, 4),
(151, 5, 'BIC2253', 'Networking', 5, 3),
(152, 5, 'BIC2234', 'Multimedia Programming', 5, 4),
(153, 5, 'BIB2104', 'Creative Problem Solving', 6, 4),
(154, 5, 'BIC2263', 'Software Project Management', 6, 3),
(155, 5, 'BIB2993', 'Co-Operative Placement 2', 6, 3),
(156, 5, 'BBB3023', 'International Business', 7, 3),
(157, 5, 'BIB2304', 'Issues in Database Design', 7, 4),
(158, 5, 'BIB3203', 'Technopreneurship', 7, 3),
(159, 5, 'BIB3113', 'Independent Project 1 for BIS', 7, 3),
(160, 5, 'BBB3033', 'Strategic Management', 8, 3),
(161, 5, 'BBB2073', 'E-Commerce', 8, 3),
(162, 5, 'BIB3213', 'Management and Information Systems', 8, 3),
(163, 5, 'BIB3223', 'Independent Project 2 for BIS', 8, 3),
(164, 5, 'BIB3993', 'Co-Operative Placement 3', 9, 3),

-- BBA: Bachelor of Arts (Hons) in Business Administration [Programme 7]
(165, 7, 'BBA1093', 'Business Accounting', 1, 3),
(166, 7, 'BBB1013', 'Business Communication', 1, 3),
(167, 7, 'BBB1023', 'Microeconomics', 1, 3),
(168, 7, 'BBB1043', 'Fundamentals of Management', 1, 3),
(169, 7, 'BBB1063', 'Business Information Systems', 2, 3),
(170, 7, 'BBS1063', 'Statistics and its Applications', 2, 3),
(171, 7, 'BBB1033', 'Macroeconomics', 2, 3),
(172, 7, 'BBB1053', 'Organisational Behaviour', 2, 3),
(173, 7, 'BBM1013', 'Fundamentals of Marketing', 3, 3),
(174, 7, 'BBB1093', 'Business Law', 3, 3),
(175, 7, 'KAD1041', 'Co-Operative Placement 1', 3, 3),
(176, 7, 'BBB2013', 'Company Law', 4, 3),
(177, 7, 'BBS2303', 'Business Mathematics', 4, 3),
(178, 7, 'BB203',   'Business Modelling with Spreadsheet', 4, 3),
(179, 7, 'BBB2043', 'Business Research Methods', 4, 3),
(180, 7, 'BBB2023', 'Managing People', 5, 3),
(181, 7, 'BBB2033', 'Corporate Communication', 5, 3),
(182, 7, 'BBA2223', 'Financial Management', 5, 3),
(183, 7, 'BBA2213', 'Managerial Accounting', 5, 3),
(184, 7, 'BB218',   'Internet in Practice', 6, 3),
(185, 7, 'BBB2053', 'Management Ethics', 6, 3),
(186, 7, 'KAD1042', 'Co-Operative Placement 2', 6, 3),
(187, 7, 'BBA2103', 'Corporate Finance', 7, 3),
(188, 7, 'BBB3053', 'Contemporary Human Resource Management', 7, 3),
(189, 7, 'BBB3073', 'Final Project A', 7, 3),
(190, 7, 'BBB3023', 'International Business', 7, 3),
(191, 7, 'BBB3043', 'Organisational Development and Change', 8, 3),
(192, 7, 'BBB3083', 'Strategic Information Systems Management', 8, 3),
(193, 7, 'BBB3033', 'Strategic Management', 8, 3),
(194, 7, 'BBB3103', 'Issues in Business', 8, 3),
(195, 7, 'BBB3093', 'Final Project B', 9, 3),
(196, 7, 'BBB3013', 'Entrepreneurship', 9, 3),
(197, 7, 'BBM3083', 'Retail Marketing', 9, 3),
(198, 7, 'BBM3063', 'Services Marketing', 9, 3),
(199, 7, 'KAD1043', 'Co-Operative Placement 3', 9, 3),

-- BAF: Bachelor of Arts (Hons) Accounting and Finance [Programme 8]
(200, 8, 'BBB1023', 'Microeconomics', 1, 3),
(201, 8, 'BBA1013', 'Introductory Accounting', 1, 3),
(202, 8, 'BBS1063', 'Statistics and its Application', 1, 3),
(203, 8, 'BA105',   'Financial Markets and Institutions', 1, 3),
(204, 8, 'BBB1013', 'Business Communication', 2, 3),
(205, 8, 'BBB1063', 'Business Information System', 2, 3),
(206, 8, 'BA210',   'Financial Reporting Standards', 2, 3),
(207, 8, 'BBB1033', 'Macroeconomics', 2, 3),
(208, 8, 'BBA1703', 'Introduction to Management Accounting', 3, 3),
(209, 8, 'BBB1093', 'Business Law', 3, 3),
(210, 8, 'KAD1061', 'Co-Operative Placement 1', 3, 3),
(211, 8, 'BBB2013', 'Company Law', 4, 3),
(212, 8, 'BA214',   'Corporate Accounts', 4, 3),
(213, 8, 'BBA2044', 'Accounting Information System', 4, 4),
(214, 8, 'BBA2443', 'Capital Financing and Investment', 4, 3),
(215, 8, 'BBS2293', 'Management Science', 5, 3),
(216, 8, 'BBA2413', 'Intermediate Management Accounting', 5, 3),
(217, 8, 'BBB2043', 'Business Research Method', 5, 3),
(218, 8, 'BBA2204', 'Corporate Governance, Risk and Professional Ethics', 6, 4),
(219, 8, 'BBA2103', 'Corporate Finance', 6, 3),
(220, 8, 'BA202',   'Auditing 1', 6, 3),
(221, 8, 'KAD1062', 'Co-Operative Placement 2', 6, 3),
(222, 8, 'BBB3033', 'Strategic Management', 7, 3),
(223, 8, 'BBA2163', 'Investment Analysis', 7, 3),
(224, 8, 'BBA2173', 'Equity Analysis', 7, 3),
(225, 8, 'BA309',   'Financial Research Project A', 7, 3),
(226, 8, 'BA312',   'Advanced Corporate Accounts', 7, 3),
(227, 8, 'BBA3153', 'Multinational Finance', 8, 3),
(228, 8, 'BBA3264', 'Advanced Financial Management', 8, 4),
(229, 8, 'BA310',   'Financial Research Project B', 8, 3),
(230, 8, 'BA313',   'Advanced Management Accounting', 8, 3),
(231, 8, 'BBA3044', 'Integrated Case-Study', 9, 4),
(232, 8, 'BBA3193', 'Risk Management and Insurance', 9, 3),
(233, 8, 'KAD1063', 'Co-Operative Placement 3', 9, 3),

-- BHA: Bachelor of Hospitality Administration [Programme 13]
(234, 13, 'BHH1014', 'Basic Food Preparation', 1, 4),
(235, 13, 'BHH1023', 'Customer Service', 1, 3),
(236, 13, 'BHH1033', 'Sanitation, Safety and Hygiene', 1, 3),
(237, 13, 'BBB1013', 'Business Communication', 1, 3),
(238, 13, 'BHH1053', 'Fundamentals of Hospitality and Tourism Industry', 2, 3),
(239, 13, 'BHH1064', 'Food and Beverage Service', 2, 4),
(240, 13, 'BHH1073', 'Food and Beverage Management', 2, 3),
(241, 13, 'BHH1083', 'Housekeeping Management', 2, 3),
(242, 13, 'BHH1093', 'Front Office Operation and Management', 3, 3),
(243, 13, 'BHH1103', 'Introduction to Hospitality Accounting', 3, 3),
(244, 13, 'BHH1113', 'Cross Cultural Studies', 3, 3),
(245, 13, 'BHH1163', 'Foreign Language in Hospitality', 3, 3),
(246, 13, 'BHH2016', 'Industry Placement I', 4, 6),
(247, 13, 'BHH2024', 'Commercial Cookery', 5, 4),
(248, 13, 'BHH2033', 'Introduction to Management and Organisation Theory', 5, 3),
(249, 13, 'BHH2043', 'Principles of Marketing', 5, 3),
(250, 13, 'BHH2053', 'Human Resource Management', 5, 3),
(251, 13, 'BHH2063', 'Hospitality and Tourism Law', 6, 3),
(252, 13, 'BHH2073', 'Business Research Methods', 6, 3),
(253, 13, 'BHH2083', 'Food and Beverage and Labour Cost Control', 6, 3),
(254, 13, 'BHH2093', 'Independent Project I', 6, 3),
(255, 13, 'BHH3033', 'Tourism Planning, Development and Management', 7, 3),
(256, 13, 'BHH3043', 'Tourism and Business of Hotels', 7, 3),
(257, 13, 'BHH3053', 'Introduction to Wine and Bar', 7, 3),
(258, 13, 'BHH3063', 'Leadership and Business Performance', 7, 3),
(259, 13, 'BHH3074', 'Event Operation Management', 8, 4),
(260, 13, 'BHH3083', 'Casino, Club and Resort Management', 8, 3),
(261, 13, 'BHH3093', 'Hospitality Facilities Management and Design', 8, 3),
(262, 13, 'BHH3103', 'Hospitality Revenue Management', 8, 3),
(263, 13, 'BHH3013', 'Consumer Behaviour', 9, 3),
(264, 13, 'BHH3023', 'Hospitality and Tourism Strategic Management', 9, 3),
(265, 13, 'BHH3113', 'Independent Project II', 9, 3),
(266, 13, 'BHH3126', 'Industry Placement II', 9, 6),

-- BPS: BA (Hons) Psychology [Programme 14]
(267, 14, 'SP121',  'Introduction to Psychology', 1, 3),
(268, 14, 'SP122',  'Positive Psychology', 1, 3),
(269, 14, 'SP110',  'Statistics for Psychology', 1, 3),
(270, 14, 'SL110',  'Critical Issues in the Contemporary World', 1, 3),
(271, 14, 'SP202',  'Lifespan Development', 2, 3),
(272, 14, 'SP105',  'Social Psychology', 2, 3),
(273, 14, 'SL112',  'Persuasive Speech', 2, 3),
(274, 14, 'SL113',  'Thinking and Being', 2, 3),
(275, 14, 'SP199',  'Co-Operative Placement 1', 3, 3),
(276, 14, 'SP111',  'Psychological Research Methods 1', 4, 3),
(277, 14, 'SP213',  'Psychological Research Methods 2', 4, 3),
(278, 14, 'SP203',  'Neuropsychology', 4, 3),
(279, 14, 'SP201',  'Cognitive Psychology', 4, 3),
(280, 14, 'SP205',  'Personality Theories', 5, 3),
(281, 14, 'SP308',  'Psychological Testing and Assessment', 5, 3),
(282, 14, 'SP332',  'Counselling Theories and Techniques', 5, 3),
(283, 14, 'SP204',  'Educational Psychology', 5, 3),
(284, 14, 'SP208',  'Health Psychology', 6, 3),
(285, 14, 'SP107',  'Human Sexuality', 6, 3),
(286, 14, 'SP224',  'Sport Psychology', 6, 3),
(287, 14, 'SP299',  'Co-Operative Placement 2', 6, 3),
(288, 14, 'SP306',  'Industrial and Organisational Psychology', 7, 3),
(289, 14, 'SP301',  'Abnormal Psychology', 7, 3),
(290, 14, 'SP311',  'Independent Project A', 7, 3),
(291, 14, 'SP303',  'Philosophical Issues in Psychology', 7, 3),
(292, 14, 'SP304',  'Ethics and Professional Issues in Psychology', 8, 3),
(293, 14, 'SP305',  'Cross-Cultural Psychology', 8, 3),
(294, 14, 'SP312',  'Independent Project B', 8, 3),
(295, 14, 'SP307',  'Entrepreneurial Psychology', 8, 3),
(296, 14, 'SP309',  'Professional Development in Psychology', 9, 3),
(297, 14, 'SP399',  'Co-Operative Placement 3', 9, 3),

-- BMC: BA (Hons) Mass Communication [Programme 15]
(298, 15, 'SM101',  'Introduction to Mass Communication', 1, 3),
(299, 15, 'SM103',  'Basic Photography', 1, 3),
(300, 15, 'SM110',  'Visual Communication', 1, 3),
(301, 15, 'SM104',  'Introduction to Public Speaking', 1, 3),
(302, 15, 'SM105',  'Introduction to Video Production', 2, 3),
(303, 15, 'BBB1043','Fundamentals of Management', 2, 3),
(304, 15, 'SM115',  'Writing for Mass Communication', 2, 3),
(305, 15, 'SM106',  'Film Studies', 2, 3),
(306, 15, 'SM108',  'Introduction to Public Relations', 3, 3),
(307, 15, 'SM113',  'Introduction to Journalism', 3, 3),
(308, 15, 'SM199',  'Co-Operative Placement 1', 3, 3),
(309, 15, 'SM222',  'Creative Content Development', 4, 3),
(310, 15, 'SM347',  'Mass Communication Research 1', 4, 3),
(311, 15, 'SM218',  'Design and Thinking', 4, 3),
(312, 15, 'SM221',  'New Media Studies', 4, 3),
(313, 15, 'SM220',  'Creative Copywriting', 5, 3),
(314, 15, 'SM207',  'Pop Culture', 5, 3),
(315, 15, 'SM210',  'Alternative Voices and Issues in Mass Communication', 5, 3),
(316, 15, 'SM299',  'Co-Operative Placement 2', 6, 3),
(317, 15, 'SM301',  'Media, Law and Ethics', 7, 3),
(318, 15, 'BBB3013','Entrepreneurship', 7, 3),
(319, 15, 'SM302',  'Mass Communication Project', 7, 3),
(320, 15, 'SM348',  'Mass Communication Research 2', 8, 3),
(321, 15, 'SM310',  'Integrated Marketing Communication Campaign', 8, 4),
(322, 15, 'SM399',  'Co-Operative Placement 3', 9, 3),

-- BGD: BA (Hons) Graphic Design [Programme 17]
(323, 17, 'DA101',  'Art History', 1, 3),
(324, 17, 'DA102',  'Life Drawing', 1, 3),
(325, 17, 'BGD101', 'Graphic and Image Editing', 1, 3),
(326, 17, 'BGD102', 'Packaging and Display Design', 1, 3),
(327, 17, 'SM110',  'Visual Communication', 2, 3),
(328, 17, 'BGD104', 'Typography 1', 2, 3),
(329, 17, 'SM103',  'Basic Photography', 2, 3),
(330, 17, 'BGD103', 'Brand Design and Campaign', 2, 3),
(331, 17, 'BMM101', 'Introduction to Multimedia', 3, 3),
(332, 17, 'BGD201', 'Design and Layout', 4, 3),
(333, 17, 'BGD202', 'Typography 2', 4, 3),
(334, 17, 'BMM202', 'Web Design', 4, 3),
(335, 17, 'BGD203', 'Information and Environmental Design', 4, 3),
(336, 17, 'BMM201', 'Multimedia Design 1', 5, 3),
(337, 17, 'BGD204', 'Design for Industry', 5, 3),
(338, 17, 'BGD205', 'Proposal Writing', 5, 3),
(339, 17, 'BGD206', 'Digital Visual Presentation', 5, 3),
(340, 17, 'BGD207', 'Practical Training', 6, 3),
(341, 17, 'DA308',  'Post-Production', 6, 3),
(342, 17, 'BMM301', 'Multimedia Design 2', 7, 3),
(343, 17, 'BGD301', 'Design Major Project 1', 7, 3),
(344, 17, 'BGD303', 'Research Project', 7, 3),
(345, 17, 'BGD304', 'Intellectual Properties', 8, 3),
(346, 17, 'BGD305', 'Portfolio', 8, 3),
(347, 17, 'BGD302', 'Design Major Project 2', 8, 3),
(348, 17, 'BGD306', 'Industry Placement', 9, 6),

-- BFDM: BA (Hons) Fashion Design with Marketing [Programme 18]
(349, 18, 'BFD101', 'Fashion Illustration and Design Communication', 1, 3),
(350, 18, 'BFD102', 'Garment Construction and Fashion Sewing', 1, 3),
(351, 18, 'DA101',  'Art History', 1, 3),
(352, 18, 'SM110',  'Visual Communication', 1, 3),
(353, 18, 'DA102',  'Life Drawing', 2, 3),
(354, 18, 'FD106',  'Integrated Marketing Communication in Fashion', 2, 3),
(355, 18, 'FD105',  'History of Fashion', 2, 3),
(356, 18, 'BFD103', 'Creative Cutting', 2, 3),
(357, 18, 'BFD104', 'Design Development and Portfolio', 3, 3),
(358, 18, 'BBB1043','Fundamentals of Management', 3, 3),
(359, 18, 'BBM1013','Fundamentals of Marketing', 3, 3),
(360, 18, 'BFD199', 'Co-Operative Placement 1', 3, 3),
(361, 18, 'BFD201', 'Customer Communication', 4, 3),
(362, 18, 'BFD202', 'Fabric and Functions', 4, 3),
(363, 18, 'BFD203', 'Industry Brief 1 - Production and Realisation', 4, 3),
(364, 18, 'BFD204', 'Industry Brief 1 - Research and Design Presentation', 4, 3),
(365, 18, 'BB203',  'Business Modeling with Spreadsheet', 5, 3),
(366, 18, 'BBB3013','Entrepreneurship', 5, 3),
(367, 18, 'BFD205', 'Industry Brief 2 - Production and Realisation', 5, 3),
(368, 18, 'BFD206', 'Industry Brief 2 - Research and Design Presentation', 5, 3),
(369, 18, 'BFD208', 'Sculpting with Fabric', 6, 3),
(370, 18, 'BFD207', 'Fashion Retailing', 6, 3),
(371, 18, 'BFD299', 'Co-Operative Placement 2', 6, 3),
(372, 18, 'BFD301', 'Industrial Design and Manufacture', 7, 3),
(373, 18, 'BFD302', 'Final Major Project - Research and Rationale', 7, 3),
(374, 18, 'BFD303', 'Men\'s Wear - Tailoring Manufacture and Styling', 7, 3),
(375, 18, 'BFD304', 'Fashion Show Production', 8, 3),
(376, 18, 'BFD305', 'Corsetry Construction Techniques', 8, 3),
(377, 18, 'BFD306', 'Final Major Project - Portfolio and Dissertation', 8, 3),
(378, 18, 'BFD307', 'Final Major Project - Realisation and Manufacture', 9, 4),
(379, 18, 'BFD399', 'Co-Operative Placement 3', 9, 3);

-- ---------------------------------------------------------------------
-- 5. books (D2 Academic Catalogue)
-- ---------------------------------------------------------------------
INSERT INTO books (book_id, title, author) VALUES
(1, 'Systems Analysis and Design', 'Kendall & Kendall'),
(2, 'Data Structures and Algorithm Analysis in Java', 'Mark Allen Weiss'),
(3, 'Database System Concepts', 'Silberschatz, Korth & Sudarshan'),
(4, 'Computer Networking: A Top-Down Approach', 'Kurose & Ross');

-- ---------------------------------------------------------------------
-- 6. editions (D2 Academic Catalogue)
-- ---------------------------------------------------------------------
INSERT INTO editions (edition_id, book_id, isbn, edition_no, new_price) VALUES
(1, 1, '978-0134785554', '10th Global Edition', 1850.00),
(2, 2, '978-0132576277', '3rd Edition', 1600.00),
(3, 3, '978-0078022159', '7th Edition', 2100.00),
(4, 4, '978-0136681557', '8th Edition', 2400.00);

-- ---------------------------------------------------------------------
-- 7. course_books (D3 Syllabus & Forecast Parameters)
-- ---------------------------------------------------------------------
INSERT INTO course_books (course_id, edition_id, term, expected_enrolment, is_required, confirmed_by, confirmed_at) VALUES
(1, 1, 'September 2026', 45, TRUE, 2, '2026-09-01 10:00:00'),
(2, 2, 'September 2026', 60, TRUE, 2, '2026-09-01 10:00:00'),
(3, 3, 'September 2026', 55, TRUE, 2, '2026-09-01 10:00:00'),
(4, 4, 'September 2026', 40, TRUE, 2, '2026-09-01 10:00:00');

-- ---------------------------------------------------------------------
-- 8. stock (D4 Stock)
-- ---------------------------------------------------------------------
INSERT INTO stock (edition_id, qty_new, qty_reserved) VALUES
(1, 15, 1),
(2, 10, 1),
(3, 6,  0),
(4, 0,  0);

-- ---------------------------------------------------------------------
-- 9. used_listings (D5 Used Listings)
-- ---------------------------------------------------------------------
INSERT INTO used_listings (listing_id, seller_id, edition_id, declared_condition, condition_grade, asking_price, approved_price, status) VALUES
(1, 3, 2, 'good', 'good',     1000.00, 950.00,  'available'),
(2, 3, 3, 'good', 'like_new', 1400.00, 1300.00, 'reserved'),
(3, 3, 1, 'fair', NULL,       900.00,  NULL,    'pending_inspection');

-- ---------------------------------------------------------------------
-- 10. reservations (D6 Reservations)
-- ---------------------------------------------------------------------
INSERT INTO reservations (reservation_id, student_id, status, payment_method, qr_token, created_at) VALUES
(1, 4, 'unpaid_reserved', 'cash',  'oGoqycNl5zbLiPk9oCswKEZC7AelYNvJ', '2026-10-15 14:30:00'),
(2, 4, 'paid_reserved',   'bkash', 'i1Hf9yiN_THXEYhhM8wdeP5tf9rTLUh9', '2026-10-16 11:15:00');

-- ---------------------------------------------------------------------
-- 11. reservation_items (D6 Reservations)
-- ---------------------------------------------------------------------
INSERT INTO reservation_items (item_id, reservation_id, edition_id, listing_id, unit_price) VALUES
(1, 1, 1, NULL, 1850.00),
(2, 1, 2, NULL, 1600.00),
(3, 2, 3, 2,    1300.00);

-- ---------------------------------------------------------------------
-- 12. waitlist (D6 Reservations)
-- ---------------------------------------------------------------------
INSERT INTO waitlist (waitlist_id, student_id, edition_id, joined_at, notified_at) VALUES
(1, 4, 4, '2026-10-14 09:20:00', NULL);

-- ---------------------------------------------------------------------
-- 13. transactions (D7 Transaction Ledger)
-- ---------------------------------------------------------------------
INSERT INTO transactions (txn_id, reservation_id, listing_id, txn_type, amount, created_at) VALUES
(1, 2, NULL, 'payment', 1300.00, '2026-10-16 11:15:00');

-- ---------------------------------------------------------------------
-- 14. notifications (D8 Notifications)
-- ---------------------------------------------------------------------
INSERT INTO notifications (notification_id, user_id, message, is_read, created_at) VALUES
(1, 4, 'Your reservation is confirmed. Show your QR slip at the pickup desk.', FALSE, '2026-10-15 14:30:00'),
(2, 3, 'Your used book listing for Data Structures and Algorithm Analysis in Java is verified and now available.', TRUE, '2026-10-15 16:00:00');