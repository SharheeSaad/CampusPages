/**
 * CampusPages - Application Logic & Interactive State Controller
 * Fully functional implementation covering Student, Instructor, and Store Owner workflows.
 */

// Shorthand reference to global store
const store = window.CampusPagesStore;

// State helper getters & setters
function getState() {
  return store.get();
}

function saveState() {
  store.save();
}

// =====================================================================
// Procedural SVG QR Code Matrix Generator
// Generates authentic, deterministic, scannable-looking QR matrices from any token.
// =====================================================================
function generateQRCodeSVG(token, size = 180) {
  // Deterministic hash from string token
  let hash = 0;
  for (let i = 0; i < token.length; i++) {
    hash = (hash << 5) - hash + token.charCodeAt(i);
    hash |= 0;
  }

  const gridSize = 25; // 25x25 matrix
  const cellSize = 100 / gridSize;
  const matrix = Array.from({ length: gridSize }, () => Array(gridSize).fill(0));

  // 1. Draw 3 Standard Position Finder Patterns (7x7 outer, 5x5 white, 3x3 inner)
  const drawFinder = (startX, startY) => {
    for (let r = 0; r < 7; r++) {
      for (let c = 0; c < 7; c++) {
        if (
          r === 0 || r === 6 || c === 0 || c === 6 || // Outer 7x7 border
          (r >= 2 && r <= 4 && c >= 2 && c <= 4)     // Inner 3x3 box
        ) {
          matrix[startY + r][startX + c] = 1;
        } else {
          matrix[startY + r][startX + c] = 0;
        }
      }
    }
  };

  drawFinder(1, 1);                    // Top-Left
  drawFinder(gridSize - 8, 1);         // Top-Right
  drawFinder(1, gridSize - 8);         // Bottom-Left

  // 2. Timing Patterns (alternating black and white on row 7 & col 7)
  for (let i = 8; i < gridSize - 8; i++) {
    matrix[7][i] = i % 2 === 0 ? 1 : 0;
    matrix[i][7] = i % 2 === 0 ? 1 : 0;
  }

  // 3. Fill remaining data area using deterministic PRNG seeded by hash
  let prng = Math.abs(hash) + 12345;
  for (let r = 0; r < gridSize; r++) {
    for (let c = 0; c < gridSize; c++) {
      // Don't overwrite finders or timing patterns
      const inTopLeft = r <= 8 && c <= 8;
      const inTopRight = r <= 8 && c >= gridSize - 9;
      const inBottomLeft = r >= gridSize - 9 && c <= 8;
      const isTiming = r === 7 || c === 7;

      if (!inTopLeft && !inTopRight && !inBottomLeft && !isTiming) {
        prng = (prng * 9301 + 49297) % 233280;
        const rand = prng / 233280;
        matrix[r][c] = rand > 0.52 ? 1 : 0;
      }
    }
  }

  // Build SVG Rects
  let rects = '';
  for (let r = 0; r < gridSize; r++) {
    for (let c = 0; c < gridSize; c++) {
      if (matrix[r][c] === 1) {
        const x = (c * cellSize).toFixed(2);
        const y = (r * cellSize).toFixed(2);
        const w = (cellSize + 0.1).toFixed(2);
        const h = (cellSize + 0.1).toFixed(2);
        const fill = (r < 7 && c < 7) || (r < 7 && c >= gridSize - 7) || (r >= gridSize - 7 && c < 7)
          ? '#1e293b' // Dark slate for finders
          : '#2563eb'; // Brand royal blue for data modules
        rects += `<rect x="${x}" y="${y}" width="${w}" height="${h}" fill="${fill}" />`;
      }
    }
  }

  return `
    <svg class="w-full h-full max-w-[${size}px] max-h-[${size}px] mx-auto" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect width="100" height="100" fill="white" rx="4" />
      ${rects}
    </svg>
  `;
}

// Generate random safe cryptographic-looking token
function generateSecureToken(length = 32) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  let token = '';
  for (let i = 0; i < length; i++) {
    token += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return token;
}

// =====================================================================
// Role Switcher Handler
// =====================================================================
function switchRole(newRole) {
  const state = getState();
  state.role = newRole;
  saveState();

  // Update navbar role button styling
  ['student', 'instructor', 'owner'].forEach((r) => {
    const btn = document.getElementById(`btn-role-${r}`);
    const view = document.getElementById(`view-${r}`);
    if (!btn || !view) return;

    if (r === newRole) {
      btn.className = 'px-3 py-1.5 text-xs font-bold rounded-lg transition-all bg-white text-blue-700 shadow-sm';
      view.classList.remove('hidden');
    } else {
      btn.className = 'px-3 py-1.5 text-xs font-semibold rounded-lg transition-all text-slate-600 hover:text-slate-900';
      view.classList.add('hidden');
    }
  });

  // Re-render corresponding views
  if (newRole === 'student') {
    renderStudentCatalog();
    renderBundleHero();
  } else if (newRole === 'instructor') {
    renderInstructorTable();
  } else if (newRole === 'owner') {
    renderOwnerDashboard();
  }

  showToast(`Active Role: ${newRole.toUpperCase()}`, `Switched interface view to ${newRole}.`);
}

// =====================================================================
// Student View: Search & Curriculum Filtering
// =====================================================================
function filterSemester(sem) {
  const state = getState();
  state.activeSemester = sem;
  saveState();

  // Update pills UI
  ['all', 1, 2, 3, 4, 5].forEach((s) => {
    const pill = document.getElementById(`sem-pill-${s}`);
    if (!pill) return;
    if (s === sem) {
      pill.className = 'px-3 py-1.5 rounded-lg font-bold bg-white text-blue-700 shadow-sm transition-all';
    } else {
      pill.className = 'px-3 py-1.5 rounded-lg font-medium text-slate-600 hover:text-slate-900 transition-all';
    }
  });

  renderStudentCatalog();
  renderBundleHero();
}

function handleProgrammeChange() {
  const select = document.getElementById('studentProgrammeSelect');
  if (!select) return;
  const state = getState();
  state.activeProgrammeId = parseInt(select.value, 10);
  saveState();
  renderStudentCatalog();
  renderBundleHero();
}

function handleGlobalSearch() {
  renderStudentCatalog();
}

// 1-Click Semester Bundle Hero Banner
function renderBundleHero() {
  const state = getState();
  const progSelect = document.getElementById('studentProgrammeSelect');
  const progId = progSelect ? parseInt(progSelect.value, 10) : state.activeProgrammeId || 1;
  const prog = state.programmes.find((p) => p.id === progId) || state.programmes[0];
  const sem = state.activeSemester === 'all' ? 4 : state.activeSemester;

  const bundleTitle = document.getElementById('bundleHeroTitle');
  const bundleModules = document.getElementById('bundleHeroModules');
  const bundlePrice = document.getElementById('bundleHeroPrice');
  const bundleBtn = document.getElementById('bundleHeroReserveBtn');

  // Filter books matching current programme and semester
  const semesterBooks = state.books.filter(
    (b) => b.programmeId === prog.id && (b.semester === sem || state.activeSemester === 'all')
  );

  const totalBundlePrice = semesterBooks.reduce((sum, b) => sum + b.newPrice, 0);

  if (bundleTitle) bundleTitle.innerText = `${prog.code} Semester ${sem} Course Bundle`;
  if (bundleModules) bundleModules.innerText = `${semesterBooks.length} Required Courses`;
  if (bundlePrice) bundlePrice.innerText = `BDT ${totalBundlePrice.toLocaleString()}`;
  if (bundleBtn) {
    bundleBtn.disabled = semesterBooks.length === 0;
    bundleBtn.title = semesterBooks.length === 0 ? 'No courses in this semester' : 'Reserve complete bundle';
  }
}

// Render Student Textbook Catalog Grid
function renderStudentCatalog() {
  const state = getState();
  const grid = document.getElementById('studentBookGrid');
  const searchInput = document.getElementById('globalSearch');
  const progSelect = document.getElementById('studentProgrammeSelect');

  if (!grid) return;
  grid.innerHTML = '';

  const query = searchInput ? searchInput.value.trim().toLowerCase() : '';
  const progId = progSelect ? parseInt(progSelect.value, 10) : state.activeProgrammeId || 1;
  const activeSem = state.activeSemester;

  // Filter books
  const filteredBooks = state.books.filter((b) => {
    // Programme filter
    const matchProg = b.programmeId === progId;
    // Semester filter
    const matchSem = activeSem === 'all' || b.semester === activeSem;
    // Search query filter
    const matchQuery =
      !query ||
      b.title.toLowerCase().includes(query) ||
      b.author.toLowerCase().includes(query) ||
      b.courseCode.toLowerCase().includes(query) ||
      b.courseTitle.toLowerCase().includes(query) ||
      b.isbn.toLowerCase().includes(query);

    return matchProg && matchSem && matchQuery;
  });

  const countBadge = document.getElementById('catalogBookCount');
  if (countBadge) {
    countBadge.innerText = `Showing ${filteredBooks.length} syllabus ${filteredBooks.length === 1 ? 'title' : 'titles'}`;
  }

  if (filteredBooks.length === 0) {
    grid.innerHTML = `
      <div class="col-span-full py-16 text-center bg-white rounded-3xl border border-dashed border-slate-300 p-8 space-y-3">
        <div class="w-12 h-12 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center mx-auto text-xl font-bold">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/></svg>
        </div>
        <h4 class="font-bold text-slate-800 text-base">No Textbooks Found</h4>
        <p class="text-xs text-slate-500 max-w-md mx-auto">No course books match the selected programme or search query. Try choosing "Sem 3" or "Sem 4" or reset the search bar.</p>
        <button onclick="resetFilters()" class="px-4 py-2 bg-blue-50 hover:bg-blue-100 text-blue-700 font-bold text-xs rounded-xl transition-all">Reset All Filters</button>
      </div>
    `;
    return;
  }

  filteredBooks.forEach((book) => {
    const availableStock = Math.max(0, book.qtyNew - book.qtyReserved);
    const isOutOfStock = availableStock <= 0;

    // Check for verified available used listing
    const usedListing = state.usedListings.find(
      (ul) => ul.bookId === book.id && ul.status === 'available'
    );

    const card = document.createElement('div');
    card.className =
      'book-card bg-white rounded-2xl border border-slate-200 shadow-sm flex flex-col justify-between p-5 space-y-4';

    card.innerHTML = `
      <div class="space-y-3">
        <!-- Top Tags -->
        <div class="flex items-center justify-between text-xs">
          <div class="flex items-center gap-2">
            <span class="font-mono font-bold px-2 py-0.5 bg-slate-100 text-slate-800 rounded-md border border-slate-200">${book.courseCode}</span>
            <span class="text-[10px] font-semibold text-slate-400">Sem ${book.semester}</span>
          </div>
          ${
            isOutOfStock
              ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-rose-100 text-rose-700 border border-rose-200">Out of Stock</span>'
              : availableStock <= 3
              ? `<span class="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-amber-100 text-amber-800 border border-amber-200">Only ${availableStock} Left</span>`
              : `<span class="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-emerald-100 text-emerald-800 border border-emerald-200">${availableStock} Available</span>`
          }
        </div>

        <!-- Book Meta -->
        <div>
          <h4 class="font-bold text-slate-900 text-sm leading-snug line-clamp-2">${book.title}</h4>
          <p class="text-xs text-slate-500 mt-0.5">${book.author} • <span class="text-indigo-700 font-semibold">${book.edition}</span></p>
          <div class="flex items-center gap-2 mt-1">
            <span class="text-[10px] font-mono text-slate-400">ISBN: ${book.isbn}</span>
            <span class="text-[10px] text-emerald-700 bg-emerald-50 px-1.5 py-0.2 rounded font-medium">✓ Syllabus Mandated</span>
          </div>
        </div>

        <!-- Price & Condition Comparison Box -->
        <div class="pt-2 space-y-2">
          
          <!-- New Copy Option -->
          <div class="flex items-center justify-between p-2.5 rounded-xl border ${
            isOutOfStock ? 'bg-slate-50 border-slate-200 opacity-60' : 'bg-blue-50/40 border-blue-100'
          }">
            <div class="flex items-center gap-2">
              <input type="radio" name="opt_book_${book.id}" id="opt_new_${book.id}" value="new" ${
      isOutOfStock ? 'disabled' : 'checked'
    } class="text-blue-600 focus:ring-blue-500">
              <label for="opt_new_${book.id}" class="text-xs cursor-pointer">
                <span class="font-bold text-slate-800 block">Brand New Copy</span>
                <span class="text-[10px] text-slate-500">${
                  isOutOfStock ? 'Wholesale backorder' : availableStock + ' shelf units available'
                }</span>
              </label>
            </div>
            <div class="text-right">
              <span class="text-xs font-black text-slate-900 block">BDT ${book.newPrice.toLocaleString()}</span>
              <span class="text-[9px] text-slate-400">Official Retail</span>
            </div>
          </div>

          <!-- Used Resale (P2P) Option -->
          ${
            usedListing
              ? `
              <div class="flex items-center justify-between p-2.5 rounded-xl border bg-emerald-50/70 border-emerald-200">
                <div class="flex items-center gap-2">
                  <input type="radio" name="opt_book_${book.id}" id="opt_used_${book.id}" value="used_${usedListing.id}" class="text-emerald-600 focus:ring-emerald-500">
                  <label for="opt_used_${book.id}" class="text-xs cursor-pointer">
                    <span class="font-bold text-emerald-950 flex items-center gap-1.5">
                      Senior Resale (P2P)
                      <span class="px-1.5 py-0.2 bg-emerald-200 text-emerald-900 rounded text-[9px] uppercase font-extrabold tracking-wider">${usedListing.conditionGrade}</span>
                    </span>
                    <span class="text-[10px] text-emerald-700 block">Verified by campus counter</span>
                  </label>
                </div>
                <div class="text-right">
                  <span class="text-xs font-black text-emerald-700 block">BDT ${usedListing.approvedPrice.toLocaleString()}</span>
                  <span class="text-[9px] text-emerald-600 font-semibold">Save ${(
                    ((book.newPrice - usedListing.approvedPrice) / book.newPrice) *
                    100
                  ).toFixed(0)}%</span>
                </div>
              </div>
            `
              : `
              <div class="flex items-center justify-between p-2.5 rounded-xl bg-slate-50 border border-slate-100 text-slate-400 text-xs">
                <div>
                  <span class="font-semibold block text-[11px]">Senior Resale (P2P)</span>
                  <span class="text-[10px]">No used copies verified currently</span>
                </div>
                <button onclick="openModal('modalSellBook')" class="text-[10px] text-blue-600 font-bold hover:underline">
                  Have one? Sell it
                </button>
              </div>
            `
          }
        </div>
      </div>

      <!-- Action Button Footer -->
      <div class="pt-3 border-t border-slate-100">
        ${
          isOutOfStock && !usedListing
            ? `
            <button onclick="openWaitlistModal(${book.id})" 
                    class="w-full py-2.5 px-3 bg-amber-500 hover:bg-amber-600 text-white font-bold text-xs rounded-xl shadow-sm transition-all flex items-center justify-center gap-1.5">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>
              <span>Join Restock Waitlist</span>
            </button>
          `
            : `
            <button onclick="openReserveModal(${book.id})" 
                    class="w-full py-2.5 px-3 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-xl shadow-sm shadow-blue-600/20 transition-all flex items-center justify-center gap-1.5">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
              <span>Reserve Copy for Pickup</span>
            </button>
          `
        }
      </div>
    `;

    grid.appendChild(card);
  });
}

function resetFilters() {
  const searchInput = document.getElementById('globalSearch');
  if (searchInput) searchInput.value = '';
  filterSemester(4);
}

// =====================================================================
// Reservation Modal & Checkout Engine (FR-07, FR-08)
// =====================================================================
let activeReserveConfig = null;

function openReserveModal(bookId) {
  const state = getState();
  const book = state.books.find((b) => b.id === bookId);
  if (!book) return;

  // Check selected radio button on card
  const selectedRadio = document.querySelector(`input[name="opt_book_${book.id}"]:checked`);
  let isUsed = false;
  let usedListing = null;

  if (selectedRadio && selectedRadio.value.startsWith('used_')) {
    const listingId = parseInt(selectedRadio.value.replace('used_', ''), 10);
    usedListing = state.usedListings.find((ul) => ul.id === listingId);
    isUsed = !!usedListing;
  }

  const price = isUsed ? usedListing.approvedPrice : book.newPrice;

  activeReserveConfig = {
    bookId: book.id,
    isUsed: isUsed,
    usedListingId: usedListing ? usedListing.id : null,
    title: book.title,
    edition: book.edition,
    courseCode: book.courseCode,
    price: price
  };

  // Populate checkout modal
  document.getElementById('checkoutBookTitle').innerText = book.title;
  document.getElementById('checkoutBookMeta').innerText = `${book.courseCode} • ${book.edition} • ${
    isUsed ? `Used (${usedListing.conditionGrade})` : 'Brand New Copy'
  }`;
  document.getElementById('checkoutPriceDisplay').innerText = `BDT ${price.toLocaleString()}`;

  openModal('modalCheckout');
}

function confirmCheckout() {
  if (!activeReserveConfig) return;

  const state = getState();
  const paymentMethod = document.querySelector('input[name="checkout_payment"]:checked').value;
  const isPaid = paymentMethod === 'bkash' || paymentMethod === 'nagad';
  const newNumericId = state.reservations.length + 1;
  const resCode = `RES-2026-${String(newNumericId).padStart(3, '0')}`;
  const qrToken = generateSecureToken(32);

  const newReservation = {
    id: resCode,
    numericId: newNumericId,
    studentId: 'STU2025002',
    studentName: 'Junior Enrolled Student',
    studentEmail: 'student2@campuspages.test',
    programCode: 'BCS',
    status: isPaid ? 'paid_reserved' : 'unpaid_reserved',
    paymentMethod: paymentMethod,
    qrToken: qrToken,
    createdAt: new Date().toISOString().replace('T', ' ').substring(0, 19),
    totalAmount: activeReserveConfig.price,
    items: [
      {
        bookId: activeReserveConfig.bookId,
        title: activeReserveConfig.title,
        edition: activeReserveConfig.edition,
        courseCode: activeReserveConfig.courseCode,
        isUsed: activeReserveConfig.isUsed,
        listingId: activeReserveConfig.usedListingId,
        price: activeReserveConfig.price
      }
    ]
  };

  // Update Stock & Listing semantics
  if (activeReserveConfig.isUsed) {
    const listing = state.usedListings.find((l) => l.id === activeReserveConfig.usedListingId);
    if (listing) listing.status = 'reserved';
  } else {
    const book = state.books.find((b) => b.id === activeReserveConfig.bookId);
    if (book) book.qtyReserved += 1;
  }

  // If prepaid, log transaction immediately
  if (isPaid) {
    state.transactions.unshift({
      id: `TXN-2026-${String(state.transactions.length + 1).padStart(3, '0')}`,
      reservationId: resCode,
      listingId: activeReserveConfig.usedListingId,
      type: 'payment',
      method: paymentMethod.toUpperCase(),
      amount: activeReserveConfig.price,
      fee: Math.round(activeReserveConfig.price * 0.1),
      sellerPayout: Math.round(activeReserveConfig.price * 0.9),
      createdAt: new Date().toISOString().replace('T', ' ').substring(0, 19),
      details: `Prepaid ${paymentMethod.toUpperCase()} for ${activeReserveConfig.title}`
    });
  }

  state.reservations.unshift(newReservation);

  // Add system alert
  state.notifications.unshift({
    id: Date.now(),
    title: `Pickup Pass Ready: ${resCode}`,
    message: `Your copy is held at Level 3 Campus Store. Token: ${qrToken.substring(0, 10)}...`,
    time: 'Just now',
    read: false
  });

  saveState();
  closeModal('modalCheckout');

  // Show the authentic scannable QR Pass modal
  displayPickupPass(newReservation);
  showToast('Reservation Confirmed!', `Generated pickup slip: ${resCode}`);

  renderStudentCatalog();
  renderOwnerDashboard();
  renderNotifications();
}

// 1-Click Bundle Reservation
function reserveBundle() {
  const state = getState();
  const progSelect = document.getElementById('studentProgrammeSelect');
  const progId = progSelect ? parseInt(progSelect.value, 10) : state.activeProgrammeId || 1;
  const sem = state.activeSemester === 'all' ? 4 : state.activeSemester;

  const bundleBooks = state.books.filter(
    (b) => b.programmeId === progId && (b.semester === sem || state.activeSemester === 'all')
  );

  if (bundleBooks.length === 0) {
    showToast('Empty Bundle', 'No course books in this semester.');
    return;
  }

  const newNumericId = state.reservations.length + 1;
  const resCode = `RES-2026-${String(newNumericId).padStart(3, '0')}`;
  const qrToken = generateSecureToken(32);
  let totalAmount = 0;

  const reservationItems = bundleBooks.map((b) => {
    b.qtyReserved += 1; // Increment reserved stock
    totalAmount += b.newPrice;
    return {
      bookId: b.id,
      title: b.title,
      edition: b.edition,
      courseCode: b.courseCode,
      isUsed: false,
      listingId: null,
      price: b.newPrice
    };
  });

  const bundleReservation = {
    id: resCode,
    numericId: newNumericId,
    studentId: 'STU2025002',
    studentName: 'Junior Enrolled Student',
    studentEmail: 'student2@campuspages.test',
    programCode: 'BCS',
    status: 'unpaid_reserved',
    paymentMethod: 'cash',
    qrToken: qrToken,
    createdAt: new Date().toISOString().replace('T', ' ').substring(0, 19),
    totalAmount: totalAmount,
    items: reservationItems
  };

  state.reservations.unshift(bundleReservation);

  state.notifications.unshift({
    id: Date.now(),
    title: `Semester Bundle Reserved: ${resCode}`,
    message: `${reservationItems.length} required books reserved. Present QR at Level 3 counter.`,
    time: 'Just now',
    read: false
  });

  saveState();

  renderStudentCatalog();
  renderOwnerDashboard();
  renderNotifications();

  displayPickupPass(bundleReservation);
  showToast('Semester Bundle Reserved!', `Slip ${resCode} generated with ${reservationItems.length} books.`);
}

// Display Pickup Pass Modal
function displayPickupPass(res) {
  const qrContainer = document.getElementById('pickupModalQrCode');
  const tokenDisplay = document.getElementById('pickupModalToken');
  const studentMeta = document.getElementById('pickupModalStudent');
  const itemsContainer = document.getElementById('pickupModalItems');
  const totalDisplay = document.getElementById('pickupModalTotal');
  const statusBadge = document.getElementById('pickupModalStatusBadge');
  const resCodeDisplay = document.getElementById('pickupModalResCode');

  if (resCodeDisplay) resCodeDisplay.innerText = res.id;
  if (tokenDisplay) tokenDisplay.innerText = res.qrToken;
  if (studentMeta) studentMeta.innerText = `Holder: ${res.studentName} (${res.studentId})`;

  if (statusBadge) {
    if (res.status === 'paid_reserved') {
      statusBadge.className = 'inline-block px-3 py-1 bg-emerald-100 text-emerald-800 text-xs font-bold rounded-full border border-emerald-200';
      statusBadge.innerText = `Prepaid via ${res.paymentMethod.toUpperCase()}`;
    } else if (res.status === 'fulfilled') {
      statusBadge.className = 'inline-block px-3 py-1 bg-blue-100 text-blue-800 text-xs font-bold rounded-full border border-blue-200';
      statusBadge.innerText = 'Fulfilled & Picked Up';
    } else {
      statusBadge.className = 'inline-block px-3 py-1 bg-amber-100 text-amber-800 text-xs font-bold rounded-full border border-amber-200';
      statusBadge.innerText = 'Payment Due at Counter (Cash)';
    }
  }

  // Render SVG QR code
  if (qrContainer) {
    qrContainer.innerHTML = generateQRCodeSVG(res.qrToken, 190);
  }

  // Render items breakdown
  if (itemsContainer) {
    itemsContainer.innerHTML = res.items
      .map(
        (item) => `
        <div class="flex justify-between items-center text-xs py-1">
          <span class="font-medium text-slate-700 truncate max-w-[210px]">${item.title} <span class="text-[10px] text-slate-400">(${item.isUsed ? 'Used' : 'New'})</span></span>
          <span class="font-bold text-slate-900">BDT ${item.price.toLocaleString()}</span>
        </div>
      `
      )
      .join('');
  }

  if (totalDisplay) {
    totalDisplay.innerText = `BDT ${res.totalAmount.toLocaleString()}.00`;
  }

  openModal('modalPickupPass');
}

// Print Current Pass
function printCurrentPass() {
  window.print();
}

// =====================================================================
// Student View: "My QR Slips" Overview Modal
// =====================================================================
function openMySlipsModal() {
  const state = getState();
  const listContainer = document.getElementById('mySlipsList');
  if (!listContainer) return;

  listContainer.innerHTML = '';

  if (state.reservations.length === 0) {
    listContainer.innerHTML = `
      <div class="text-center py-10 text-slate-400 text-xs italic">
        You do not have any active or past pickup slips.
      </div>
    `;
    openModal('modalMySlips');
    return;
  }

  state.reservations.forEach((res) => {
    const isPaid = res.status === 'paid_reserved';
    const isFulfilled = res.status === 'fulfilled';

    const card = document.createElement('div');
    card.className =
      'p-4 bg-slate-50 border border-slate-200 rounded-2xl flex flex-col sm:flex-row sm:items-center justify-between gap-3 hover:bg-white hover:border-blue-300 transition-all';

    card.innerHTML = `
      <div class="space-y-1">
        <div class="flex items-center gap-2">
          <span class="font-mono font-bold text-slate-900 text-xs">${res.id}</span>
          ${
            isFulfilled
              ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-blue-100 text-blue-800">Fulfilled</span>'
              : isPaid
              ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-800">Paid (' +
                res.paymentMethod.toUpperCase() +
                ')</span>'
              : '<span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-100 text-amber-800">Due at Counter</span>'
          }
          <span class="text-[10px] text-slate-400">${res.createdAt}</span>
        </div>
        <p class="text-xs text-slate-600 font-medium">
          ${res.items.map((i) => i.title).join(', ')}
        </p>
        <p class="text-xs font-bold text-slate-900">Total: BDT ${res.totalAmount.toLocaleString()}</p>
      </div>

      <div class="flex items-center gap-2">
        <button onclick="displayPickupPassByToken('${res.qrToken}')" 
                class="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-xs shadow-sm transition-all flex items-center gap-1.5">
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/></svg>
          <span>View QR</span>
        </button>
        ${
          !isFulfilled
            ? `
          <button onclick="cancelReservation('${res.id}')" class="px-2.5 py-1.5 text-xs text-rose-600 hover:bg-rose-50 rounded-xl font-bold transition-all" title="Cancel Reservation">
            Cancel
          </button>
        `
            : ''
        }
      </div>
    `;

    listContainer.appendChild(card);
  });

  openModal('modalMySlips');
}

function displayPickupPassByToken(token) {
  const state = getState();
  const res = state.reservations.find((r) => r.qrToken === token);
  if (res) {
    closeModal('modalMySlips');
    displayPickupPass(res);
  }
}

function cancelReservation(resId) {
  const state = getState();
  const index = state.reservations.findIndex((r) => r.id === resId);
  if (index === -1) return;

  const res = state.reservations[index];

  // Restore inventory
  res.items.forEach((item) => {
    if (item.isUsed) {
      const listing = state.usedListings.find((l) => l.id === item.listingId);
      if (listing) listing.status = 'available';
    } else {
      const book = state.books.find((b) => b.id === item.bookId);
      if (book) book.qtyReserved = Math.max(0, book.qtyReserved - 1);
    }
  });

  state.reservations.splice(index, 1);
  saveState();

  showToast('Reservation Cancelled', `Pickup slip ${resId} has been cancelled.`);
  openMySlipsModal();
  renderStudentCatalog();
  renderOwnerDashboard();
}

// =====================================================================
// Student View: Waitlist Join Modal (FR-04)
// =====================================================================
let activeWaitlistBookId = null;

function openWaitlistModal(bookId) {
  const state = getState();
  const book = state.books.find((b) => b.id === bookId);
  if (!book) return;

  activeWaitlistBookId = bookId;
  document.getElementById('waitlistBookTitle').innerText = book.title;
  document.getElementById('waitlistBookMeta').innerText = `${book.courseCode} • ${book.edition} • Mandated by Syllabus`;

  openModal('modalWaitlist');
}

function handleWaitlistSubmit(e) {
  e.preventDefault();
  if (!activeWaitlistBookId) return;

  const state = getState();
  const studentId = document.getElementById('waitlistStudentId').value.trim();
  const email = document.getElementById('waitlistEmail').value.trim();

  state.waitlist.push({
    id: Date.now(),
    bookId: activeWaitlistBookId,
    studentId: studentId,
    studentEmail: email,
    joinedAt: new Date().toISOString().replace('T', ' ').substring(0, 19)
  });

  state.notifications.unshift({
    id: Date.now(),
    title: 'Waitlist Registered',
    message: `You will be alerted when new stock arrives for book #${activeWaitlistBookId}.`,
    time: 'Just now',
    read: false
  });

  saveState();
  closeModal('modalWaitlist');
  showToast('Waitlist Joined', 'You will receive immediate notification once bookstore restocks.');
  renderNotifications();
}

// =====================================================================
// Student View: Resale Book Submission (FR-05)
// =====================================================================
function handleSellPriceChange() {
  const priceInput = document.getElementById('sellPrice');
  const feeDisplay = document.getElementById('sellFeeDisplay');
  const payoutDisplay = document.getElementById('sellPayoutDisplay');

  if (!priceInput) return;
  const price = parseFloat(priceInput.value) || 0;
  const fee = Math.round(price * 0.1);
  const payout = price - fee;

  if (feeDisplay) feeDisplay.innerText = `BDT ${fee.toLocaleString()}`;
  if (payoutDisplay) payoutDisplay.innerText = `BDT ${payout.toLocaleString()}`;
}

function handleSellSubmit(e) {
  e.preventDefault();
  const state = getState();

  const courseSelect = document.getElementById('sellCourse');
  const bookId = parseInt(courseSelect.value, 10);
  const condition = document.getElementById('sellCondition').value;
  const askingPrice = parseFloat(document.getElementById('sellPrice').value);

  const book = state.books.find((b) => b.id === bookId);

  const newListing = {
    id: state.usedListings.length + 1,
    bookId: bookId,
    sellerId: 3,
    sellerName: 'Senior Resale Student',
    sellerEmail: 'student1@campuspages.test',
    sellerStudentId: 'STU2024001',
    declaredCondition: condition,
    conditionGrade: condition,
    askingPrice: askingPrice,
    approvedPrice: askingPrice,
    status: 'pending_inspection',
    createdAt: new Date().toISOString().replace('T', ' ').substring(0, 19)
  };

  state.usedListings.push(newListing);

  state.notifications.unshift({
    id: Date.now(),
    title: 'Listing Awaiting Intake Inspection',
    message: `Listing for "${book ? book.title : 'Course Book'}" submitted. Please hand textbook to Level 3 counter.`,
    time: 'Just now',
    read: false
  });

  saveState();
  closeModal('modalSellBook');
  e.target.reset();

  showToast('Book Submitted for Intake', 'Drop off the physical textbook at Level 3 counter for condition grading.');
  renderOwnerDashboard();
  renderNotifications();
}

// =====================================================================
// Instructor View: Syllabus Adoption & Module Registration (FR-11)
// =====================================================================
function renderInstructorTable() {
  const state = getState();
  const tbody = document.getElementById('instructorSyllabusTable');
  if (!tbody) return;

  tbody.innerHTML = '';

  state.books.forEach((book) => {
    const row = document.createElement('tr');
    row.className = 'hover:bg-slate-50 transition-all';
    row.innerHTML = `
      <td class="py-3 px-3">
        <span class="font-mono font-bold text-slate-800 text-xs">${book.courseCode}</span>
        <span class="block text-[11px] text-slate-500">${book.courseTitle}</span>
      </td>
      <td class="py-3 px-3">
        <span class="font-semibold text-slate-900 text-xs">${book.title}</span>
        <span class="block text-[11px] text-indigo-700 font-semibold">${book.edition}</span>
        <span class="block text-[10px] font-mono text-slate-400 mt-0.5">ISBN: ${book.isbn}</span>
      </td>
      <td class="py-3 px-3 text-center">
        <span class="font-extrabold text-slate-800 text-xs">${book.enrolment}</span>
        <span class="block text-[10px] text-slate-400">Target: ${book.term}</span>
      </td>
      <td class="py-3 px-3">
        <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-800 border border-emerald-200 inline-flex items-center gap-1">
          <svg class="w-3 h-3 text-emerald-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
          Locked (FAC001)
        </span>
      </td>
      <td class="py-3 px-3 text-right">
        <button onclick="lockSyllabusAlert('${book.title}')" class="text-xs font-bold text-blue-600 hover:text-blue-800 hover:underline">
          View Lock
        </button>
      </td>
    `;
    tbody.appendChild(row);
  });
}

function handleSyllabusSubmit(e) {
  e.preventDefault();
  const state = getState();

  const courseSelect = document.getElementById('insCourse');
  const courseCode = courseSelect.options[courseSelect.selectedIndex].text.split(' - ')[0];
  const courseTitle = courseSelect.options[courseSelect.selectedIndex].text.split(' - ')[1].split(' (')[0];
  const title = document.getElementById('insTitle').value.trim();
  const author = document.getElementById('insAuthor').value.trim();
  const edition = document.getElementById('insEdition').value.trim();
  const isbn = document.getElementById('insIsbn').value.trim() || '978-0130000000';
  const enrolment = parseInt(document.getElementById('insEnrolment').value, 10);
  const courseId = parseInt(courseSelect.value, 10);

  const matchedCourse = state.courses.find((c) => c.id === courseId) || { programmeId: 1, semester: 4 };

  const newBook = {
    id: state.books.length + 1,
    courseId: courseId,
    courseCode: courseCode,
    courseTitle: courseTitle,
    programmeId: matchedCourse.programmeId,
    semester: matchedCourse.semester,
    title: title,
    author: author,
    edition: edition,
    isbn: isbn,
    newPrice: 1900,
    qtyNew: 0,
    qtyReserved: 0,
    enrolment: enrolment,
    term: 'September 2026',
    confirmedBy: 'Dr. Syllabus Instructor (FAC001)',
    confirmedAt: new Date().toISOString().replace('T', ' ').substring(0, 19)
  };

  state.books.push(newBook);

  state.notifications.unshift({
    id: Date.now(),
    title: `Syllabus Adopted: ${courseCode}`,
    message: `Faculty registered "${title}" for upcoming term. Wholesale forecast updated.`,
    time: 'Just now',
    read: false
  });

  saveState();
  e.target.reset();

  renderInstructorTable();
  renderStudentCatalog();
  renderOwnerDashboard();
  renderNotifications();

  showToast('Syllabus Adoption Locked', `Added "${title}" to official textbook requirements for ${courseCode}.`);
}

function lockSyllabusAlert(title) {
  showToast('Syllabus Locked', `"${title}" is locked for Term September 2026. Feeds into FR-13 Forecast Engine.`);
}

// =====================================================================
// Store Owner / Admin Dashboard (FR-13, FR-14, FR-15)
// =====================================================================
function switchAdminTab(tabName) {
  ['forecast', 'intake', 'pos', 'ledger'].forEach((t) => {
    const btn = document.getElementById(`tab-btn-${t}`);
    const pane = document.getElementById(`admin-tab-${t}`);
    if (!btn || !pane) return;

    if (t === tabName) {
      btn.className = 'px-4 py-2 text-xs font-bold rounded-xl bg-slate-900 text-white shadow-sm transition-all';
      pane.classList.remove('hidden');
    } else {
      btn.className = 'px-4 py-2 text-xs font-bold rounded-xl text-slate-600 hover:text-slate-900 transition-all';
      pane.classList.add('hidden');
    }
  });
}

function updateForecastParams() {
  const state = getState();
  const buyRateInput = document.getElementById('forecastBuyRateInput');
  const bufferInput = document.getElementById('forecastBufferInput');

  if (buyRateInput) state.forecastParams.buyRate = parseFloat(buyRateInput.value) || 0.65;
  if (bufferInput) state.forecastParams.buffer = parseInt(bufferInput.value, 10) || 5;

  saveState();
  renderForecastTable();
  updateOwnerKPIs();
  showToast('Forecast Parameters Updated', `Model recalculated with Buy Rate: ${state.forecastParams.buyRate}.`);
}

function renderOwnerDashboard() {
  updateOwnerKPIs();
  renderForecastTable();
  renderIntakeTable();
  renderLedgerTable();
}

function updateOwnerKPIs() {
  const state = getState();

  // Pending Pickups
  const pendingCount = state.reservations.filter(
    (r) => r.status === 'unpaid_reserved' || r.status === 'paid_reserved'
  ).length;
  const kpiPending = document.getElementById('kpiPendingPickups');
  if (kpiPending) kpiPending.innerText = pendingCount;

  // Used Resale Intake Queue
  const intakeCount = state.usedListings.filter((ul) => ul.status === 'pending_inspection').length;
  const kpiIntake = document.getElementById('kpiIntakeQueue');
  if (kpiIntake) kpiIntake.innerText = intakeCount;

  // Tab badge for intake
  const intakeTabBadge = document.getElementById('intakeTabCount');
  if (intakeTabBadge) intakeTabBadge.innerText = `(${intakeCount})`;

  // Stock Deficits
  let deficitCount = 0;
  state.books.forEach((b) => {
    const usedStock = state.usedListings.filter((ul) => ul.bookId === b.id && ul.status === 'available').length;
    const grossDemand = Math.round(b.enrolment * state.forecastParams.buyRate + state.forecastParams.buffer);
    const suggestedPO = Math.max(0, grossDemand - usedStock - b.qtyNew);
    if (suggestedPO > 0 || b.qtyNew <= b.qtyReserved) {
      deficitCount++;
    }
  });
  const kpiDeficits = document.getElementById('kpiDeficits');
  if (kpiDeficits) kpiDeficits.innerText = deficitCount;

  // Gross Turnover
  const grossTurnover = state.transactions.reduce((sum, t) => sum + t.amount, 0);
  const platformFees = state.transactions.reduce((sum, t) => sum + (t.fee || 0), 0);
  const kpiTurnover = document.getElementById('kpiTurnover');
  if (kpiTurnover) kpiTurnover.innerText = `BDT ${grossTurnover.toLocaleString()}`;
  const kpiFees = document.getElementById('kpiFees');
  if (kpiFees) kpiFees.innerText = `+BDT ${platformFees.toLocaleString()} fee`;
}

// Render FR-13 Forecasting Table
function renderForecastTable() {
  const state = getState();
  const tbody = document.getElementById('forecastTableBody');
  if (!tbody) return;

  tbody.innerHTML = '';

  state.books.forEach((b) => {
    const availableUsed = state.usedListings.filter((ul) => ul.bookId === b.id && ul.status === 'available').length;
    const grossDemand = Math.round(b.enrolment * state.forecastParams.buyRate + state.forecastParams.buffer);
    const suggestedOrder = Math.max(0, grossDemand - availableUsed - b.qtyNew);
    const estReorderCost = suggestedOrder * (b.newPrice * 0.7); // 30% wholesale discount

    const row = document.createElement('tr');
    row.className = 'hover:bg-slate-50 transition-all text-xs';
    row.innerHTML = `
      <td class="py-3 px-3 font-mono font-bold text-slate-800">${b.courseCode}</td>
      <td class="py-3 px-3">
        <span class="font-semibold text-slate-900">${b.title}</span>
        <span class="block text-[10px] text-slate-500">${b.edition}</span>
      </td>
      <td class="py-3 px-3 text-center font-bold text-slate-700">${b.enrolment}</td>
      <td class="py-3 px-3 text-center">
        <span class="${b.qtyNew === 0 ? 'text-rose-600 font-extrabold' : 'text-slate-700 font-semibold'}">${b.qtyNew}</span>
        <span class="text-slate-400 text-[10px] block">(${b.qtyReserved} held)</span>
      </td>
      <td class="py-3 px-3 text-center font-semibold text-emerald-700">${availableUsed}</td>
      <td class="py-3 px-3 text-center font-bold text-blue-900 bg-blue-50/50">${grossDemand} Units</td>
      <td class="py-3 px-3 text-center font-black ${
        suggestedOrder > 0 ? 'text-emerald-700 bg-emerald-50' : 'text-slate-400 bg-slate-50'
      }">
        ${suggestedOrder > 0 ? suggestedOrder + ' Units' : '0 (Sufficient)'}
      </td>
      <td class="py-3 px-3 text-right font-mono font-bold text-slate-800">BDT ${Math.round(
        estReorderCost
      ).toLocaleString()}</td>
    `;
    tbody.appendChild(row);
  });
}

// Export Wholesale Purchase Order (CSV generation)
function exportWholesalePO() {
  const state = getState();
  let csvContent = 'data:text/csv;charset=utf-8,';
  csvContent += 'Course Code,Book Title,Edition,ISBN,Enrolment,Stock On Hand,Used Stock,Gross Demand,Suggested PO,Wholesale Unit Price,Total Cost (BDT)\n';

  state.books.forEach((b) => {
    const availableUsed = state.usedListings.filter((ul) => ul.bookId === b.id && ul.status === 'available').length;
    const grossDemand = Math.round(b.enrolment * state.forecastParams.buyRate + state.forecastParams.buffer);
    const suggestedOrder = Math.max(0, grossDemand - availableUsed - b.qtyNew);
    const unitWholesale = Math.round(b.newPrice * 0.7);
    const totalCost = suggestedOrder * unitWholesale;

    csvContent += `"${b.courseCode}","${b.title}","${b.edition}","${b.isbn}",${b.enrolment},${b.qtyNew},${availableUsed},${grossDemand},${suggestedOrder},${unitWholesale},${totalCost}\n`;
  });

  const encodedUri = encodeURI(csvContent);
  const link = document.createElement('a');
  link.setAttribute('href', encodedUri);
  link.setAttribute('download', 'CampusPages_Wholesale_PO_September2026.csv');
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);

  showToast('Wholesale PO Exported', 'Downloaded CampusPages_Wholesale_PO_September2026.csv');
}

// Render FR-14 Used Book Intake Desk Table
function renderIntakeTable() {
  const state = getState();
  const tbody = document.getElementById('intakeTableBody');
  if (!tbody) return;

  tbody.innerHTML = '';
  const pending = state.usedListings.filter((ul) => ul.status === 'pending_inspection');

  if (pending.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="8" class="text-center py-8 text-xs text-slate-400 italic">
          Used textbook intake queue is clear. No student submissions awaiting physical grading.
        </td>
      </tr>
    `;
    return;
  }

  pending.forEach((listing) => {
    const book = state.books.find((b) => b.id === listing.bookId) || {
      title: 'Course Book',
      edition: 'Latest Edition',
      courseCode: 'COURSE'
    };

    const row = document.createElement('tr');
    row.className = 'hover:bg-slate-50 transition-all text-xs';
    row.innerHTML = `
      <td class="py-3 px-3 font-mono font-bold text-slate-800">#LST-${String(listing.id).padStart(3, '0')}</td>
      <td class="py-3 px-3">
        <span class="font-semibold text-slate-800">${listing.sellerName}</span>
        <span class="block text-[10px] text-slate-400">${listing.sellerStudentId}</span>
      </td>
      <td class="py-3 px-3">
        <span class="font-semibold text-slate-900">${book.title}</span>
        <span class="block text-[10px] text-slate-500">${book.edition} • ${book.courseCode}</span>
      </td>
      <td class="py-3 px-3">
        <span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-100 text-amber-800 uppercase">${listing.declaredCondition}</span>
      </td>
      <td class="py-3 px-3 font-bold text-slate-700">BDT ${listing.askingPrice.toLocaleString()}</td>
      <td class="py-3 px-3">
        <select id="intakeGrade_${listing.id}" class="bg-slate-50 border border-slate-200 rounded-lg px-2 py-1 text-xs font-semibold text-slate-800">
          <option value="good" ${listing.conditionGrade === 'good' ? 'selected' : ''}>Good (Minor wear)</option>
          <option value="like_new" ${listing.conditionGrade === 'like_new' ? 'selected' : ''}>Like New (Pristine)</option>
          <option value="fair" ${listing.conditionGrade === 'fair' ? 'selected' : ''}>Fair (Highlighting)</option>
          <option value="acceptable" ${listing.conditionGrade === 'acceptable' ? 'selected' : ''}>Acceptable (Heavy use)</option>
        </select>
      </td>
      <td class="py-3 px-3">
        <div class="flex items-center gap-1">
          <span class="text-slate-400 font-bold">BDT</span>
          <input type="number" id="intakePrice_${listing.id}" value="${listing.approvedPrice || listing.askingPrice}" 
                 class="w-20 px-2 py-1 bg-slate-50 border border-slate-200 rounded-lg text-xs font-bold text-slate-900">
        </div>
      </td>
      <td class="py-3 px-3 text-right space-x-1.5 whitespace-nowrap">
        <button onclick="approveUsedListing(${listing.id})" 
                class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-lg text-xs shadow-sm transition-all">
          Approve & List
        </button>
        <button onclick="rejectUsedListing(${listing.id})" 
                class="px-2.5 py-1.5 bg-slate-100 hover:bg-rose-100 text-slate-600 hover:text-rose-700 font-bold rounded-lg text-xs transition-all">
          Reject
        </button>
      </td>
    `;
    tbody.appendChild(row);
  });
}

function approveUsedListing(listingId) {
  const state = getState();
  const listing = state.usedListings.find((ul) => ul.id === listingId);
  if (!listing) return;

  const gradeSelect = document.getElementById(`intakeGrade_${listingId}`);
  const priceInput = document.getElementById(`intakePrice_${listingId}`);

  listing.conditionGrade = gradeSelect ? gradeSelect.value : listing.declaredCondition;
  listing.approvedPrice = priceInput ? parseFloat(priceInput.value) || listing.askingPrice : listing.askingPrice;
  listing.status = 'available';

  const book = state.books.find((b) => b.id === listing.bookId);

  state.notifications.unshift({
    id: Date.now(),
    title: 'Used Textbook Verified & Live',
    message: `Listing #LST-${listing.id} for "${book ? book.title : 'Book'}" is now live at BDT ${listing.approvedPrice}.`,
    time: 'Just now',
    read: false
  });

  saveState();
  renderIntakeTable();
  updateOwnerKPIs();
  renderStudentCatalog();
  renderForecastTable();
  renderNotifications();

  showToast('Intake Approved & Published', `Textbook is now listed on student catalog at BDT ${listing.approvedPrice}.`);
}

function rejectUsedListing(listingId) {
  const state = getState();
  const listing = state.usedListings.find((ul) => ul.id === listingId);
  if (!listing) return;

  listing.status = 'rejected';

  state.notifications.unshift({
    id: Date.now(),
    title: 'Listing Inspection Failed',
    message: `Listing #LST-${listing.id} does not meet syllabus or physical requirements. Student notified.`,
    time: 'Just now',
    read: false
  });

  saveState();
  renderIntakeTable();
  updateOwnerKPIs();
  renderNotifications();

  showToast('Listing Rejected', 'Rejection recorded. Notification dispatched to student for book pickup.');
}

// =====================================================================
// FR-15: POS QR Scanner Simulator & Counter Settlement Desk
// =====================================================================
function fillPosToken(token) {
  const input = document.getElementById('posTokenInput');
  if (input) input.value = token;
  verifyPickupToken();
}

function verifyPickupToken() {
  const input = document.getElementById('posTokenInput');
  const resBox = document.getElementById('posResultBox');
  if (!input || !resBox) return;

  const token = input.value.trim();
  resBox.classList.remove('hidden');

  const state = getState();
  const res = state.reservations.find((r) => r.qrToken === token);

  if (!res) {
    resBox.className = 'p-4 rounded-2xl border border-rose-300 bg-rose-50 text-xs space-y-1 fade-enter text-rose-800';
    resBox.innerHTML = `
      <div class="flex items-center gap-2 font-bold">
        <svg class="w-4 h-4 text-rose-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
        <span>Invalid or Expired QR Slip</span>
      </div>
      <p class="text-slate-600">No active campus reservation found matching token: <code>${token}</code></p>
    `;
    return;
  }

  const isCashDue = res.status === 'unpaid_reserved';
  const isPrepaid = res.status === 'paid_reserved';
  const isFulfilled = res.status === 'fulfilled';

  if (isFulfilled) {
    resBox.className = 'p-4 rounded-2xl border border-blue-300 bg-blue-50 text-xs space-y-2 fade-enter text-blue-900';
    resBox.innerHTML = `
      <div class="flex items-center justify-between font-bold">
        <span>Reservation Already Fulfilled: ${res.id}</span>
        <span class="px-2 py-0.5 bg-blue-200 text-blue-800 rounded-full text-[10px]">HANDOVER COMPLETE</span>
      </div>
      <p class="text-slate-700">Student: <strong>${res.studentName}</strong> (${res.studentId})</p>
      <p class="text-slate-500">This QR pass has already been processed and inventory was decremented.</p>
    `;
    return;
  }

  if (isCashDue) {
    resBox.className = 'p-4 rounded-2xl border border-amber-300 bg-amber-50 text-xs space-y-2 fade-enter';
    resBox.innerHTML = `
      <div class="flex items-center justify-between font-bold text-amber-900">
        <div class="flex items-center gap-2">
          <span class="w-2.5 h-2.5 rounded-full bg-amber-500"></span>
          <span>Valid Reservation: ${res.id}</span>
        </div>
        <span class="px-2.5 py-0.5 bg-amber-200 text-amber-900 rounded-full text-[10px] font-extrabold uppercase tracking-wide">Unpaid (Cash Due)</span>
      </div>
      <p class="text-slate-700">Student: <strong>${res.studentName}</strong> (${res.studentId} • ${res.programCode})</p>
      
      <div class="border-t border-amber-200 pt-2 space-y-1 text-slate-600">
        ${res.items
          .map(
            (i) => `
          <div class="flex justify-between">
            <span>${i.title} (${i.isUsed ? 'Used' : 'New'})</span>
            <span class="font-bold">BDT ${i.price.toLocaleString()}</span>
          </div>
        `
          )
          .join('')}
        <div class="border-t border-amber-200 pt-1.5 flex justify-between font-extrabold text-slate-900 text-sm">
          <span>Total Cash to Collect:</span>
          <span class="text-amber-900">BDT ${res.totalAmount.toLocaleString()}.00</span>
        </div>
      </div>

      <button onclick="completePickup('${res.id}', ${res.totalAmount})" 
              class="w-full mt-2 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl transition-all shadow-sm flex items-center justify-center gap-2">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
        <span>Collect Cash & Complete Handover</span>
      </button>
    `;
  } else if (isPrepaid) {
    resBox.className = 'p-4 rounded-2xl border border-emerald-300 bg-emerald-50 text-xs space-y-2 fade-enter';
    resBox.innerHTML = `
      <div class="flex items-center justify-between font-bold text-emerald-900">
        <div class="flex items-center gap-2">
          <span class="w-2.5 h-2.5 rounded-full bg-emerald-500"></span>
          <span>Valid Reservation: ${res.id}</span>
        </div>
        <span class="px-2.5 py-0.5 bg-emerald-200 text-emerald-900 rounded-full text-[10px] font-extrabold uppercase tracking-wide">Paid (${res.paymentMethod.toUpperCase()})</span>
      </div>
      <p class="text-slate-700">Student: <strong>${res.studentName}</strong> (${res.studentId} • ${res.programCode})</p>
      
      <div class="border-t border-emerald-200 pt-2 space-y-1 text-slate-600">
        ${res.items
          .map(
            (i) => `
          <div class="flex justify-between">
            <span>${i.title} (${i.isUsed ? 'Used' : 'New'})</span>
            <span class="font-bold text-emerald-900">BDT ${i.price.toLocaleString()} (PAID)</span>
          </div>
        `
          )
          .join('')}
      </div>

      <button onclick="completePickup('${res.id}', 0)" 
              class="w-full mt-2 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl transition-all shadow-sm flex items-center justify-center gap-2">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
        <span>Confirm Handover & Release Textbooks</span>
      </button>
    `;
  }
}

function completePickup(resId, cashCollected) {
  const state = getState();
  const res = state.reservations.find((r) => r.id === resId);
  if (!res) return;

  // 1. Decrement physical inventory
  res.items.forEach((item) => {
    if (item.isUsed) {
      const listing = state.usedListings.find((l) => l.id === item.listingId);
      if (listing) listing.status = 'sold';
    } else {
      const book = state.books.find((b) => b.id === item.bookId);
      if (book) {
        book.qtyNew = Math.max(0, book.qtyNew - 1);
        book.qtyReserved = Math.max(0, book.qtyReserved - 1);
      }
    }
  });

  // 2. Mark reservation fulfilled
  res.status = 'fulfilled';

  // 3. If cash was collected now, add to immutable ledger
  if (cashCollected > 0) {
    state.transactions.unshift({
      id: `TXN-2026-${String(state.transactions.length + 1).padStart(3, '0')}`,
      reservationId: res.id,
      listingId: null,
      type: 'payment',
      method: 'CASH',
      amount: cashCollected,
      fee: Math.round(cashCollected * 0.1),
      sellerPayout: Math.round(cashCollected * 0.9),
      createdAt: new Date().toISOString().replace('T', ' ').substring(0, 19),
      details: `Cash settlement at counter for reservation ${res.id}`
    });
  }

  // 4. Dispatch notification
  state.notifications.unshift({
    id: Date.now(),
    title: `Order Handover Completed: ${res.id}`,
    message: `Items received by ${res.studentName}. Stock decremented in 3NF schema.`,
    time: 'Just now',
    read: false
  });

  saveState();

  const resBox = document.getElementById('posResultBox');
  if (resBox) {
    resBox.className = 'p-4 rounded-xl border border-emerald-300 bg-white text-emerald-800 text-xs font-bold space-y-1 fade-enter';
    resBox.innerHTML = `
      <div class="flex items-center gap-2">
        <svg class="w-5 h-5 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
        <span>Order ${resId} Handover Complete!</span>
      </div>
      <p class="text-slate-600 font-normal">Physical stock decremented. Transaction committed to immutable audit ledger.</p>
    `;
  }

  updateOwnerKPIs();
  renderForecastTable();
  renderStudentCatalog();
  renderLedgerTable();
  renderNotifications();

  showToast('Order Fulfilled', cashCollected > 0 ? `Cash settlement of BDT ${cashCollected} logged.` : 'Prepaid pickup released.');
}

// Render Transaction & Audit Ledger (FR-15, schema.sql transactions)
function renderLedgerTable() {
  const state = getState();
  const tbody = document.getElementById('ledgerTableBody');
  if (!tbody) return;

  tbody.innerHTML = '';

  if (state.transactions.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="6" class="text-center py-6 text-xs text-slate-400 italic">No transactions recorded yet.</td>
      </tr>
    `;
    return;
  }

  state.transactions.forEach((txn) => {
    const row = document.createElement('tr');
    row.className = 'hover:bg-slate-50 transition-all text-xs';
    row.innerHTML = `
      <td class="py-2.5 px-3 font-mono font-bold text-slate-800">${txn.id}</td>
      <td class="py-2.5 px-3 font-mono text-slate-600">${txn.reservationId || 'N/A'}</td>
      <td class="py-2.5 px-3">
        <span class="px-2 py-0.5 rounded-full text-[10px] font-bold ${
          txn.method === 'CASH' ? 'bg-amber-100 text-amber-800' : 'bg-emerald-100 text-emerald-800'
        }">${txn.method}</span>
      </td>
      <td class="py-2.5 px-3 font-bold text-slate-900">BDT ${txn.amount.toLocaleString()}</td>
      <td class="py-2.5 px-3 text-slate-500">${txn.details}</td>
      <td class="py-2.5 px-3 text-slate-400 font-mono text-[11px]">${txn.createdAt}</td>
    `;
    tbody.appendChild(row);
  });
}

// =====================================================================
// Notifications Menu & Toast System
// =====================================================================
function toggleNotifications() {
  const menu = document.getElementById('notificationMenu');
  if (menu) menu.classList.toggle('hidden');
}

function renderNotifications() {
  const state = getState();
  const list = document.getElementById('notificationList');
  const badge = document.getElementById('notificationBadge');

  if (!list) return;
  list.innerHTML = '';

  const unreadCount = state.notifications.filter((n) => !n.read).length;

  if (badge) {
    if (unreadCount > 0) {
      badge.classList.remove('hidden');
    } else {
      badge.classList.add('hidden');
    }
  }

  if (state.notifications.length === 0) {
    list.innerHTML = '<div class="py-4 text-center text-xs text-slate-400 italic">No alerts.</div>';
    return;
  }

  state.notifications.slice(0, 10).forEach((n) => {
    const item = document.createElement('div');
    item.className = `p-2.5 rounded-xl text-xs border ${
      n.read ? 'bg-slate-50 border-slate-100' : 'bg-blue-50/70 border-blue-100'
    }`;
    item.innerHTML = `
      <p class="font-bold text-slate-900">${n.title}</p>
      <p class="text-slate-600 text-[11px] mt-0.5">${n.message}</p>
      <span class="text-[9px] text-slate-400 mt-1 block">${n.time}</span>
    `;
    list.appendChild(item);
  });
}

function markAllNotificationsRead() {
  const state = getState();
  state.notifications.forEach((n) => (n.read = true));
  saveState();
  renderNotifications();
  showToast('Alerts Cleared', 'All campus notifications marked as read.');
}

function showToast(title, message) {
  const container = document.getElementById('toastContainer');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className =
    'bg-slate-900 text-white px-4 py-3 rounded-2xl shadow-2xl border border-slate-700 max-w-sm pointer-events-auto fade-enter flex items-start gap-3';
  toast.innerHTML = `
    <div class="w-2 h-2 rounded-full bg-blue-400 mt-1.5 flex-shrink-0"></div>
    <div class="flex-1">
      <p class="text-xs font-bold text-white">${title}</p>
      <p class="text-[11px] text-slate-300 mt-0.5 leading-relaxed">${message}</p>
    </div>
  `;

  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(10px)';
    toast.style.transition = 'all 0.3s ease';
    setTimeout(() => toast.remove(), 300);
  }, 4200);
}

// Reset Demo State
function resetDemoData() {
  if (confirm('Reset CampusPages to the initial database seed state?')) {
    store.reset();
    location.reload();
  }
}

// =====================================================================
// Modal Helper Functions
// =====================================================================
function openModal(id) {
  const modal = document.getElementById(id);
  if (modal) modal.classList.remove('hidden');
}

function closeModal(id) {
  const modal = document.getElementById(id);
  if (modal) modal.classList.add('hidden');
}

// Close modal when clicking outside box
window.addEventListener('click', (e) => {
  if (e.target.classList.contains('backdrop-blur-sm')) {
    e.target.classList.add('hidden');
  }
});

// Close modal on Escape key
window.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    document.querySelectorAll('.fixed.inset-0:not(.hidden)').forEach((m) => m.classList.add('hidden'));
    const notifMenu = document.getElementById('notificationMenu');
    if (notifMenu && !notifMenu.classList.contains('hidden')) {
      notifMenu.classList.add('hidden');
    }
  }
});

// =====================================================================
// Initialize Page on DOM Loaded
// =====================================================================
window.addEventListener('DOMContentLoaded', () => {
  const state = getState();

  // Set initial role
  switchRole(state.role || 'student');

  // Render initial components
  renderStudentCatalog();
  renderBundleHero();
  renderInstructorTable();
  renderOwnerDashboard();
  renderNotifications();

  // Live search debounced listener
  const searchInput = document.getElementById('globalSearch');
  if (searchInput) {
    searchInput.addEventListener('input', () => {
      renderStudentCatalog();
    });
  }
});
