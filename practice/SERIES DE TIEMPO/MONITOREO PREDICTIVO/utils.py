from unicodedata import normalize, category

import pandas as pd
print("CONEXION CON UTILITARIOS")




def clean_text(val):
    return ''.join(
        [_ for _ in normalize('NFD', val.lower()) if category(_) in ['Ll', 'Nd', 'Zs']]
    )
