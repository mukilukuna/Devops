import re


def test_wachtwoord(ww):
    min_lengte = 8
    verpl_tekens = ("[a-z]", "[A-Z]", "[0-9]", "[!#$%&()*+,-./:;<=>?@]")

    geldig_ww = len(ww) >= 8
    for tekens in verpl_tekens:
        if re.search(tekens, ww):
            geldig_ww = geldig_ww and True
        else:
            geldig_ww = geldig_ww and False
    return geldig_ww
