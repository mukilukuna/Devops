import random


def roll():
    min_value = 1
    max_value = 6
    roll = random.randint(min_value, max_value)
    return roll


while True:
    try:
        players = int(input("hoeveel spelers doen mee aan het spel? (2-4): "))
        if 2 <= players <= 4:
            break
        else:
            print("onjuist aantal spelers")
    except ValueError:
        print("dit was een incorrecte input. het spel word afgesloten")
        exit()
print(players)
max_score = 50
speler_score = [0 for _ in range(players)]

print(speler_score)
while max(speler_score) < (max_score):
    for speler_index in range(players):
        print("\nspeler", speler_index + 1, "beurt is gestart\n")
        print("uw totale score is:", speler_score[speler_index], "\n")
        huidige_score = 0
        while True:
            should_roll = input("will je opniuew rollen? (y \ n): ")
            if should_roll.lower() != "y":
                break
            value = roll()
            if value == 1:
                print("je hebt een 1 gerold. volgende beurt")
                huidige_score = 0
                break
            else:
                print("je hebt een ", value, "gerolt!")
                huidige_score += value
            print("je score is: ", huidige_score)
        speler_score[speler_index] += huidige_score
        print("je totale score is: ", speler_score[speler_index])
max_score = max(speler_score)
winnaar = speler_score.index(max_score)
print("speler nummer", winnaar + 1, "is de winnaar met een score van", max_score)
