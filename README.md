# CampusPages

**Demand-driven course book supply and peer resale platform with syllabus matching and inventory forecasting.**  


---

## 1. Project Overview
CampusPages is an academic web platform designed to streamline course textbook acquisition and circular book reuse at UCSI University Bangladesh. The system links instructor-confirmed course booklists directly to student demand forecasts, offers single-step semester bundle reservations, and provides a peer-to-peer (P2P) resale pipeline for senior students with on-campus pickup verification.

---

## 2. Team Members & Contributions
* **Sharhee Saad Imam** (ID: 1702400203) — Architecture, Backend, Database & Repository Lead
* **Amaan Ahmad** (ID: 1702300064) — Survey Research, UI/UX & Documentation
* **Md. Aminur Rahman Eusha** (ID: 1702400154) — Testing, Quality Assurance & Data Modeling

**Course Lecturer:** Rokeya Akanda Sriti  
**Course Code:** BIC3203

---

## 3. Repository Architecture
```text
CampusPages/
├── docs/                # Academic Proposal, SRS, Test Plan, Defect Log, Traceability Matrix
├── diagrams/            # DFD (Level 0-2), ERD, UML Diagrams (Draw.io XML & exports)
├── design/              # UI/UX Wireframes and Figma screen exports
├── database/            # MySQL schema.sql, seed.sql, and relational normalization notes
├── src/                 # Application Source Code (Python Flask)
│   ├── app.py           # Application entry point & configuration
│   ├── models/          # Database query wrappers & data models
│   ├── routes/          # Blueprint routing (Student, Instructor, Owner)
│   ├── services/        # Demand forecasting engine (FR-13) & QR verification
│   ├── templates/       # HTML5 Jinja templates
│   └── static/          # CSS styles, JS assets, and images
├── tests/               # Test suites (FR validation & API tests)
├── .env.example         # Template for environment configuration
├── .gitignore           # Git ignore rules for Python, virtual environments, and secrets
├── requirements.txt     # Python dependencies
└── README.md            # Repository overview and setup guide