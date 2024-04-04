import sqlite3

# Connect to the Chinook database
conn = sqlite3.connect('chinook.db')

# Check if the Track table exists
cursor = conn.execute(
    "SELECT name FROM sqlite_master WHERE type='table' AND name='Track'")
result = cursor.fetchone()

if result:
    print("The Track table exists in the database")
else:
    print("The Track table does not exist in the database")

# Close the database connection
conn.close()
