import sqlite3
import os


def zoek_tracks(db_connection, track_naam):
    cursor = db_connection.cursor()
    query = """
    SELECT track.TrackId, track.Name, artist.Name
    FROM track
    JOIN albums ON track.AlbumId = albums.AlbumId
    JOIN artists ON albums.ArtistId = artists.ArtistId
    WHERE track.Name LIKE ?
    """
    cursor.execute(query, ('%' + track_naam.strip() + '%',))
    return cursor.fetchall()


def voeg_toe_aan_playlist(db_connection, playlist_id, track_id):
    cursor = db_connection.cursor()
    query = "INSERT INTO playlist_track (PlaylistId, TrackId) VALUES (?, ?)"
    cursor.execute(query, (playlist_id, track_id))
    db_connection.commit()


# Pad naar de database
db_path = 'C:/Users/mukil/Downloads/chinook/chinook.db'

# Maak een databaseverbinding
conn = sqlite3.connect(db_path)

# Lees de naam van het bestand en controleer of het bestaat
playlist_file_path = input("Geef naam van het te importeren bestand: ")
if not os.path.isfile(playlist_file_path):
    print("Bestand niet gevonden")
else:
    with open(playlist_file_path, 'r') as file:
        tracks = [line.strip() for line in file]

    # Vraag de naam van de nieuwe playlist
    playlist_naam = input("Geef naam van de playlist: ")
    cursor = conn.cursor()
    cursor.execute(
        "SELECT PlaylistId FROM playlists WHERE Name = ?", (playlist_naam,))
    if cursor.fetchone():
        print("Deze playlist bestaat al")
    else:
        # Maak een nieuwe playlist
        cursor.execute("INSERT INTO playlists (Name) VALUES (?)",
                       (playlist_naam,))
        playlist_id = cursor.lastrowid

        # Voeg tracks toe aan de nieuwe playlist
        for track_naam in tracks:
            resultaten = zoek_tracks(conn, track_naam)
            if not resultaten:
                print(f"Geen tracks gevonden voor {track_naam}")
            elif len(resultaten) == 1:
                voeg_toe_aan_playlist(conn, playlist_id, resultaten[0][0])
            else:
                print(f"Meerdere tracks gevonden voor '{track_naam}':")
                for idx, (track_id, track_naam, artiest_naam) in enumerate(resultaten, start=1):
                    print(f"{idx}: {artiest_naam} - {track_naam}")
                keuze = int(input("Uw keuze: ")) - 1
                voeg_toe_aan_playlist(conn, playlist_id, resultaten[keuze][0])

        print("--- Import van playlist gereed ---")

# Sluit de databaseverbinding
conn.close()
