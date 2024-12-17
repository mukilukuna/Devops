onderwijs = {
    "Vmbo": "Voorbereidend middelbaar beroepsonderwijs",
    "Havo": "Hoger algemeen voortgezet onderwijs",
    "Vwo": "Voorbereidend wetenschappelijk onderwijs",
    "Mbo": "Middelbaar beroepsonderwijs",
    "Hbo": "Hoger beroepsonderwijs",
    "Wo": "Wetenschappelijk onderwijs"
}

onderwijs["Mavo"] = "Middelbaar algemeen voorgezet onderwijs"
# print(onderwijs)

new_onderwijs = sorted(list(onderwijs.values()))
print(new_onderwijs)
