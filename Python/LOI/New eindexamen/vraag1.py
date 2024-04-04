import sqlite3

# Verbind met de Chinook-database
conn = sqlite3.connect('C:/Users/mukil/Downloads/chinook/chinook.db')
cursor = conn.cursor()

# Definieer en voer de SQL-query uit
query_vraag1 = """
SELECT ar.Name, al.Title, COUNT(il.TrackId) AS PlayCount
FROM albums al
JOIN artists ar ON al.ArtistId = ar.ArtistId
JOIN tracks tr ON al.AlbumId = tr.AlbumId
JOIN invoice_items il ON tr.TrackId = il.TrackId
GROUP BY al.AlbumId
ORDER BY PlayCount DESC
LIMIT 10;
"""


try:
    cursor.execute(query_vraag1)

    # Haal de resultaten op en print ze uit
    albums = cursor.fetchall()
    print("Artist\tAlbum Title\tPlay Count")
    for artist, title, count in albums:
        print(f"{artist}\t{title}\t{count}")
except sqlite3.OperationalError as e:
    print(f"Er is een fout opgetreden: {e}")

# Sluit de databaseverbinding
conn.close()
