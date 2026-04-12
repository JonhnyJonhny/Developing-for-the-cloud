/* ============================================================
   Budget Tracker — app.js
   All UI logic: rendering, navigation, modal, reports pipeline.
   Depends on: data.js (transactions, icons, catColors, iconMap)
   ============================================================ */

/* ── State ── */
let txType          = "expense";
let currentFilter   = "all";
let searchQuery     = "";
let reportInProgress = false;
let toastTimer;

/* ============================================================
   Rendering helpers
   ============================================================ */

/**
 * Build HTML string for a single transaction row.
 * @param {object} tx
 * @returns {string}
 */
function txHTML(tx) {
  const c    = catColors[tx.category] || catColors["Other"];
  const isPos = tx.amount > 0;
  return `
    <div class="tx-item">
      <div class="tx-icon" style="background:${c.bg};color:${c.color}">
        ${icons[tx.icon] || icons.wallet}
      </div>
      <div class="tx-info">
        <div class="tx-name">${tx.name}</div>
        <div class="tx-meta">${tx.category} · ${tx.date}</div>
      </div>
      <div class="tx-amount ${isPos ? "positive" : "negative"}">
        ${isPos ? "+" : ""}£${Math.abs(tx.amount).toFixed(2)}
      </div>
    </div>`;
}

/** Render the 5 most recent transactions on the Dashboard. */
function renderRecentTx() {
  document.getElementById("recent-tx-list").innerHTML =
    transactions.slice(0, 5).map(txHTML).join("");
}

/** Render filtered & searched transactions on the Transactions page. */
function renderFullTx() {
  const filtered = transactions.filter(t => {
    const matchFilter =
      currentFilter === "all" ||
      t.type === currentFilter ||
      t.category.toLowerCase() === currentFilter;

    const matchSearch =
      t.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      t.category.toLowerCase().includes(searchQuery.toLowerCase());

    return matchFilter && matchSearch;
  });

  if (!filtered.length) {
    document.getElementById("full-tx-list").innerHTML =
      `<div style="text-align:center;padding:30px;color:var(--text3);font-size:13px">No transactions found</div>`;
    return;
  }

  /* Group by date label */
  const grouped = {};
  filtered.forEach(t => {
    if (!grouped[t.date]) grouped[t.date] = [];
    grouped[t.date].push(t);
  });

  let html = "";
  for (const date in grouped) {
    html += `<div class="tx-group-label">${date}</div>`;
    html += grouped[date].map(txHTML).join("");
  }

  document.getElementById("full-tx-list").innerHTML = html;
  document.getElementById("tx-count").textContent   = filtered.length;
}

/* ============================================================
   Navigation
   ============================================================ */

/**
 * Switch to a named page and mark the triggering nav item active.
 * @param {string} name  - page id suffix (e.g. "dashboard")
 * @param {Element} el   - the nav button that was clicked
 */
function showPage(name, el) {
  document.querySelectorAll(".page").forEach(p => p.classList.remove("active"));
  document.querySelectorAll(".nav-item").forEach(n => n.classList.remove("active"));

  document.getElementById("page-" + name).classList.add("active");
  if (el) el.classList.add("active");

  if (name === "transactions") renderFullTx();
}

/* ============================================================
   Transaction filters & search
   ============================================================ */

/** Called on search input. */
function filterTx(val) {
  searchQuery = val;
  renderFullTx();
}

/**
 * Set the active category filter.
 * @param {string}  f   - filter key
 * @param {Element} btn - clicked filter button
 */
function setFilter(f, btn) {
  currentFilter = f;
  document.querySelectorAll(".filter-btn").forEach(b => b.classList.remove("active"));
  btn.classList.add("active");
  renderFullTx();
}

/* ============================================================
   Add-transaction modal
   ============================================================ */

function openModal() {
  document.getElementById("modal").classList.add("show");
  document.getElementById("tx-name").value   = "";
  document.getElementById("tx-amount").value = "";
}

function closeModal() {
  document.getElementById("modal").classList.remove("show");
}

/**
 * Toggle the expense / income pill inside the modal.
 * @param {string} t - "expense" | "income"
 */
function setTxType(t) {
  txType = t;
  const eBtn = document.getElementById("btn-expense");
  const iBtn = document.getElementById("btn-income");
  eBtn.className = "type-btn" + (t === "expense" ? " active-expense" : "");
  iBtn.className = "type-btn" + (t === "income"  ? " active-income"  : "");
}

/** Validate, create, and prepend a new transaction. */
function addTransaction() {
  const name   = document.getElementById("tx-name").value.trim();
  const amount = parseFloat(document.getElementById("tx-amount").value);
  const cat    = document.getElementById("tx-category").value;

  if (!name || isNaN(amount)) {
    showToast("Please fill in all fields", "warning");
    return;
  }

  const finalAmt  = txType === "expense" ? -Math.abs(amount) : Math.abs(amount);
  const finalCat  = txType === "income"  ? "Income"           : cat;

  const newTx = {
    id:       Date.now(),
    name,
    category: finalCat,
    amount:   finalAmt,
    date:     "Just now",
    type:     txType,
    icon:     iconMap[cat] || "wallet",
  };

  transactions.unshift(newTx);

  /* Update badges */
  document.getElementById("tx-badge").textContent = transactions.length;
  document.getElementById("tx-count").textContent  = transactions.length;

  updateStats();
  renderRecentTx();
  renderFullTx();
  closeModal();
  showToast("Transaction added successfully", "success");
}

/* ============================================================
   Dashboard stat cards
   ============================================================ */

/** Recalculate and repaint the four stat cards. */
function updateStats() {
  const income   = transactions.filter(t => t.amount > 0)
                               .reduce((s, t) => s + t.amount, 0);
  const expenses = Math.abs(
    transactions.filter(t => t.amount < 0)
                .reduce((s, t) => s + t.amount, 0)
  );
  const balance  = income - expenses;
  const rate     = Math.round((balance / income) * 100);

  document.getElementById("stat-balance").textContent  = `£${balance.toFixed(0)}`;
  document.getElementById("stat-income").textContent   = `£${income.toFixed(0)}`;
  document.getElementById("stat-expenses").textContent = `£${expenses.toFixed(0)}`;
  document.getElementById("stat-savings").textContent  = `${rate}%`;
}

/* ============================================================
   Reports page
   ============================================================ */

/**
 * Highlight the chosen report type card.
 * @param {Element} el
 */
function selectReport(el) {
  document.querySelectorAll(".report-option").forEach(b => b.classList.remove("selected"));
  el.classList.add("selected");
}

/**
 * Simulate the AWS pipeline with animated step-by-step status.
 * Replace the setTimeout delays with real fetch() calls to your
 * API Gateway endpoint and poll for Lambda / SNS completion.
 */
async function generateReport() {
  if (reportInProgress) return;
  reportInProgress = true;

  const btn  = document.getElementById("gen-btn");
  const card = document.getElementById("status-card");

  card.classList.add("visible");
  btn.disabled  = true;
  btn.innerHTML = `
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
         class="spinning" style="width:16px;height:16px">
      <path d="M21 12a9 9 0 11-6.219-8.56"/>
    </svg>
    Processing...`;

  const steps = [
    { id: 1, name: "Request received",      time: 800  },
    { id: 2, name: "Queued in SQS",         time: 1400 },
    { id: 3, name: "Lambda executing",      time: 2800 },
    { id: 4, name: "Saved to S3",           time: 1200 },
    { id: 5, name: "SNS notification sent", time: 600  },
  ];

  for (const s of steps) {
    const iconEl  = document.getElementById(`step${s.id}-icon`);
    const nameEl  = document.getElementById(`step${s.id}-name`);

    /* Active (spinning) state */
    iconEl.className = "step-icon active";
    iconEl.innerHTML = `
      <svg viewBox="0 0 24 24" fill="none" stroke="var(--blue)" stroke-width="2" class="spinning">
        <path d="M21 12a9 9 0 11-6.219-8.56"/>
      </svg>`;
    nameEl.textContent = s.name;
    showToast(s.name + "...", "info");

    /* Simulate async work */
    await new Promise(r => setTimeout(r, s.time));

    /* Done state */
    iconEl.className = "step-icon done";
    iconEl.innerHTML = `
      <svg viewBox="0 0 24 24" fill="none" stroke="var(--green)" stroke-width="2.5">
        <polyline points="20 6 9 17 4 12"/>
      </svg>`;
    document.getElementById(`step${s.id}-time`).textContent = "✓";
  }

  /* Bump alert badge */
  const alertBadge = document.getElementById("alert-badge");
  alertBadge.textContent = (parseInt(alertBadge.textContent) || 0) + 1;

  showToast("Report ready! Check your email.", "success");

  btn.disabled  = false;
  btn.innerHTML = `
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="width:16px;height:16px">
      <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/>
    </svg>
    Generate another report`;

  reportInProgress = false;
}

/* ============================================================
   Toast notifications
   ============================================================ */

const toastIcons = {
  success: `<polyline points="20 6 9 17 4 12"/>`,
  info:    `<circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>`,
  warning: `<path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
            <line x1="12" y1="9" x2="12" y2="13"/>
            <line x1="12" y1="17" x2="12.01" y2="17"/>`,
};

/**
 * Display a temporary toast message.
 * @param {string} msg
 * @param {"success"|"info"|"warning"} type
 */
function showToast(msg, type = "success") {
  const toast   = document.getElementById("toast");
  const iconSvg = document.getElementById("toast-icon-svg");

  document.getElementById("toast-msg").textContent = msg;
  toast.className = `toast ${type}`;
  iconSvg.innerHTML = toastIcons[type] || toastIcons.success;

  void toast.offsetWidth;          /* Force reflow to restart CSS transition */
  toast.classList.add("show");

  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove("show"), 3500);
}

/* ============================================================
   Initialise on DOMContentLoaded
   ============================================================ */
document.addEventListener("DOMContentLoaded", () => {
  renderRecentTx();
  renderFullTx();
});
