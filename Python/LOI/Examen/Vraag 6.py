# omdat de status niet een globale varaibel is

status = "actief"


def deactiveer_proces():
    global status
    status = "non-actief"


def maak_uitvoer():
    if status == "actief":
        uitvoer = "12345678"
    else:
        uitvoer = None
    return uitvoer


print(maak_uitvoer())
deactiveer_proces()
print(maak_uitvoer())

# maak_uitvoer is niet een globale variabel. de functie kan een andere resultaat tonen indien de informatie van buitenaf anders is
# lokale variabel


# er moet een return gezet worden onder non-actief zodat de parameter mee genomen wordt in de globale code.
