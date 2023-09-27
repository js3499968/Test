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

# Specify the table for which you want to retrieve column names and unique values
table_name <- "your_table_name"

# Get the column names
column_names <- sqlColumns(connection, catalog = db_database, table = table_name)$COLUMN_NAME

# Create a list to store unique values for each column
unique_values_list <- list()

# Loop through each column and retrieve unique values if there are less than 50
for (column in column_names) {
  query <- paste("SELECT DISTINCT ", column, " FROM ", table_name)
  result <- sqlQuery(connection, query)
  if (nrow(result) <= 50) {
    unique_values_list[[column]] <- result
  }
}

# Close the database connection
odbcClose(connection)