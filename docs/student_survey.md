# CampusPages Student Needs Survey
**Course:** BIC3203 Business Case Project  
**Target Respondents:** UCSI University Bangladesh Enrolled Students  
**Survey Tool:** Google Forms  

---

## Purpose
This survey collects empirical baseline data to calibrate the demand forecasting model (`forecast_params.buy_rate`) and validate student pain points regarding course book procurement, pricing, and peer resale.

---

## Questionnaire Items

### Section 1: Demographics & Academic Profile
1. **What degree programme are you currently enrolled in?**
   - [ ] BSc (Hons) Computer Science
   - [ ] Bachelor of Information Technology
   - [ ] BBA / Business Administration
   - [ ] Other: __________

2. **What year/semester are you currently in?**
   - [ ] Year 1 (Semester 1–3)
   - [ ] Year 2 (Semester 4–6)
   - [ ] Year 3 (Semester 7–9)
   - [ ] Final Year / Graduating

---

### Section 2: Current Book Procurement Habits
3. **Where do you usually get your textbooks for each semester? (Select all that apply)**
   - [ ] Off-campus markets (e.g., Nilkhet)
   - [ ] Online bookshops (e.g., Rokomari, BoiBazar)
   - [ ] Borrowed or purchased from senior students
   - [ ] Photocopy shops
   - [ ] Free digital/PDF downloads
   - [ ] Campus Library reference books

4. **Have you ever ended up with the wrong edition of a required textbook?**
   - [ ] Yes, multiple times
   - [ ] Yes, once
   - [ ] No, never

5. **How long does it usually take you to get all your course books at the start of a semester?**
   - [ ] Less than 3 days
   - [ ] 1–2 weeks
   - [ ] 3 weeks or more
   - [ ] I frequently cannot get all required books

---

### Section 3: Financial & Willingness to Purchase
6. **On average, how much do you spend on academic books per semester?**
   - [ ] Under BDT 1,000
   - [ ] BDT 1,000 – BDT 2,500
   - [ ] BDT 2,501 – BDT 4,000
   - [ ] Over BDT 4,000

7. **If an on-campus service guaranteed the instructor-confirmed edition for pickup, would you buy new books from it?**
   - [ ] Definitely yes (1.0 weight)
   - [ ] Probably yes (0.75 weight)
   - [ ] Only if discounted (0.50 weight)
   - [ ] No, prefer photocopies/PDFs (0.0 weight)

---

### Section 4: Peer Resale & Semester Bundles
8. **What happens to your textbooks once a semester ends?**
   - [ ] They sit on my shelf unused
   - [ ] I give them away to friends or juniors for free
   - [ ] I try to sell them informally
   - [ ] I do not buy physical books

9. **Would you use a verified campus platform to sell your completed course books to junior students?**
   - [ ] Yes, definitely
   - [ ] Maybe, depending on payout convenience
   - [ ] No

10. **Would you use a "One-Click Semester Bundle" that reserves all required textbooks for your enrolled courses in one step?**
    - [ ] Extremely useful
    - [ ] Somewhat useful
    - [ ] Not interested

---

## Calibration Formula for System Demand Forecasting (FR-13)
The responses to Question 7 directly establish the `buy_rate` parameter inside table `forecast_params`:

$$\text{Buy Rate} = \frac{\sum (\text{Definitely Yes} \times 1.0) + (\text{Probably Yes} \times 0.75) + (\text{Only if Discounted} \times 0.50)}{N_{\text{total respondents}}}$$

This parameter replaces guesswork and provides an evidence-based demand multiplier for the order recommendation engine.