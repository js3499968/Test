# Load the RODBC package
library(RODBC)

# Define your database connection parameters
db_server <- "your_server_name"
db_database <- "your_database_name"
db_user <- "your_username"
db_password <- "your_password"

# Create a connection to the SQL Server database
connection <- odbcDriverConnect(paste("Driver={SQL Server};Server=", db_server, ";
                                      Database=", db_database, ";
                                      UID=", db_user, ";
                                      PWD=", db_password))

# Function to check if a column is a date or datetime column
is_date_column <- function(column_name, connection) {
  query <- paste("SELECT TOP 1 ", column_name, " FROM your_table_name")
  tryCatch({
    result <- sqlQuery(connection, query)
    is_date <- is.Date(result[[1]])
    return(is_date)
  }, error = function(e) {
    return(FALSE)
  })
}

# Specify the table for which you want to retrieve column names
table_name <- "your_table_name"

# Get the column names
column_names <- sqlColumns(connection, catalog = db_database, table = table_name)$COLUMN_NAME

# Loop through each column and check if it's a date column
date_columns <- character(0)
for (column in column_names) {
  if (is_date_column(column, connection)) {
    date_columns <- c(date_columns, column)
  }
}

# Create a list to store max and min dates for each date column
date_extremes <- list()

# Loop through date columns and query max and min dates
for (date_column in date_columns) {
  query <- paste("SELECT MAX(", date_column, "), MIN(", date_column, ") FROM ", table_name)
  result <- sqlQuery(connection, query)
  date_extremes[[date_column]] <- result
}

# Query table creation and last modified dates
table_info_query <- paste("
SELECT name AS table_name, create_date, modify_date
FROM sys.tables
WHERE name = '", table_name, "'
")

table_info <- sqlQuery(connection, table_info_query)

# Close the database connection
odbcClose(connection)

# Create a dataframe to store the results
result_df <- data.frame(
  Table_Name = table_info$table_name,
  Table_Creation_Date = table_info$create_date,
  Table_Last_Modified_Date = table_info$modify_date
)

for (date_column in date_columns) {
  result_df[paste(date_column, "_Max_Date")] <- date_extremes[[date_column]][1, 1]
  result_df[paste(date_column, "_Min_Date")] <- date_extremes[[date_column]][1, 2]
}

# Print or manipulate the dataframe as needed
print(result_df)
