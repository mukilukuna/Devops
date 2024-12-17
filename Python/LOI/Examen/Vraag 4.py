# Prompts user to input their birth year as an integer
geb_jaar = int(input("Geef geboortejaar: "))
# Determines the generation based on the user's birth year input


if geb_jaar in range(2016, 2031):
    generatie = "Generatie Alpha"
elif geb_jaar in range(2001, 2016):
    generatie = "Generatie Z"
elif geb_jaar in range(1986, 2001):
    generatie = "Generatie y"
elif geb_jaar in range(1971, 1986):
    generatie = "Pragmatische generatie"
elif geb_jaar in range(1956, 1971):
    generatie = "Generatie X"
elif geb_jaar in range(1941, 1956):
    generatie = "Protestgeneratie"
elif geb_jaar in range(1925, 1941):
    generatie = "Stille generatie"
else:
    generatie = "onbekend"

print(generatie)
