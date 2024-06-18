-- Создание таблицы для хранения ошибок
CREATE TABLE IF NOT EXISTS :schema.station_errors (
    id SERIAL PRIMARY KEY,
    date DATE,
    station VARCHAR(255),
    msg VARCHAR(255),
    status VARCHAR(50)
);

-- Очистка таблицы перед новой загрузкой
TRUNCATE TABLE :schema.station_errors;

-- Вставка новых ошибок с присвоением статусов
WITH error_days AS (
    SELECT
        *,
        LAG(date) OVER (PARTITION BY station ORDER BY date) AS prev_date,
        LAG(date, 2) OVER (PARTITION BY station ORDER BY date) AS prev_prev_date
    FROM :schema.raw_data
    WHERE msg = 'fail'
),
status_calculation AS (
    SELECT
        id,
        date,
        station,
        msg,
        CASE
            WHEN prev_date IS NULL OR date - prev_date > 1 THEN 'new'
            WHEN prev_date = date THEN 'new'
            WHEN date - prev_date = 1 AND (date - prev_prev_date > 2 OR prev_prev_date is NULL) THEN 'serious'
            ELSE 'critical'
        END AS status
    FROM error_days
)
INSERT INTO :schema.station_errors (id, date, station, msg, status)
SELECT id, date, station, msg, status FROM status_calculation;