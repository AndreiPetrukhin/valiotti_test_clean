# Load environment variables from .env file
source .env

# Variables
CSV_FILE="events.csv"
TABLE_NAME="events"
DB_SCHEMA="public"
CSV_URL="https://drive.google.com/u/0/uc?id=1dHnYmn4mO2rsJxa_7RYK9thp70smeFcf&export=download"

# Function to recreate the table
recreate_table() {
  PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "
  DROP TABLE IF EXISTS $DB_SCHEMA.$TABLE_NAME;
  CREATE TABLE $DB_SCHEMA.$TABLE_NAME (
    user_id VARCHAR(255),
    product_identifier VARCHAR(255),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    price_in_usd DECIMAL
  );
  "
}

# Function to download CSV file
download_csv() {
  curl -L -o $CSV_FILE $CSV_URL
}

# Function to import data from CSV file to table
import_csv_to_table() {
  PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME <<EOF
  \copy $DB_SCHEMA.$TABLE_NAME(user_id, product_identifier, start_time, end_time, price_in_usd) FROM '$(pwd)/$CSV_FILE' DELIMITER ',' CSV HEADER;
EOF
}

# Main script
echo "Recreating table..."
recreate_table

echo "Downloading CSV file..."
download_csv

echo "Importing CSV file to table..."
import_csv_to_table

echo "Done!"