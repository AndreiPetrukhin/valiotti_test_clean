-- Create the deposits table
CREATE TABLE public.deposits (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    amount FLOAT NOT NULL,
    created_at TIMESTAMP NOT NULL
);

-- Create the withdrawals table
CREATE TABLE public.withdrawals (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    amount FLOAT NOT NULL,
    created_at TIMESTAMP NOT NULL
);

-- Insert test data into deposits table
INSERT INTO public.deposits (user_id, amount, created_at) VALUES
(1, 100.00, '2024-06-15 10:00:00'),
(2, 200.00, '2024-06-15 12:00:00'),
(1, 50.00, '2024-06-16 10:00:00'),
(3, 300.00, '2024-06-16 15:00:00'),
(2, 150.00, '2024-06-17 09:00:00');

-- Insert test data into withdrawals table
INSERT INTO public.withdrawals (user_id, amount, created_at) VALUES
(1, 30.00, '2024-06-15 14:00:00'),
(3, 100.00, '2024-06-15 16:00:00'),
(1, 20.00, '2024-06-16 11:00:00'),
(2, 50.00, '2024-06-17 10:00:00'),
(3, 80.00, '2024-06-17 12:00:00');

-- Check the contents of deposits table
SELECT * FROM deposits;

-- Check the contents of withdrawals table
SELECT * FROM withdrawals;

-- Create a materialized view to aggregate daily summaries of deposits and withdrawals
CREATE MATERIALIZED VIEW public.daily_summary_mv AS
SELECT 
    date_trunc('day', created_at) AS day,
    SUM(CASE WHEN TG_TABLE_NAME = 'deposits' THEN amount ELSE 0 END) AS total_deposits,
    SUM(CASE WHEN TG_TABLE_NAME = 'withdrawals' THEN amount ELSE 0 END) AS total_withdrawals,
    SUM(CASE WHEN TG_TABLE_NAME = 'deposits' THEN amount ELSE 0 END) - SUM(CASE WHEN TG_TABLE_NAME = 'withdrawals' THEN amount ELSE 0 END) AS net_amount
FROM 
    (SELECT created_at, amount, 'deposits' AS TG_TABLE_NAME FROM deposits
     UNION ALL
     SELECT created_at, amount, 'withdrawals' AS TG_TABLE_NAME FROM withdrawals) AS transactions
GROUP BY 
    day
ORDER BY 
    day;

-- Check the contents of the materialized view
SELECT * FROM public.daily_summary_mv;

-- Refresh the materialized view to update its data
REFRESH MATERIALIZED VIEW public.daily_summary_mv;

-- Insert additional test data into deposits table
INSERT INTO deposits (user_id, amount, created_at) VALUES
(1, 120.00, '2024-06-18 11:00:00'),
(2, 220.00, '2024-06-18 13:00:00'),
(3, 320.00, '2024-06-19 09:00:00'),
(4, 420.00, '2024-06-19 14:00:00'),
(5, 520.00, '2024-06-20 10:00:00'),
(1, 220.00, '2024-06-20 12:00:00');

-- Insert additional test data into withdrawals table
INSERT INTO withdrawals (user_id, amount, created_at) VALUES
(2, 120.00, '2024-06-18 15:00:00'),
(3, 220.00, '2024-06-18 17:00:00'),
(4, 320.00, '2024-06-19 11:00:00'),
(5, 420.00, '2024-06-19 16:00:00'),
(1, 520.00, '2024-06-20 14:00:00'),
(2, 220.00, '2024-06-20 16:00:00');

-- Refresh the materialized view to include the new data
REFRESH MATERIALIZED VIEW public.daily_summary_mv;

-- Check the updated contents of the materialized view
SELECT * FROM public.daily_summary_mv;

-- Schedule a daily refresh of the materialized view at midnight using pg_cron
SELECT cron.schedule('0 0 * * *', 'REFRESH MATERIALIZED VIEW public.daily_summary_mv');