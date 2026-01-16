-- PERSONAL FINANCE TRACKER (MySQL)
DROP DATABASE IF EXISTS personal_finance;
CREATE DATABASE personal_finance;
USE personal_finance;

-- 1) USERS
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'CAD',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2) ACCOUNTS
CREATE TABLE accounts (
  account_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  account_name VARCHAR(60) NOT NULL,
  account_type ENUM('CHEQUING','SAVINGS','CREDIT_CARD','CASH','INVESTMENT','LOAN') NOT NULL,
  institution VARCHAR(60),
  opened_on DATE,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 3) CATEGORIES (needs/wants/savings)
CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  category_group ENUM('NEEDS','WANTS','SAVINGS','INCOME','TRANSFER') NOT NULL
);

-- 4) MERCHANTS
CREATE TABLE merchants (
  merchant_id INT AUTO_INCREMENT PRIMARY KEY,
  merchant_name VARCHAR(80) NOT NULL,
  merchant_type VARCHAR(50)
);

-- 5) TRANSACTIONS
CREATE TABLE transactions (
  txn_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  account_id INT NOT NULL,
  category_id INT NOT NULL,
  merchant_id INT NULL,
  txn_date DATE NOT NULL,
  description VARCHAR(200),
  amount DECIMAL(12,2) NOT NULL,
  txn_type ENUM('INCOME','EXPENSE','TRANSFER') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (account_id) REFERENCES accounts(account_id),
  FOREIGN KEY (category_id) REFERENCES categories(category_id),
  FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id),
  INDEX idx_txn_user_date (user_id, txn_date),
  INDEX idx_txn_category (category_id),
  INDEX idx_txn_account (account_id)
);

-- 6) BUDGETS (per category per month)
CREATE TABLE budgets (
  budget_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  category_id INT NOT NULL,
  budget_month DATE NOT NULL,  -- use first day of month e.g. '2026-01-01'
  budget_amount DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (category_id) REFERENCES categories(category_id),
  UNIQUE KEY uq_budget (user_id, category_id, budget_month)
);

-- 7) GOALS (savings goals)
CREATE TABLE goals (
  goal_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  goal_name VARCHAR(80) NOT NULL,
  target_amount DECIMAL(12,2) NOT NULL,
  target_date DATE,
  created_on DATE DEFAULT (CURRENT_DATE),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 8) NET WORTH SNAPSHOTS (monthly)
CREATE TABLE net_worth_snapshots (
  snapshot_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  snapshot_month DATE NOT NULL, -- first day of month
  assets DECIMAL(12,2) NOT NULL,
  liabilities DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  UNIQUE KEY uq_snapshot (user_id, snapshot_month)
);

-- 9) RECURRING RULES (subscriptions / recurring bills)
CREATE TABLE recurring_rules (
  rule_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  merchant_id INT NOT NULL,
  category_id INT NOT NULL,
  frequency ENUM('WEEKLY','MONTHLY','YEARLY') NOT NULL,
  expected_amount DECIMAL(12,2) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id),
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- -------------------
-- SAMPLE DATA
-- -------------------
INSERT INTO users (full_name, currency) VALUES
('Tushar Sohal', 'CAD');

INSERT INTO accounts (user_id, account_name, account_type, institution, opened_on) VALUES
(1, 'RBC Chequing', 'CHEQUING', 'RBC', '2023-01-01'),
(1, 'RBC Savings', 'SAVINGS', 'RBC', '2023-01-01'),
(1, 'Amex Credit Card', 'CREDIT_CARD', 'AMEX', '2024-05-01'),
(1, 'Cash Wallet', 'CASH', NULL, '2024-01-01');

INSERT INTO categories (category_name, category_group) VALUES
('Salary', 'INCOME'),
('Rent', 'NEEDS'),
('Groceries', 'NEEDS'),
('Transport', 'NEEDS'),
('Utilities', 'NEEDS'),
('Eating Out', 'WANTS'),
('Entertainment', 'WANTS'),
('Subscriptions', 'WANTS'),
('Savings Transfer', 'SAVINGS'),
('Credit Card Payment', 'TRANSFER');

INSERT INTO merchants (merchant_name, merchant_type) VALUES
('Employer Payroll', 'INCOME'),
('Landlord', 'HOUSING'),
('Walmart', 'GROCERIES'),
('Costco', 'GROCERIES'),
('BC Hydro', 'UTILITIES'),
('Telus', 'UTILITIES'),
('Uber', 'TRANSPORT'),
('Starbucks', 'EATING_OUT'),
('Netflix', 'SUBSCRIPTION'),
('Spotify', 'SUBSCRIPTION'),
('Cineplex', 'ENTERTAINMENT');

-- Transactions (Jan 2026 sample)
INSERT INTO transactions (user_id, account_id, category_id, merchant_id, txn_date, description, amount, txn_type) VALUES
(1, 1, 1, 1, '2026-01-01', 'Monthly salary', 2600.00, 'INCOME'),
(1, 1, 2, 2, '2026-01-02', 'Rent January', -950.00, 'EXPENSE'),
(1, 1, 3, 3, '2026-01-03', 'Groceries', -85.40, 'EXPENSE'),
(1, 3, 6, 8, '2026-01-04', 'Coffee', -6.25, 'EXPENSE'),
(1, 1, 5, 5, '2026-01-05', 'Electricity', -45.10, 'EXPENSE'),
(1, 1, 5, 6, '2026-01-06', 'Phone bill', -55.00, 'EXPENSE'),
(1, 3, 8, 9, '2026-01-07', 'Netflix subscription', -16.99, 'EXPENSE'),
(1, 3, 8, 10,'2026-01-07', 'Spotify subscription', -11.99, 'EXPENSE'),
(1, 1, 4, 7, '2026-01-08', 'Uber rides', -22.50, 'EXPENSE'),
(1, 1, 9, NULL,'2026-01-10', 'Transfer to savings', -300.00, 'TRANSFER'),
(1, 2, 9, NULL,'2026-01-10', 'Transfer from chequing', 300.00, 'TRANSFER'),
(1, 1, 10,NULL,'2026-01-12', 'Credit card payment', -200.00, 'TRANSFER'),
(1, 3, 7, 11,'2026-01-15', 'Movie night', -18.50, 'EXPENSE');

INSERT INTO budgets (user_id, category_id, budget_month, budget_amount) VALUES
(1, 2, '2026-01-01', 950.00),  -- rent
(1, 3, '2026-01-01', 350.00),  -- groceries
(1, 6, '2026-01-01', 120.00),  -- eating out
(1, 8, '2026-01-01', 40.00),   -- subscriptions
(1, 7, '2026-01-01', 60.00);   -- entertainment

INSERT INTO goals (user_id, goal_name, target_amount, target_date) VALUES
(1, 'Emergency Fund', 5000.00, '2026-12-31'),
(1, 'Trip to India', 2500.00, '2026-10-01');

INSERT INTO net_worth_snapshots (user_id, snapshot_month, assets, liabilities) VALUES
(1, '2025-12-01', 15000.00, 1200.00),
(1, '2026-01-01', 15300.00, 1100.00);

INSERT INTO recurring_rules (user_id, merchant_id, category_id, frequency, expected_amount, start_date) VALUES
(1, 9, 8, 'MONTHLY', 16.99, '2025-01-01'),
(1, 10,8, 'MONTHLY', 11.99, '2025-01-01');
