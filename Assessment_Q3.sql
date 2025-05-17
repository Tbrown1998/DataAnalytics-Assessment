-- Identify plans with their last transaction date and flag accounts inactive for over 365 days

WITH latest_tran AS (
-- Get the most recent confirmed transaction date per plan
  SELECT 
    plan_id, 
    MAX(transaction_date) AS max_transaction_date
  FROM 
    savings_savingsaccount
  WHERE 
    confirmed_amount > 0
  GROUP BY 
    plan_id
),
plans_with_last_tran AS (
-- Join plans with their last transaction date or fallback to plan creation date
  SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
      WHEN p.is_regular_savings = 1 THEN 'Savings'
      WHEN p.is_a_fund = 1 THEN 'Investment'
    END AS type,
    COALESCE(l.max_transaction_date, p.created_on) AS last_transaction_date
  FROM 
    plans_plan p
  LEFT JOIN 
    latest_tran l ON p.id = l.plan_id
  WHERE 
    p.is_regular_savings = 1 OR p.is_a_fund = 1
)
SELECT 
  plan_id,
  owner_id,
  type,
  last_transaction_date,
    -- Calculate inactivity days since last transaction or creation
  DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days
FROM 
  plans_with_last_tran
WHERE 
  DATEDIFF(CURDATE(), last_transaction_date) > 365 -- Flag accounts inactive for more than one year
ORDER BY inactivity_days DESC;