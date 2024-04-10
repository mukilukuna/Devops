import os

# Definieer de map waar je doorheen wilt gaan
directory = r"C:\Users\mukil\OneDrive\Documenten\Vs Code\Devops\Devops\Python\LOI\Examen"

# Loop door elk bestand in de opgegeven map
for filename in os.listdir(directory):
    # Maak het volledige pad naar het bestand
    old_file_path = os.path.join(directory, filename)

    # Controleer of het een bestand is en geen map
    if os.path.isfile(old_file_path):
        # Maak de nieuwe bestandsnaam met de .py extensie
        new_file_path = old_file_path + '.py'

        # Hernoem het bestand naar de nieuwe naam met de .py extensie
        os.rename(old_file_path, new_file_path)
        print(f"Het bestand {filename} is hernoemd naar {filename}.py")

print("Alle bestanden zijn succesvol hernoemd.")
