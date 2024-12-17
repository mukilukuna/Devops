import re


def filter_tekst(tekst, f):
    resultaat = []
    woorden = re.split("[,.]+", tekst)
    for woord in woorden:
        if f(woord.lower()):
            resultaat.append(woord)
    return resultaat


print(filter_tekst(
    """Zie ginds komt de stoomboot uit Spanje weer aan. Hij brengt ons Sint-Nicolaas, ik zie hem al staan""",
    lambda w: len(w) > 0 and w[0] == "S"))
