import sqlite3

def execute_sql_from_file(filename, db_filename):
    conn = sqlite3.connect(db_filename)
    cursor = conn.cursor()
    
    
    with open(filename, 'r') as sql_file:
        sql_script = sql_file.read()
        
    cursor.executescript(sql_script)
    
    conn.commit()
    conn.close()
    
    

sql_commands_file = 'project_1.txt'
sqlite_db_file = 'project_1.sqlite'
        
execute_sql_from_file(sql_commands_file, sqlite_db_file)