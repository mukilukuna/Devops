FaseToestand = int(input("voer de temperatuur in: "))

if FaseToestand < 0:
    print("vast")
elif FaseToestand == 0:
    print("Smeltend ijst")
elif FaseToestand < 100:
    print("Vloeibaar")
elif FaseToestand == 100:
    print("kokend Water")
else:
    print("Gasvormig")
