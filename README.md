# DataAnalytics-Assessment

---

### General Overview
The repository contains solutions for CowryWise SQL Assessment Test. The project database contain 4 tables
- `users_customuser`: contains records of deposit transactions
-  `savings_savingsaccount`: contains customer demographic and contact information
- `plans_plan`: contains records of plans created by customers
- `withdrawals_withdrawal`: contains  records of withdrawal transactions

---

### Technologies Used:
- **DBMS:** Mysql
- **Version Control:** GitHub

---

### QUESTION 1:
#### Scenario: 
The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
#### Task: 
Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits

### My Approach: 
My main goal was to pinpoint those valuable customers who've diversified their holdings with cowrywise, having both savings and investment plans, Here are the steps i took for this analysis:
- **Joining Tables:** To get a complete picture, I started by joining these tables. I needed to link the users to their plans and then to their deposit amounts.
- **Conditional Aggregation:** This was the tricky part. I used the `SUM(CASE)` trick to count the savings and investment plans for each customer separately. This way, I could easily see who had at least one of each.
- **Calculating Total Deposits:** I created a `subquery` to sum up all the deposits for each customer from the savings_savingsaccount table. This gave me the total "value" each customer had with us.
- **Filtering with HAVING:** After calculating all that, I used the `HAVING` clause to filter out the customers who didn't meet the criteria those who had both a savings plan AND an investment plan.
- **Ordering Results:** Finally, I sorted the results by the total deposit amount in descending order. This put the highest-value customers right at the top.

### Challenges:
- **Assumptions:** I had to make sure I understood what constituted a `funded` plan. In this case, I assumed it was tied to the deposit records in the savings_savingsaccount table. If there were other conditions, the query would need tweaking.
- **Handling edge cases:** I considered that a user might have multiple savings accounts for a single savings plan, but the query counts plans.
- **Performance:** I was mindful of performance, especially with large datasets. While the subquery works, I know that in some situations, window functions might be more efficient. But for clarity, I stuck with this approach.

--- 

### QUESTION 2
### Scenario: 
The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).
### Task:  
Calculate the average number of transactions per customer per month and categorize them:
- `High Frequency` (≥10 transactions/month)
- `Medium Frequency` (3-9 transactions/month)
- `Low Frequency` (≤2 transactions/month)

### My Approach:
My goal was to analyze and group transactions frequency by all customers and understand transaction patterns. Here are the steps i took for this analysis:

- **Calculate Monthly Transactions:**  I counted each user's transactions per month from the `savings_savingsaccount` table.
- **Calculate Average Monthly Transactions:** I calculated the average number of monthly transactions for each user. 
- **Categorize Users:** I used a `CASE` statement to categorize users based on their average monthly transactions.
- **Aggregation** I grouped users by category and counted them, also calculating the average transactions per month for each category.
- **Ordering Results:** Finally, I `sorted` the results by the total deposit amount in descending order. This put the highest-value customers right at the top.
- **Determine Last Activity and Inactivity:** I found each plan's most recent activity date (transaction or creation) and calculated how many days it has been inactive.
- **Filter and Order:** I then filtered for plans inactive for over 365 days and ordered them by inactivity.

### Challenges
- **Aggregating Monthly Transactions Per User:** I used `EXTRACT(YEAR FROM transaction_date)` and `EXTRACT(MONTH FROM transaction_date)` to break down transactions by month and year, enabling correct grouping.
- **Calculating Average Monthly Transactions:** I used a `subquery` inside a `CTE` to first count monthly transactions, then calculated the average monthly transactions per user by grouping on user_id again.
- **Handling Users with Sparse or No Transactions:** By aggregating averages only on users with transactions and categorizing them properly, I ensured all active users were accounted for, and inactive users naturally fall into the `Low Frequency` category.

---

### QUESTION 3
## Scenario: 
The ops team wants to flag accounts with no inflow transactions for over one year.
## Task: 
Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) .

### My Approach:
The goal is to write a SQL query that finds active accountsthat are either savings accounts or investment accounts. Then Identify accounts that have had no inflow transactions within the last year (365 days). I solved this question by following these steps:

- **Customer Transaction Frequency:**  I calculated users' `average` monthly transactions, categorized them by `frequency (high, medium, low)`, and summarized the customer count and average transactions for each category.
- **Inactive Account Identification:**  I determined each plan's last activity date and inactivity duration, then `filtered` and ordered the plans based on inactivity. 

### Challenges
- **Handling Missing Transaction Dates:** Some plans had no confirmed transactions, resulting in `NULL` latest transaction dates. To handle this, I used `COALESCE()` to replace `NULLs` with the plan’s creation date as a fallback.
- **Dealing with Multiple Plan Types:** I had to differentiate between regular savings plans and investment funds within the same query, using conditional logic `(CASE)` to label the plan type appropriately.
- **Ordering and Filtering Results:** To ensure the transaction_date field accurately reflects user activity. I had to apply filtering to show only accounts inactive for more than a year and order the results by inactivity, which involved combining filtering conditions and ordering by calculated columns.

--- 

### QUESTION 4:
## Scenario:  
Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).
## Task: 
For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
- `Account tenure (months since signup)`
- `Total transactions`
- `Estimated CLV` (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
- Order by estimated `CLV` from highest to lowest


### My Approach:
- **Calculate Customer Tenure:**  I first calculates how long each customer has been with the company in months.
- **I Determine Transaction Stats:**  It then aggregates each customer's total transactions and calculates their estimated total profit.
- **Compute and Order CLV:** Finally, it combines tenure and transaction data to calculate the estimated CLV for each customer using the provided formula and orders the results from highest to lowest CLV.

### Challenges

- **Avoiding division errors:** The `CLV` formula involved division by tenure and transaction counts, which could be zero, risking division-by-zero errors. SO I added a `CASE` statement to check tenure before dividing, setting CLV to 0 if tenure was zero or `null` to avoid errors.
- **Calculating account tenure accurately:** I needed to convert the signup date into a meaningful tenure measure (months) while handling cases where the signup date might be missing. Then i used Used `DATEDIFF` and division by 30 to calculate tenure in months, filtering out customers without a date_joined.
- **Handling transaction data:** I aggregated transactions with `COUNT(*)` and summed amounts with `SUM()`, dividing by 1000 to convert kobo to base currency.
