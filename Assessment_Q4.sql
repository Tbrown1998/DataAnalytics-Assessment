-- Calculate Customer Lifetime Value (CLV) based on account tenure and transaction volume

WITH customer_tenure AS (
    -- Calculate the tenure in months for each customer since signup
    SELECT 
        id AS owner_id,
        DATEDIFF(CURRENT_DATE, date_joined) / 30 AS tenure_months
    FROM 
        users_customuser
    WHERE 
        date_joined IS NOT NULL
),

transaction_stats AS (
    -- Aggregate total transactions and estimated profit per customer
    SELECT
        s.owner_id,
        COUNT(*) AS total_transactions,
        SUM(s.confirmed_amount) / 1000 AS estimated_profit  -- profit = 0.1% of total transaction value (kobo to base units)
    FROM 
        savings_savingsaccount s
    WHERE 
        s.confirmed_amount > 0
    GROUP BY 
        s.owner_id
)

SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    ROUND(t.tenure_months, 1) AS tenure_months,
    ts.total_transactions,
    -- Calculate estimated CLV using given formula, protect against division by zero
    CASE
        WHEN t.tenure_months > 0 
        THEN ROUND(
            (ts.total_transactions / t.tenure_months) * 12 * (ts.estimated_profit / ts.total_transactions)
            , 2)
        ELSE 0
    END AS estimated_clv
FROM 
    users_customuser u
JOIN 
    customer_tenure t ON u.id = t.owner_id
JOIN 
    transaction_stats ts ON u.id = ts.owner_id
ORDER BY 
    estimated_clv DESC;
