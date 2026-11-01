# Database Normalization Documentation
**Target:** Third Normal Form (3NF) Validation  
**System:** CampusPages  

---

## 1. Unnormalized Form (UNF)
The unnormalized state represents a flat transactional log where multi-item textbook reservations, student details, course requirements, and vendor inventory exist in repeating groups:

$$\text{UNF}(\underline{\text{ReservationID}}, \text{StudentID}, \text{StudentName}, \text{ProgrammeName}, \text{CourseCode}, \text{CourseTitle}, \{\text{BookTitle}, \text{Author}, \text{EditionLabel}, \text{ISBN}, \text{Price}, \text{CopyType}\}, \text{PaymentMethod}, \text{PickupCode})$$

* **Anomalies Identified:**
  * *Insertion Anomaly:* Cannot enter a course textbook into the catalog without an active student reservation.
  * *Update Anomaly:* Modifying the author or base price of a book requires updating thousands of past reservation records.
  * *Deletion Anomaly:* Deleting a cancelled student reservation deletes the record of the course textbook syllabus.

---

## 2. First Normal Form (1NF)
**Rule:** Eliminate repeating groups; ensure all attributes are atomic; identify a primary key[cite: 4].

The repeating book items within each reservation are decomposed into distinct rows with a composite key $(\text{ReservationID}, \text{EditionID})$:

* `RESERVATION_FLAT`($\underline{\text{ReservationID}}$, $\underline{\text{EditionID}}$, $\text{StudentID}$, $\text{StudentName}$, $\text{StudentEmail}$, $\text{ProgrammeName}$, $\text{CourseCode}$, $\text{CourseTitle}$, $\text{BookTitle}$, $\text{Author}$, $\text{ISBN}$, $\text{EditionLabel}$, $\text{UnitPrice}$, $\text{CopyType}$, $\text{PaymentMethod}$, $\text{PickupCode}$)

---

## 3. Second Normal Form (2NF)
**Rule:** Must be in 1NF; eliminate partial functional dependencies (all non-key attributes must depend on the whole primary key)[cite: 4].

In `RESERVATION_FLAT`, book attributes ($\text{BookTitle}, \text{Author}, \text{UnitPrice}$) depend only on $\text{EditionID}$, not on the combined key $(\text{ReservationID}, \text{EditionID})$. 

Decomposition into separate relations:
1. **`reservations`** ($\underline{\text{reservation\_id}}$, $\text{student\_id}$, $\text{status}$, $\text{payment\_method}$, $\text{pickup\_code}$)
2. **`reservation_items`** ($\underline{\text{item\_id}}$, $\text{reservation\_id}$, $\text{edition\_id}$, $\text{copy\_type}$, $\text{listing\_id}$, $\text{unit\_price}$)
3. **`editions_catalog`** ($\underline{\text{edition\_id}}$, $\text{book\_title}$, $\text{author}$, $\text{edition\_label}$, $\text{isbn}$, $\text{new\_price}$)

---

## 4. Third Normal Form (3NF)
**Rule:** Must be in 2NF; eliminate transitive dependencies (no non-key attribute can depend on another non-key attribute)[cite: 4].

* **Transitive Dependency 1 (Programmes & Courses):** $\text{course\_id} \rightarrow \text{programme\_id} \rightarrow \text{programme\_name}$.  
  * *Resolution:* Separate into `programmes` ($\underline{\text{programme\_id}}$, $\text{name}$, $\text{code}$) and `courses` ($\underline{\text{course\_id}}$, $\text{code}$, $\text{title}$, $\text{programme\_id}$, $\text{semester\_no}$).
* **Transitive Dependency 2 (Books & Editions):** $\text{edition\_id} \rightarrow \text{book\_id} \rightarrow (\text{title}, \text{author})$.  
  * *Resolution:* Separate into conceptual entity `books` ($\underline{\text{book\_id}}$, $\text{title}$, $\text{author}$) and physical entity `editions` ($\underline{\text{edition\_id}}$, $\text{book\_id}$, $\text{edition\_label}$, $\text{isbn}$, $\text{new\_price}$).
* **Transitive Dependency 3 (Inventory & P2P Resale):** Physical stock levels and peer-to-peer listings have distinct lifecycles from static editions.  
  * *Resolution:* Separate into `stock` (for new bookstore copies) and `used_listings` (for student-submitted copies undergoing intake grading).

### Conclusion
The resulting 14 tables in `database/schema.sql` completely satisfy Third Normal Form (3NF), ensuring data integrity, minimal redundancy, and complete isolation of insert, update, and delete operations.