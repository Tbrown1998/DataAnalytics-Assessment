-- Query to find customers with both savings and investment plans,
-- along with their total deposits, ordered by total deposit amount.

SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    
    -- Count of savings plans for each customer
    SUM(CASE WHEN p.is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,
    
    -- Count of investment plans for each customer
    SUM(CASE WHEN p.is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count,
    
    -- Total confirmed amount deposited by the customer (defaults to 0 if no deposits)
    ROUND(COALESCE(td.total_amount, 0),2) AS total_deposits

FROM users_customuser u

-- Join to plans_plan to identify savings and investment plans per user
LEFT JOIN plans_plan p 
    ON p.owner_id = u.id

-- Subquery to sum confirmed_amount per user from savings_savingsaccount table
LEFT JOIN (
    SELECT 
        owner_id, 
        SUM(confirmed_amount) AS total_amount
    FROM savings_savingsaccount
    GROUP BY owner_id
) td 
    ON td.owner_id = u.id

GROUP BY 
    u.id, 
    name

-- Only include customers who have at least one savings and one investment plan
HAVING 
    savings_count > 0 
    AND investment_count > 0

ORDER BY 
    total_deposits DESC;