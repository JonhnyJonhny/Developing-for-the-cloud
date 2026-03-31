// 1. Define the mock data structure (Replace with fetch() to RDS backend later)
//const mockDbResponse = {

//}

// 2. Utility function to format currency
const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
};

// 3. Function to update the summary cards
const updateSummaryUI = (summaryData) => {
    document.getElementById('total-balance').textContent = formatCurrency(summaryData.totalBalance);
    document.getElementById('monthly-income').textContent = `+${formatCurrency(summaryData.monthlyIncome)}`;
    document.getElementById('monthly-expenses').textContent = `-${formatCurrency(summaryData.monthlyExpenses)}`;
};

// 4. Function to render the transaction table
const renderTransactions = (transactions) => {
    const tbody = document.getElementById('transactions-body');
    tbody.innerHTML = ''; // Clear existing rows

    transactions.forEach(trx => {
        const row = document.createElement('tr');
        
        // Format date to be more readable
        const dateObj = new Date(trx.date);
        const formattedDate = dateObj.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
        
        // Determine badge class
        const badgeClass = trx.type === 'income' ? 'badge income' : 'badge expense';
        const displayType = trx.type.charAt(0).toUpperCase() + trx.type.slice(1);

        row.innerHTML = `
            <td>${formattedDate}</td>
            <td>${trx.description}</td>
            <td>${trx.category}</td>
            <td>${formatCurrency(trx.amount)}</td>
            <td><span class="${badgeClass}">${displayType}</span></td>
        `;
        tbody.appendChild(row);
    });
};

// 5. Main function to fetch data and initialize the dashboard
async function loadDashboardData() {
    try {
        // Mock data loading
        const data = mockDbResponse; 
        
        // Update DOM
        updateSummaryUI(data.summary);
        renderTransactions(data.transactions);
    } catch (error) {
        console.error("Failed to load dashboard data:", error);
    }
}

// 6. Report Generation Logic Placeholder
function handleReportGeneration() {
    console.log("Triggering report generation microservice...");
    // Future: Add fetch call to your report microservice endpoint here
    alert("Report generation triggered!");
}

// Event Listeners
document.addEventListener('DOMContentLoaded', loadDashboardData);
document.getElementById('btn-generate-report').addEventListener('click', handleReportGeneration);