# Database Normalization Documentation
**Course:** BIC3203 Business Case Project  
**System:** CampusPages  
**Scope:** Relational Normalization Analysis (1NF through 3NF with Controlled 2NF Exception)  

---

## 1. Unnormalized Form (UNF)
In its raw state, textbook reservations, course syllabus mandates, inventory tracking, and student account data exist as a flat, unnormalized record containing repeating groups and duplicated operational data:

$$\text{UNF}(\underline{\text{ReservationID}}, \text{StudentID}, \text{StudentName}, \text{StudentEmail}, \text{ProgrammeCode}, \text{CourseCode}, \text{CourseTitle}, \{\text{BookTitle}, \text{Author}, \text{EditionNo}, \text{ISBN}, \text{Price}, \text{CopyType}, \text{ListingID}\}, \text{PaymentMethod}, \text{QRToken})$$

### Anomalies Inherent in UNF:
* **Insertion Anomaly:** A new course textbook or syllabus cannot be registered without an enrolled student placing an active reservation.
* **Update Anomaly:** Updating the retail price or author of a textbook requires editing every historical reservation row where that book appears.
* **Deletion Anomaly:** Cancelling or deleting an inactive reservation permanently wipes the record of the course syllabus and textbook edition from the system.

---

## 2. First Normal Form (1NF)
**Rule:** Eliminate repeating groups; ensure all column values are atomic; establish a defined primary key.

The nested array of reserved books within each reservation order is flattened into distinct rows identified by a composite key $(\text{reservation\_id}, \text{edition\_id})$:

$$\text{RESERVATION\_FLAT}(\underline{\text{reservation\_id}}, \underline{\text{edition\_id}}, \text{student\_id}, \text{student\_no}, \text{full\_name}, \text{email}, \text{programme\_code}, \text{course\_code}, \text{course\_title}, \text{book\_title}, \text{author}, \text{edition\_no}, \text{isbn}, \text{unit\_price}, \text{listing\_id}, \text{payment\_method}, \text{qr\_token})$$

---

## 3. Second Normal Form (2NF)
**Rule:** Must be in 1NF; eliminate partial functional dependencies where non-key attributes depend on only part of a composite primary key.

In `RESERVATION\_FLAT`, attributes such as `book_title`, `author`, `edition_no`, `isbn`, and base catalog pricing depend solely on `edition_id`, rather than the composite key $(\text{reservation\_id}, \text{edition\_id})$.

### Decomposition:
1. **`reservations`** ($\underline{\text{reservation\_id}}$, $\text{student\_id}$, $\text{status}$, $\text{payment\_method}$, $\text{qr\_token}$)
2. **`reservation_items`** ($\underline{\text{item\_id}}$, $\text{reservation\_id}$, $\text{edition\_id}$, $\text{listing\_id}$, $\text{unit\_price}$)
   * *Architectural Note on `unit_price`:* The `unit_price` in `reservation_items` is a deliberate historical price snapshot captured at the exact moment of reservation. It preserves transactional financial accuracy against subsequent catalog or used-listing price revisions.
3. **`editions`** ($\underline{\text{edition\_id}}$, $\text{book\_id}$, $\text{edition\_no}$, $\text{isbn}$, $\text{new\_price}$)

---

## 4. Third Normal Form (3NF) & Controlled Exceptions
**Rule:** Must be in 2NF; eliminate transitive functional dependencies (where a non-key attribute depends on another non-key attribute: $X \rightarrow Y \rightarrow Z$).

### Transitive Dependencies Resolved:
* **Programmes & Courses:** $\text{course\_id} \rightarrow \text{programme\_id} \rightarrow \text{code}, \text{name}$.  
  * *Resolution:* Separated into `programmes` ($\underline{\text{programme\_id}}$, $\text{code}$, $\text{name}$) and `courses` ($\underline{\text{course\_id}}$, $\text{programme\_id}$, $\text{course\_code}$, $\text{title}$, $\text{semester\_no}$).
* **Titles & Physical Editions:** $\text{edition\_id} \rightarrow \text{book\_id} \rightarrow \text{title}, \text{author}$.  
  * *Resolution:* Separated into conceptual entity `books` ($\underline{\text{book\_id}}$, $\text{title}$, $\text{author}$) and physical edition entity `editions` ($\underline{\text{edition\_id}}$, $\text{book\_id}$, $\text{edition\_no}$, $\text{isbn}$, $\text{new\_price}$).
* **User Accounts & Programmes:** $\text{user\_id} \rightarrow \text{programme\_id} \rightarrow \text{programme\_name}$.  
  * *Resolution:* `users` stores foreign key `programme_id` referencing `programmes`, eliminating repeated degree names.
* **P2P Resale & Bookstore Stock Isolation:** Dynamic peer-to-peer listings (`used_listings`) and new inventory on hand (`stock`) are decoupled from catalog editions into distinct entities to accommodate unique operational lifecycles (inspection, condition grading, and allocation holds).

---

## 5. Controlled 2NF Exception: `course_books` Table

The table `course_books` possesses a composite primary key:

$$\text{PK} = (\text{course\_id}, \text{edition\_id}, \text{term})$$

### Academic Analysis of Dependency:
* The attribute `expected_enrolment` is functionally determined by the course and academic term alone:
  $$\{\text{course\_id}, \text{term}\} \rightarrow \text{expected\_enrolment}$$
* Because `expected_enrolment` does not depend on the third component of the primary key (`edition_id`), this represents a formal **partial dependency (a 2NF violation)**.

### Engineering & Academic Justification:
A purist 3NF decomposition would split this relationship into an auxiliary table:
* `course_terms` ($\underline{\text{course\_id}}$, $\underline{\text{term}}$, $\text{expected\_enrolment}$)
* `course_term_books` ($\underline{\text{course\_id}}$, $\underline{\text{term}}$, $\underline{\text{edition\_id}}$, $\text{is\_required}$)

To maintain architectural cohesion, adhere to the 14-table system specification, and minimize relational JOIN overhead during real-time student bundle queries, `expected_enrolment` is deliberately co-located within `course_books`. Because UCSI courses predominantly mandate a single primary textbook per term, redundancy risk is controlled while query latency across the catalog remains minimized.