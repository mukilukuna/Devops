import random
a = 0
juiste_nummer = random.randint(0, 5)
for a in range(5):
    gues = int(input("gues a number: "))
    if gues == juiste_nummer:
        print("Correct jouw keuze was, ", gues, ". Het koste je", a, " keren.")
        break
    elif gues <= juiste_nummer:
        print("te laag")
    elif gues >= juiste_nummer:
        print("te hoog")
a = + 1
print("fout, de juiste nummer was: ", juiste_nummer)
