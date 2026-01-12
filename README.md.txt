# Personal Finance SQL Project

## Objective
This project simulates a real-world personal finance tracking system using SQL.  
It helps analyze income, expenses, budgets, savings behavior, and spending patterns.

The goal is to demonstrate practical SQL skills used in finance and accounting roles.

---

## Tools & Technologies
- MySQL
- SQL (DDL, DML, Joins, Aggregations)
- Git & GitHub

---

## Database Overview
The database is designed using normalized relational tables to track:

- Users
- Bank & credit card accounts
- Income and expense transactions
- Spending categories (Needs, Wants, Savings)
- Merchants
- Monthly budgets
- Savings goals
- Net worth snapshots
- Recurring subscriptions

**Core Tables**
- `users`
- `accounts`
- `transactions`
- `categories`
- `budgets`

---

## Key SQL Analyses
Some of the insights generated using SQL queries:

- Monthly income vs expenses
- Spending by category and merchant
- Budget vs actual analysis
- Needs vs wants breakdown
- Monthly savings trend
- Identification of recurring subscriptions

---

## Sample Queries
```sql
-- Monthly income vs expense
SELECT
  SUM(CASE WHEN txn_type='INCOME' THEN amount ELSE 0 END) AS income,
  SUM(CASE WHEN txn_type='EXPENSE' THEN -amount ELSE 0 END) AS expenses
FROM transactions
WHERE txn_date >= '2026-01-01' AND txn_date < '2026-02-01';
