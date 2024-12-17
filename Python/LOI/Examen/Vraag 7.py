provincies = ["Drenthe", "Friesland", "Gelderland", "Groningen",
              "Limburg", "Noord-Brabant", "Noord-Holland", "Overijssel",
              "Utrecht", "Zeeland", "Zuid-Holland",]
print(len(provincies[10]))

provincies.insert(1, "Flevoland")
print(provincies)

gemeenten = provincies[-6:]
print(gemeenten)
