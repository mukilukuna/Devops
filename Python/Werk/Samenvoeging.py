import pandas as pd
import os

# Map waarin de bestanden zich bevinden
folder_path = r'C:\Users\MukiLukunaITSynergy\IT Synergy\Aurora Group B.V. - Documents\General\Professional Services\Project - Online Werkplek\Inventarisatie Fase\Export'

# Lijst met de bestandsnamen
excel_files = [
    'exportDevice_2025-3-4.xlsx',
    'INTUNE MANAGED.xlsx',
    'ESET.xlsx'
]

# Lege lijst om de ingelezen dataframes op te slaan
dataframes = []

# Lees elk Excel-bestand in
for file in excel_files:
    file_path = os.path.join(folder_path, file)
    df = pd.read_excel(file_path)  # Leest de eerste sheet in
    dataframes.append(df)

# Merge de dataframes samen op de primaire sleutel 'Email address'
# Begin met het samenvoegen van de eerste twee bestanden
merged_df = dataframes[0]
for i in range(1, len(dataframes)):
    merged_df = pd.merge(merged_df, dataframes[i], on='DeviceName', how='outer')

# Voeg het derde bestand toe aan de al samengevoegde dataframes
#merged_df = pd.merge(merged_df, dataframes[2], on='Email address', how='outer')

# Opslaan van de samengevoegde data naar een nieuw Excel-bestand
output_file = os.path.join(folder_path, 'merged_output2.xlsx')
merged_df.to_excel(output_file, index=False)

print(f"Data is succesvol samengevoegd en opgeslagen in '{output_file}'")
