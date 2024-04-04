import sqlite3

# Verbind met de nieuwe Chinook-database
conn = sqlite3.connect('C:/Users/mukil/Downloads/chinook/chinook.db')
cursor = conn.cursor()

# Haal alle tabelnamen op in de database
cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
tables = cursor.fetchall()

# Sluit de databaseverbinding
conn.close()

# Print de tabelnamen uit
for table in tables:
    print(table[0])
