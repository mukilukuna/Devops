def omrekenen_naar_euro(bedrag, valutacode):
    """Retourneert: het bedrag in vreemde valuta (afgerond op 2 decimalen),
       of None als de valutacode niet bekend is.
       Voorbeeld: omrekenen_naar_euro(112.22, 'USD') = 100
       Preconditie: bedrag is een getal en valutacode een string"""
    koers = {
        'USD': 1.1222,
        'GBP': 0.8585,
        'JPY': 125.18
    }

    try:
        return round(bedrag / koers[valutacode], 2)
    except KeyError:
        return None

# lbyl principe, er wordt eerst gecontroleerd of de ingevoerde waarde valutacode voorkomt in de koers dictionary
