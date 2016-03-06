#!/usr/bin/python
# -*- coding: utf-8 -*-

import csv, re, collections

archivo_dibujitos = "../simbolos/UGRcompleta.csv"
archivo_datos = "../listas/201415matriculasgradoramas.csv"
archivo_plantilla = "plantilla.html"
archivo_salida = "../index.html"

churro_commpleto = ""
icono = {}
dicc_churros = {}
dicc_stats = {}


def crea_url(nombre):
    return re.sub(r'[^A-Za-z0-9]', '', nombre) + ".html"

def crea_combo(diccionario):

    combo = '<select onchange="location.href=this.options[this.selectedIndex].value" name="carreras" size="1"><option value="#" selected>ELIJA UNA</option><option value="index.html">Todas</option>'
    diccionario = collections.OrderedDict(sorted(diccionario.items()))

    for pag in diccionario:
        combo = combo + '<option value="' + crea_url(pag) + '">' + pag + '</option>'

    combo = combo + '</select>'

    return combo


with open(archivo_plantilla, 'r') as plantilla:
    pagina_completa = plantilla.read()

with open(archivo_dibujitos, 'r') as dibujitos:
    lista_dibujitos = csv.reader(dibujitos)

    # Nos saltamos la primera línea
    lista_dibujitos.next()

    for fila in lista_dibujitos:
        try:
            icono[fila[0]] = fila[1]
        except IndexError:
            pass

with open(archivo_datos, 'r') as datos:
    lista_datos = csv.reader(datos)

    # Nos saltamos la primera línea
    lista_datos.next()
    for fila in lista_datos:
        try:
            churro_hombres = ("<a href='" + crea_url(fila[1]) + "' class='hombres' title='" + fila[1] + " (hombres)'>" + icono[fila[1]] + "</a> ") * int(fila[2])
            churro_mujeres = ("<a href='" + crea_url(fila[1]) + "' class='mujeres' title='" + fila[1] + " (mujeres)'>" + icono[fila[1]] + "</a> ") * int(fila[3])

            dicc_churros[fila[1]] = churro_hombres + churro_mujeres

        except KeyError:
            churro_hombres = ("<a href='" + crea_url(fila[1]) + "' class='hombres' title='" + fila[1] + " (hombres)'>X</a> ") * int(fila[2])
            churro_mujeres = ("<a href='" + crea_url(fila[1]) + "' class='mujeres' title='" + fila[1] + " (mujeres)'>X</a> ") * int(fila[3])

            dicc_churros[fila[1]] = churro_hombres + churro_mujeres

        churro_commpleto = churro_commpleto + churro_hombres + churro_mujeres

        dicc_stats[fila[1]] = "Del total de {0} matriculados: <span class='hombres'>{1}</span> hombres (<span class='hombres'>{2:.2f} %</span>), <span class='mujeres'>{3}</span> mujeres (<span class='mujeres'>{4:.2f}</span> %)".format(fila[4], fila[2], float(fila[2])/int(fila[4])*100, fila[3], float(fila[3])/int(fila[4])*100)



seleccion = crea_combo(dicc_churros)


for pag in dicc_churros:

    nombre_pagina = "../" + crea_url(pag)

    contenido = pagina_completa

    contenido = contenido.replace("[REPLACE_TITULO]", pag)
    contenido = contenido.replace("[REPLACE_MENU]", seleccion)
    contenido = contenido.replace("[REPLACE_CONTENIDO]", dicc_churros[pag])
    contenido = contenido.replace("[REPLACE_STATS]", dicc_stats[pag])

    with open(nombre_pagina, 'w') as pagina:
        pagina.write(contenido)


with open(archivo_salida, 'w') as pagina:

    pagina_completa = pagina_completa.replace("[REPLACE_TITULO]", "Todas las carreras")
    pagina_completa = pagina_completa.replace("[REPLACE_MENU]", seleccion)
    pagina_completa = pagina_completa.replace("[REPLACE_STATS]", "")
#    pagina_completa = pagina_completa.replace("[REPLACE_CONTENIDO]", churro_commpleto)

    pagina.write(pagina_completa)

# print churro_commpleto
