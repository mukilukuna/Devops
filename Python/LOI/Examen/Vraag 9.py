import hashlib


def controleer_wachtwoord(user, passw):
    try:
        with open("password.bin", "rb") as file:
            blokl = file.read(8)
            blok2 = file.read(16)

            while blokl != b'':         # zolang geen eof
                f_user = blokl.decode('ascii')
                f_hash = blok2

                if f_user == user:
                    hashed_pw = \
                        hashlib.md5(passw.encode('ascii')).digest()
                    iswachtwoordOK = (hashed_pw == f_hash)
                    return iswachtwoordOK

                blokl = file.read(8)
                blok2 = file.read(16)
            return "Gebruiker niet gevonden"
    except FileNotFoundError:
        return "Bestand niet gevonden"
