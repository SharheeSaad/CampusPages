/**
 * CampusPages - State Management and Initial Seed Data
 * Directly mirrors UCSI Bangladesh Campus 3NF Relational Database Schema & Seed.
 */

const STORAGE_KEY = 'campuspages_db_state_v1';

const INITIAL_SEED_DATA = {
  role: 'student',
  activeSemester: 4,
  activeProgrammeId: 1, // Default BCS
  forecastParams: {
    buyRate: 0.650,
    buffer: 5
  },
  programmes: [
    { id: 1, code: 'BCS', name: 'BSc (Hons) Computer Science' },
    { id: 2, code: 'BIT', name: 'Bachelor of Information Technology' },
    { id: 3, code: 'BBA', name: 'Bachelor of Business Administration' }
  ],
  courses: [
    { id: 1, programmeId: 1, code: 'BIC3203', title: 'Business Case Project', semester: 4 },
    { id: 2, programmeId: 1, code: 'BIC2104', title: 'Data Structures and Algorithms', semester: 3 },
    { id: 3, programmeId: 1, code: 'BIC2102', title: 'Database Management Systems', semester: 3 },
    { id: 4, programmeId: 2, code: 'BIT1101', title: 'Introduction to Networking', semester: 1 },
    { id: 5, programmeId: 3, code: 'BBA2010', title: 'Principles of Marketing Management', semester: 4 }
  ],
  books: [
    {
      id: 1,
      courseId: 1,
      courseCode: 'BIC3203',
      courseTitle: 'Business Case Project',
      programmeId: 1,
      semester: 4,
      title: 'Systems Analysis and Design',
      author: 'Kendall & Kendall',
      edition: '10th Global Edition',
      isbn: '978-0134785554',
      newPrice: 1850,
      qtyNew: 15,
      qtyReserved: 1,
      enrolment: 45,
      term: 'September 2026',
      confirmedBy: 'Dr. Syllabus Instructor (FAC001)',
      confirmedAt: '2026-09-01 10:00:00'
    },
    {
      id: 2,
      courseId: 2,
      courseCode: 'BIC2104',
      courseTitle: 'Data Structures and Algorithms',
      programmeId: 1,
      semester: 3,
      title: 'Data Structures & Algorithm Analysis in Java',
      author: 'Mark Allen Weiss',
      edition: '3rd Edition',
      isbn: '978-0132576277',
      newPrice: 1600,
      qtyNew: 10,
      qtyReserved: 1,
      enrolment: 60,
      term: 'September 2026',
      confirmedBy: 'Dr. Syllabus Instructor (FAC001)',
      confirmedAt: '2026-09-01 10:00:00'
    },
    {
      id: 3,
      courseId: 3,
      courseCode: 'BIC2102',
      courseTitle: 'Database Management Systems',
      programmeId: 1,
      semester: 3,
      title: 'Database System Concepts',
      author: 'Silberschatz, Korth & Sudarshan',
      edition: '7th Edition',
      isbn: '978-0078022159',
      newPrice: 2100,
      qtyNew: 6,
      qtyReserved: 0,
      enrolment: 55,
      term: 'September 2026',
      confirmedBy: 'Dr. Syllabus Instructor (FAC001)',
      confirmedAt: '2026-09-01 10:00:00'
    },
    {
      id: 4,
      courseId: 4,
      courseCode: 'BIT1101',
      courseTitle: 'Introduction to Networking',
      programmeId: 2,
      semester: 1,
      title: 'Computer Networking: A Top-Down Approach',
      author: 'Kurose & Ross',
      edition: '8th Edition',
      isbn: '978-0136681557',
      newPrice: 2400,
      qtyNew: 0, // Critical Out-of-Stock to demonstrate Waitlist
      qtyReserved: 0,
      enrolment: 40,
      term: 'September 2026',
      confirmedBy: 'Dr. Syllabus Instructor (FAC001)',
      confirmedAt: '2026-09-01 10:00:00'
    },
    {
      id: 5,
      courseId: 5,
      courseCode: 'BBA2010',
      courseTitle: 'Principles of Marketing Management',
      programmeId: 3,
      semester: 4,
      title: 'Marketing Management: Global Edition',
      author: 'Kotler & Keller',
      edition: '16th Edition',
      isbn: '978-1292404813',
      newPrice: 1950,
      qtyNew: 12,
      qtyReserved: 0,
      enrolment: 50,
      term: 'September 2026',
      confirmedBy: 'Prof. Business Faculty (FAC004)',
      confirmedAt: '2026-09-02 11:30:00'
    }
  ],
  usedListings: [
    {
      id: 1,
      bookId: 2,
      sellerId: 3,
      sellerName: 'Senior Resale Student',
      sellerEmail: 'student1@campuspages.test',
      sellerStudentId: 'STU2024001',
      declaredCondition: 'good',
      conditionGrade: 'good',
      askingPrice: 1000,
      approvedPrice: 950,
      status: 'available', // available, reserved, sold, pending_inspection, rejected
      createdAt: '2026-10-14 10:00:00'
    },
    {
      id: 2,
      bookId: 3,
      sellerId: 3,
      sellerName: 'Senior Resale Student',
      sellerEmail: 'student1@campuspages.test',
      sellerStudentId: 'STU2024001',
      declaredCondition: 'good',
      conditionGrade: 'like_new',
      askingPrice: 1400,
      approvedPrice: 1300,
      status: 'reserved', // Reserved in Reservation 2
      createdAt: '2026-10-15 09:30:00'
    },
    {
      id: 3,
      bookId: 1,
      sellerId: 3,
      sellerName: 'Senior Resale Student',
      sellerEmail: 'student1@campuspages.test',
      sellerStudentId: 'STU2024001',
      declaredCondition: 'fair',
      conditionGrade: 'fair',
      askingPrice: 900,
      approvedPrice: 900,
      status: 'pending_inspection',
      createdAt: '2026-10-16 08:45:00'
    }
  ],
  reservations: [
    {
      id: 'RES-2026-001',
      numericId: 1,
      studentId: 'STU2025002',
      studentName: 'Junior Enrolled Student',
      studentEmail: 'student2@campuspages.test',
      programCode: 'BCS',
      status: 'unpaid_reserved', // unpaid_reserved, paid_reserved, fulfilled, cancelled
      paymentMethod: 'cash',
      qrToken: 'oGoqycNl5zbLiPk9oCswKEZC7AelYNvJ',
      createdAt: '2026-10-15 14:30:00',
      totalAmount: 3450,
      items: [
        {
          bookId: 1,
          title: 'Systems Analysis and Design',
          edition: '10th Global Edition',
          courseCode: 'BIC3203',
          isUsed: false,
          listingId: null,
          price: 1850
        },
        {
          bookId: 2,
          title: 'Data Structures & Algorithm Analysis in Java',
          edition: '3rd Edition',
          courseCode: 'BIC2104',
          isUsed: false,
          listingId: null,
          price: 1600
        }
      ]
    },
    {
      id: 'RES-2026-002',
      numericId: 2,
      studentId: 'STU2025002',
      studentName: 'Junior Enrolled Student',
      studentEmail: 'student2@campuspages.test',
      programCode: 'BCS',
      status: 'paid_reserved',
      paymentMethod: 'bkash',
      qrToken: 'i1Hf9yiN_THXEYhhM8wdeP5tf9rTLUh9',
      createdAt: '2026-10-16 11:15:00',
      totalAmount: 1300,
      items: [
        {
          bookId: 3,
          title: 'Database System Concepts',
          edition: '7th Edition',
          courseCode: 'BIC2102',
          isUsed: true,
          listingId: 2,
          price: 1300
        }
      ]
    }
  ],
  waitlist: [
    {
      id: 1,
      bookId: 4,
      studentId: 'STU2025002',
      studentEmail: 'student2@campuspages.test',
      joinedAt: '2026-10-14 09:20:00'
    }
  ],
  transactions: [
    {
      id: 'TXN-2026-001',
      reservationId: 'RES-2026-002',
      listingId: 2,
      type: 'payment',
      method: 'bKash',
      amount: 1300,
      fee: 130, // 10% platform fee
      sellerPayout: 1170, // 90% payout to senior student
      createdAt: '2026-10-16 11:15:00',
      details: 'Prepaid bKash for Database System Concepts (Used - Like New)'
    }
  ],
  notifications: [
    {
      id: 1,
      title: 'Pickup Pass Ready: CP-RES-2026-001',
      message: 'Your semester bundle is reserved. Present QR at Level 3 campus counter.',
      time: '15 mins ago',
      read: false
    },
    {
      id: 2,
      title: 'Used Listing Verified',
      message: "Database System Concepts (7th Ed) graded 'Like New' at BDT 1,300.",
      time: '2 hours ago',
      read: true
    },
    {
      id: 3,
      title: 'Syllabus Adoption Confirmed',
      message: 'BIC3203 Business Case Project textbook requirements locked for Term September 2026.',
      time: '1 day ago',
      read: true
    }
  ]
};

class StateManager {
  constructor() {
    this.state = this.load();
  }

  load() {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        return JSON.parse(stored);
      }
    } catch (e) {
      console.warn('Could not read from localStorage, using initial seed data.', e);
    }
    // Deep clone initial seed data
    return JSON.parse(JSON.stringify(INITIAL_SEED_DATA));
  }

  save() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(this.state));
    } catch (e) {
      console.error('Failed to save state to localStorage', e);
    }
  }

  reset() {
    this.state = JSON.parse(JSON.stringify(INITIAL_SEED_DATA));
    this.save();
  }

  get() {
    return this.state;
  }
}

// Global state manager instance
window.CampusPagesStore = new StateManager();
