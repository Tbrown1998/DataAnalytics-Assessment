-- Calculate average monthly transaction count per user, then categorize users by transaction frequency

WITH avg_monthly_txn_count_per_user AS (
    -- Calculate average transactions per month for each user
    SELECT 
        user_id,
        AVG(total_transactions) AS avg_monthly_transactions
    FROM (
        -- Count total transactions per user for each year-month
        SELECT 
            u.id AS user_id, 
            EXTRACT(YEAR FROM s.transaction_date) AS year,
            EXTRACT(MONTH FROM s.transaction_date) AS month, 
            COUNT(*) AS total_transactions
        FROM 
            users_customuser u
        JOIN 
            savings_savingsaccount s
            ON u.id = s.owner_id
        GROUP BY 
            u.id, year, month 
    ) monthly_txn_count
    GROUP BY user_id
)

SELECT 
    -- Categorize users based on average monthly transaction count
    CASE
        WHEN avg_monthly_transactions >= 10 THEN 'High Frequency'
        WHEN avg_monthly_transactions BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    
    COUNT(*) AS customer_count,  -- Number of customers in each category
    
    ROUND(AVG(avg_monthly_transactions), 1) AS avg_transactions_per_month  -- Average transactions per month per category

FROM avg_monthly_txn_count_per_user

GROUP BY frequency_category;