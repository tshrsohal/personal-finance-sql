SELECT *
FROM transactions;


-- 1. Total income vs total expense in Jan 2026

SELECT
SUM(CASE WHEN txn_type='INCOME' THEN amount ELSE 0 END) AS total_income,
SUM(CASE WHEN txn_type='EXPENSE' THEN -amount ELSE 0 END) AS total_EXPENSE
FROM transactions
WHERE user_id = 1 AND txn_date >= '2026-01-01' AND txn_date < '2026-02-01';	


-- 2. Spending by category (Jan 2026)

SELECT c.category_name, ROUND(SUM(-t.amount), 2) AS spent
FROM transactions t
JOIN categories c ON c.category_id = t.category_id
WHERE t.user_id = 1
	AND t.txn_type = 'EXPENSE'
    AND t.txn_date >= '2026-01-01' AND t.txn_date < '2026-02-01'
GROUP BY c.category_name
ORDER BY spent DESC;

-- 3. Top 5 merchants by spend

SELECT m.merchant_name, ROUND(SUM(-t.amount), 2) AS spent
FROM transactions t
JOIN merchants m ON m.merchant_id = t.merchant_id
WHERE t.user_id = 1 AND t.txn_type = 'EXPENSE'
GROUP BY m.merchant_name
ORDER BY spent DESC
LIMIT 5;

-- 4. Needs vs Wants share (Jan 2026)

SELECT
  c.category_group,
  ROUND(SUM(-t.amount),2) AS spent
FROM transactions t
JOIN categories c ON c.category_id=t.category_id
WHERE t.user_id=1 AND t.txn_type='EXPENSE'
  AND t.txn_date >= '2026-01-01' AND t.txn_date < '2026-02-01'
GROUP BY c.category_group;

-- 5. Monthly savings rate (Income, Expenses, Net) by month

SELECT
	DATE_FORMAT(txn_date, '%Y-%m-01') AS month,
    ROUND(SUM(CASE WHEN txn_type= 'INCOME' THEN amount ELSE 0 END),2) AS income,
    ROUND(SUM(CASE WHEN txn_type= 'EXPENSE' THEN -amount ELSE 0 END),2) AS expenses,
    ROUND(SUM(CASE WHEN txn_type= 'INCOME' THEN amount ELSE 0 END) - SUM(CASE WHEN txn_type= 'EXPENSE' THEN -amount ELSE 0 END),2) AS net_savings
FROM transactions
WHERE user_id=1
GROUP BY DATE_FORMAT(txn_date, '%Y-%m-01')
ORDER BY month;

    
-- 6. Budget vs Actual (Jan 2026)

SELECT
  c.category_name,
  b.budget_amount,
  ROUND(IFNULL(SUM(CASE WHEN t.txn_type='EXPENSE' THEN -t.amount END), 0), 2) AS actual_spent,
  ROUND(b.budget_amount - IFNULL(SUM(CASE WHEN t.txn_type='EXPENSE' THEN -t.amount END), 0), 2) AS remaining
FROM budgets b
JOIN categories c ON c.category_id = b.category_id
LEFT JOIN transactions t
  ON t.user_id=b.user_id
 AND t.category_id=b.category_id
 AND t.txn_date >= b.budget_month
 AND t.txn_date < DATE_ADD(b.budget_month, INTERVAL 1 MONTH)
WHERE b.user_id=1 AND b.budget_month='2026-01-01'
GROUP BY c.category_name, b.budget_amount
ORDER BY actual_spent DESC;


