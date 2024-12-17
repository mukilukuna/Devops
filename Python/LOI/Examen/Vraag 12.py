class Hotel:
    def __init__(self, aantal_kamers):
        self.gast_in_kamer = {}
        for k in range(1, aantal_kamers+1):
            self.gast_in_kamer[k] = ""

    def inchecken(self, gast, kamer):
        if self.gast_in_kamer[kamer] == "":
            # kamer is vrij
            self.gast_in_kamer[kamer] = gast
            resultaatcode = self.gast_in_kamer[kamer] + "ingecheckt"
        else:
            resultaatcode = "Fout: kamer is bezet"
        return resultaatcode

    def uitchecken(self, kamer):
        if self.gast_in_kamer[kamer] != "":
            resultaatcode = self.gast_in_kamer[kamer] + "uitgecheckt"
            self.gast_in_kamer[kamer] = ""
        else:
            resultaatcode = "Fout: geen gast in de kamer"
        return resultaatcode

    def aantal_kamers_bezet(self):
        s = 0
        for g in self.gast_in_kamer.values():
            if g != "":
                s += 1
            return s

    def wie_in_kamer(self, kamer):
        return self.gast_in_kamer[kamer]

    def __str__(self):
        return '[{:>5} {:<10}]'.format("Aantal kamers", len(self.gast_in_kamer))

    class BoetiekHotel(Hotel):
        def __init__(self, namen_kamers):
            self.gast_in_kamer = {}
            for k in namen_kamers:
                self.gast_in_kamer[k] = ""
