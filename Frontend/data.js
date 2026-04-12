/* ============================================================
   Budget Tracker — data.js
   Seed transactions, icon SVGs, and category colour map.
   ============================================================ */

const transactions = [
  { id: 1, name: "Monthly salary",       category: "Income",        amount:  5200.00, date: "Today",       type: "income",  icon: "wallet"   },
  { id: 2, name: "Whole Foods Market",   category: "Food",          amount:   -89.40, date: "Today",       type: "expense", icon: "food"     },
  { id: 3, name: "Netflix subscription", category: "Entertainment", amount:   -15.99, date: "Yesterday",   type: "expense", icon: "zap"      },
  { id: 4, name: "Shell petrol station", category: "Transport",     amount:   -62.00, date: "Yesterday",   type: "expense", icon: "car"      },
  { id: 5, name: "Amazon purchase",      category: "Shopping",      amount:  -134.99, date: "Mon 28 Apr",  type: "expense", icon: "shopping" },
  { id: 6, name: "Electricity bill",     category: "Utilities",     amount:   -89.00, date: "Sun 27 Apr",  type: "expense", icon: "zap"      },
  { id: 7, name: "Rent payment",         category: "Housing",       amount: -1400.00, date: "Sat 26 Apr",  type: "expense", icon: "home"     },
];

/* SVG icon strings keyed by icon name */
const icons = {
  wallet: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
             <path d="M21 12V7H5a2 2 0 010-4h14v4"/>
             <path d="M3 7v13a2 2 0 002 2h16v-5"/>
             <path d="M18 12h.01"/>
           </svg>`,

  food:   `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
             <path d="M18 8h1a4 4 0 010 8h-1"/>
             <path d="M2 8h16v9a4 4 0 01-4 4H6a4 4 0 01-4-4V8z"/>
             <line x1="6" y1="1" x2="6" y2="4"/>
             <line x1="10" y1="1" x2="10" y2="4"/>
             <line x1="14" y1="1" x2="14" y2="4"/>
           </svg>`,

  car:    `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
             <path d="M5 17H3v-7l2-5h14l2 5v7h-2M5 17a2 2 0 004 0M15 17a2 2 0 004 0"/>
           </svg>`,

  shopping: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
               <path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
               <line x1="3" y1="6" x2="21" y2="6"/>
               <path d="M16 10a4 4 0 01-8 0"/>
             </svg>`,

  zap:    `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
             <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
           </svg>`,

  home:   `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
             <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
             <polyline points="9 22 9 12 15 12 15 22"/>
           </svg>`,
};

/* Category → background tint + accent colour */
const catColors = {
  Income:        { bg: "rgba(45,212,160,0.12)",  color: "#2dd4a0" },
  Food:          { bg: "rgba(45,212,160,0.10)",  color: "#2dd4a0" },
  Entertainment: { bg: "rgba(167,139,250,0.12)", color: "#a78bfa" },
  Transport:     { bg: "rgba(242,107,80,0.12)",  color: "#f26b50" },
  Shopping:      { bg: "rgba(167,139,250,0.12)", color: "#a78bfa" },
  Utilities:     { bg: "rgba(245,166,35,0.12)",  color: "#f5a623" },
  Housing:       { bg: "rgba(91,156,246,0.12)",  color: "#5b9cf6" },
  Health:        { bg: "rgba(45,212,160,0.10)",  color: "#2dd4a0" },
  Other:         { bg: "rgba(94,94,90,0.20)",    color: "#9a9a96" },
};

/* Maps form category select value to icon key */
const iconMap = {
  Food:          "food",
  Housing:       "home",
  Transport:     "car",
  Shopping:      "shopping",
  Utilities:     "zap",
  Entertainment: "zap",
  Health:        "wallet",
  Other:         "wallet",
  Income:        "wallet",
};
