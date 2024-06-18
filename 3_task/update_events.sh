#!/bin/bash

# Загрузка переменных окружения из .env файла
source .env

# Путь к файлу CSV
CSV_FILE="raw_data.csv"
DB_SCHEMA="public"

# Создание схемы, если она не существует
psql -U $DB_USER -h $DB_HOST -d $DB_NAME -c "
CREATE SCHEMA IF NOT EXISTS $DB_SCHEMA;"

# Создание таблицы raw_data, если она не существует
psql -U $DB_USER -h $DB_HOST -d $DB_NAME -c "
CREATE TABLE IF NOT EXISTS $DB_SCHEMA.raw_data (
    id INT PRIMARY KEY,
    date DATE,
    station VARCHAR(255),
    msg VARCHAR(255)
);"

# Загрузка данных из CSV в таблицу raw_data
psql -U $DB_USER -h $DB_HOST -d $DB_NAME -c "\COPY $DB_SCHEMA.raw_data(id, date, station, msg) FROM '$CSV_FILE' WITH CSV HEADER DELIMITER ',';"

# Запуск SQL-скрипта для присвоения статусов ошибкам
psql -U $DB_USER -h $DB_HOST -d $DB_NAME -v schema=$DB_SCHEMA -f status_assignment.sql