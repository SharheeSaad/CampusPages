# Software Requirements Specification (SRS)
## CampusPages: Demand-Driven Course Book Supply & Peer Resale Platform
**Authors:** Sharhee Saad Imam, Amaan Ahmad, Md. Aminur Rahman Eusha  
**Document Version:** 1.0.0  
**Date:** October 2026  

---

## 1. Introduction

### 1.1 Purpose
This Software Requirements Specification (SRS) defines the complete functional and non-functional requirements for **CampusPages**. It specifies the system behavior, interaction flows, data integrity constraints, and role permissions for student book procurement, instructor syllabus verification, and inventory demand forecasting[cite: 17, 18].

### 1.2 Scope of the System
CampusPages is an on-campus academic web platform connecting four major stakeholder workflows[cite: 17]:
1. **Enrolled Students:** Catalog browsing, single-step semester bundle reservations and peer-to-peer used book reservations[cite: 17, 18].
2. **Senior Students (Sellers):** Listing completed course books for verified intake and resale[cite: 17, 18].
3. **Course Instructors:** Formally validating required textbook editions and submitting expected course enrolments[cite: 17, 18].
4. **Platform Owner / Store Administrator:** Algorithmic demand forecasting, physical condition grading, QR pickup settlement and financial payout tracking[cite: 17, 18].

The academic prototype delivers a functional web application with a simulated payment gateway and sample catalog data[cite: 17, 18]. Full physical store fit-outs and external banking merchant integrations are outside the academic prototype scope[cite: 17].

### 1.3 Definitions, Acronyms, and Abbreviations
* **SRS:** Software Requirements Specification[cite: 4]
* **FR:** Functional Requirement
* **NFR:** Non-Functional Requirement[cite: 4]
* **UC:** Use Case
* **RBAC:** Role-Based Access Control[cite: 18]
* **P2P:** Peer-to-Peer[cite: 17]
* **ISBN:** International Standard Book Number
* **QR Code:** Quick Response 2D Barcode[cite: 18]

---

## 2. Overall Description

### 2.1 Product Perspective
CampusPages functions as an independent, centralized web application supporting campus retail operations[cite: 17]. It bridges academic syllabus planning with direct student demand, eliminating guesswork in wholesale inventory procurement while providing a structured circular economy for used textbooks[cite: 17].

### 2.2 User Classes and Characteristics
* **Student (Buyer/User):** Can register, browse books by semester/programme, reserve bundles, place deposits, track pickup status, and join waitlists[cite: 18].
* **Senior Student (Seller):** Can submit listings of used course books with edition and condition declarations[cite: 17, 18].
* **Course Instructor:** Authenticated faculty member authorized to submit and lock course syllabi, set textbook edition mandates, and input projected enrolment figures[cite: 17, 18].
* **Store Owner / Admin:** Administrative user responsible for grading physical book condition, executing demand forecasts, scanning pickup QR codes, receiving payments, and managing vendor/seller payouts[cite: 17, 18].

### 2.3 Operating Environment
* **Platform:** Web application accessible across modern web browsers (Chrome, Firefox, Safari, Edge)[cite: 5].
* **Server Environment:** Python 3.11+ running Flask 3.0[cite: 18].
* **Database Management System:** MySQL Server 8.0 Community Edition[cite: 18].
* **Client Architecture:** Responsive HTML5, CSS3, JavaScript, Bootstrap/custom styles, Chart.js for data visualization[cite: 17, 18].

### 2.4 Design and Implementation Constraints
* All persistent data must be normalized to Third Normal Form (3NF) across the designated 14 database tables[cite: 18].
* Passwords must be hashed using industry-standard hashing algorithms (Werkzeug security / bcrypt)[cite: 18].
* Payment workflows within the prototype are simulated via mobile-wallet (bKash/Nagad) confirmation tokens and do not connect to external production APIs[cite: 17, 18].

---

## 3. Specific System Features & Functional Requirements

The following requirements map directly to the master traceability chain (`FR-01` to `FR-17`)[cite: 18].

### FR-01: User Authentication & Role-Based Access Control
* **Description:** The system shall authenticate users via email and password and enforce permissions based on roles (`student`, `instructor`, `owner`)[cite: 18].
* **Inputs:** Email address, password, full name, role selection, student/staff ID[cite: 18].
* **Processing:** Validate email uniqueness; verify password against hashed storage; assign session token and authorization scope[cite: 18].
* **Outputs:** User session redirecting to role-appropriate dashboard or an error message on invalid credentials.

### FR-02: Structured Academic Catalog Navigation
* **Description:** The system shall allow students to browse and filter book titles by Degree Programme, Semester Number, and Course Code[cite: 18].
* **Inputs:** Selected programme ID, semester index, or course code[cite: 18].
* **Processing:** Query `courses` and `course_books` joined with `books`, `editions`, and live `stock` levels[cite: 18].
* **Outputs:** Filtered view displaying book title, author, required edition, new copy price, used copy price, and real-time stock status (In Stock / Low Stock / Out of Stock)[cite: 9, 18].

### FR-03: Single-Step Semester Bundle Reservation
* **Description:** The system shall enable an enrolled student to reserve all mandatory course books for a selected semester in a single action[cite: 17, 18].
* **Inputs:** Student ID, selected Programme, and target Semester[cite: 18].
* **Processing:** Retrieve all active instructor-confirmed editions for the enrolled semester; verify stock availability; create a record in `reservations` and line entries in `reservation_items`; allocate stock[cite: 18].
* **Outputs:** Bundle reservation confirmation showing consolidated cost, pickup deadline, and reservation ID[cite: 18].

### FR-04: Automated Waiting List & Restock Notifications
* **Description:** If a course book or bundle item is out of stock, the system shall allow the student to join a prioritized waitlist and receive an automated alert when stock becomes available[cite: 17, 18].
* **Inputs:** Student ID, Edition ID[cite: 18].
* **Processing:** Record entry in `waitlist`; trigger notification generator upon subsequent stock increments (`stock.qty_new` or approved used listings)[cite: 18].
* **Outputs:** Waitlist confirmation badge and in-app restock message (`notifications.message`)[cite: 18].

### FR-05: Used-Book Sell-Back Submission
* **Description:** The system shall allow registered senior students to list used textbooks for resale against instructor-confirmed course editions[cite: 17, 18].
* **Inputs:** Seller ID, Course ID, Edition ID, declared condition (Good, Fair, Acceptable), asking price[cite: 18].
* **Processing:** Verify that the edition matches the course syllabus; insert listing into `used_listings` with status `pending_inspection`[cite: 17, 18].
* **Outputs:** Seller submission receipt with instruction to drop off the book at the campus pickup desk for physical verification[cite: 17, 18].

### FR-06: Used Copy Reservation
* **Description:** The system shall allow students to reserve verified used textbooks at a discounted rate alongside or instead of new copies[cite: 17, 18].
* **Inputs:** Student ID, Listing ID[cite: 18].
* **Processing:** Check `used_listings.status == 'available'`; change status atomically to `reserved`; attach listing ID to `reservation_items`[cite: 18].
* **Outputs:** Updated reservation showing discounted used copy price and condition grade[cite: 18].

### FR-07: Dual Payment Checkout Workflow
* **Description:** The system shall support both simulated mobile wallet payment (bKash/Nagad) and cash-on-pickup selection[cite: 17, 18].
* **Inputs:** Payment method (`bKash`, `Nagad`, `Cash`), simulated transaction number/PIN[cite: 17, 18].
* **Processing:** For mobile wallet, generate a simulated transaction reference and set reservation status to `paid_reserved`; for cash, set reservation status to `unpaid_reserved`; record entry in `transactions`[cite: 17, 18].
* **Outputs:** Payment receipt, recorded transaction ID, and final reservation confirmation[cite: 17, 18].

### FR-08: QR Code Pickup Slip Generation
* **Description:** The system shall generate a secure pickup slip featuring a scannable QR code for every confirmed reservation[cite: 17, 18].
* **Inputs:** Reservation ID, Student ID[cite: 18].
* **Processing:** Encode reservation ID, student ID, and verification pickup token into an alphanumeric string rendered as a 2D QR image using the QR service[cite: 18].
* **Outputs:** Printable/displayable digital pickup pass with dynamic QR code image[cite: 17, 18].

### FR-09: Reservation Cancellation & Automated Refund
* **Description:** The system shall allow students to cancel active reservations before collection, immediately releasing reserved stock and logging refunds[cite: 17, 18].
* **Inputs:** Reservation ID, cancellation reason[cite: 18].
* **Processing:** Change reservation status to `cancelled`; return physical inventory units to `stock` or set `used_listings.status` back to `available`; create a refund entry in `transactions` if prepaid[cite: 17, 18].
* **Outputs:** Cancellation confirmation and simulated refund acknowledgment[cite: 17, 18].

### FR-10: Academic Cohort Recommendations ("Students Also Reserved")
* **Description:** The system shall display recommended supplementary or co-reserved titles based on course co-enrollment patterns[cite: 17, 18].
* **Inputs:** Current Edition ID or Course Code[cite: 18].
* **Processing:** Query past `reservation_items` to identify titles most frequently co-reserved by students sharing the same course or programme cohort[cite: 18].
* **Outputs:** List of recommended complementary titles on the book detail screen[cite: 18].

### FR-11: Instructor Syllabus & Enrolment Submission
* **Description:** The system shall enable instructors to configure course syllabi by submitting approved book editions and estimated student enrolment[cite: 17, 18].
* **Inputs:** Instructor ID, Course Code, Edition ID/Details, Academic Term, Expected Enrolment count[cite: 18].
* **Processing:** Insert/update `course_books` record; stamp `confirmed_at` timestamp; flag edition as syllabus-verified[cite: 18].
* **Outputs:** Instructor syllabus submission confirmation and course readiness status[cite: 18].

### FR-12: Inventory & Catalog Administration
* **Description:** The system shall allow the store owner to add, edit, and deactivate books, editions, base pricing, and stock levels[cite: 18].
* **Inputs:** Title, Author, Edition label, ISBN, New Price, Quantity On Hand, Reorder Threshold[cite: 18].
* **Processing:** Write changes to `books`, `editions`, and `stock` tables[cite: 18].
* **Outputs:** Real-time catalog update and stock level confirmation[cite: 18].

### FR-13: Algorithmic Demand Forecasting & Reorder Engine
* **Description:** The system shall calculate an evidence-based suggested order quantity for each syllabus title to optimize inventory procurement[cite: 17, 18].
* **Inputs:** `course_books.expected_enrolment`, `forecast_params.buy_rate`, `forecast_params.buffer`, active used copy count, and current stock on hand[cite: 17, 18].
* **Processing:** Execute the standardized forecasting algorithm:
  $$\text{Suggested Order} = \left(\text{Enrolment} \times \text{Buy Rate} + \text{Safety Buffer}\right) - \text{Available Used Copies} - \text{Stock on Hand}$$
[cite: 17, 18]
  If the calculated value is less than zero, set suggested order to 0[cite: 17].
* **Outputs:** Reorder suggestion table displaying projected demand, existing inventory, and net purchase recommendation per title[cite: 17, 18].

### FR-14: Physical Used-Book Intake & Condition Grading
* **Description:** The system shall enable the owner to inspect dropped-off used books, assign an official condition grade, and approve them for public listing[cite: 17, 18].
* **Inputs:** Listing ID, physical condition verification (Like New, Good, Fair), adjusted price approval[cite: 18].
* **Processing:** Update `used_listings.condition_grade`, set `used_listings.status = 'available'`; notify seller of listing activation[cite: 18].
* **Outputs:** Verified used book made discoverable in the public catalog[cite: 18].

### FR-15: QR Code Pickup Verification & In-Person Settlement
* **Description:** The system shall decode pickup QR codes presented at the campus desk, confirm order validity, and record fulfillment[cite: 17, 18].
* **Inputs:** Scanned or entered QR verification string, cash collected confirmation (if applicable)[cite: 18].
* **Processing:** Validate reservation status; if unpaid, record cash settlement in `transactions`; change reservation status to `completed`; decrement stock units[cite: 18].
* **Outputs:** Pickup completion confirmation and updated inventory records[cite: 18].

### FR-16: Executive Analytics Dashboard
* **Description:** The system shall present dynamic visual metrics on inventory reorders, reservation volumes, and revenue distribution[cite: 18].
* **Inputs:** Date range, course/programme filters[cite: 18].
* **Processing:** Aggregate sales from `transactions`, count reservations by status from `reservations`, and identify low-stock items breaching reorder thresholds[cite: 18].
* **Outputs:** Visual charts (via Chart.js) showing reorder alerts, top reserved courses, and financial turnover[cite: 17, 18].

### FR-17: Financial Ledger & Peer Seller Payouts
* **Description:** The system shall maintain an immutable transaction ledger and calculate seller payout balances after deducting platform commission[cite: 17, 18].
* **Inputs:** Completed Listing ID, Seller ID, payout disbursement action[cite: 18].
* **Processing:** Calculate platform commission (e.g., 10%) and net seller payout (90%); record payout execution in `transactions`; update listing status to `paid_out`[cite: 17, 18].
* **Outputs:** Disbursed payout receipt and updated platform revenue ledger[cite: 18].

---

## 4. Non-Functional Requirements (NFR)

### 4.1 Performance Requirements
* **NFR-01 (Search Latency):** Catalog search and course book filtering queries shall execute within 1.0 second under a database load of up to 1,000 titles and 500 concurrent sessions[cite: 9, 18].
* **NFR-02 (Forecast Computation):** Demand forecast calculation for an entire degree programme cohort shall complete within 2.0 seconds[cite: 18].

### 4.2 Security Requirements
* **NFR-03 (Authentication Security):** All user passwords shall be hashed using SHA-256 with dynamic salts before storage; plaintext passwords shall never be recorded in logs or database tables[cite: 18].
* **NFR-04 (Role-Based Authorization):** Server-side route decorators shall enforce RBAC, ensuring student users cannot execute instructor or administrator endpoints[cite: 18].

### 4.3 Usability & Responsive Design
* **NFR-05 (Accessibility & Viewports):** The user interface shall provide responsive layouts adapted for mobile viewports (minimum 360px width) up to desktop displays (1920px width)[cite: 18].
* **NFR-06 (Reservation Efficiency):** The user journey for reserving a semester bundle shall require no more than three clicks from the student home screen[cite: 17, 18].

### 4.4 Data Integrity & Traceability
* **NFR-07 (Relational Integrity):** All relational foreign keys shall enforce referential integrity constraints to prevent orphaned reservation lines or orphaned course syllabi[cite: 4, 18].
* **NFR-08 (Traceability Alignment):** Every functional feature shall map directly to its corresponding ID in `traceability.csv`, DFD process number, and formal test cases[cite: 18].