# Write a Python program that requests an integer value from the user. If the value is between 1 and
# 100 inclusive, print ”OK;” otherwise, do not print anything

Punten = int(input("Schrijf een waarde tussen de 1 en 100: "))

if Punten <= 100:
    print("Lager dan 100")
else:
    print("Hoger dan 100")
