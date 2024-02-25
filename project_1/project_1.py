# Import the sqlite3 library to work with SQLite databases
import sqlite3

# Define a function to execute SQL commands from a file
def execute_sql_from_file(filename, db_filename):
    # Connect to the SQLite database using the specified database file
    conn = sqlite3.connect(db_filename)
    # Create a cursor object to interact with the database
    cursor = conn.cursor()
    
    # Open the SQL file in read mode
    with open(filename, 'r') as sql_file:
        # Read the entire content of the file, which contains SQL commands
        sql_script = sql_file.read()
        
    # Execute the SQL script read from the file
    # This executes all commands in the file as a single transaction
    cursor.executescript(sql_script)
    
    # Commit any changes made to the database during the script execution
    # This makes the changes permanent
    conn.commit()
    
    # Close the database connection
    conn.close()
    

# Specify the path to the file containing SQL commands
sql_commands_file = 'project_1.txt'
# Specify the path to the SQLite database file
sqlite_db_file = 'project_1.sqlite'
        
# Call the function to execute the SQL commands from the specified file
# on the specified SQLite database
execute_sql_from_file(sql_commands_file, sqlite_db_file)
