#!/usr/bin/env bash
# Pokedex.sh - imprime "Id, Nombre y Peso" de un pokemon (peso en kg)
# Uso: ./Pokedex.sh pikachu   |   ./Pokedex.sh --sync
 
# --- Validacion: exactamente un argumento -------------------------------
if [ "$#" -eq 0 ]; then                                  # no se paso nada
  echo "Error: ingresa solo el nombre del pokemon."      # avisa al usuario
  exit 2                                                 # cancela la busqueda
fi
if [ "$#" -gt 1 ]; then                                  # se pasaron 2 o mas
  echo "Error: ingresa solo el nombre del pokemon."      # mismo mensaje
  exit 2                                                 # cancela la busqueda
fi
 
API="https://pokeapi.co/api/v2"          # base de la PokeAPI
DIR="data"                               # carpeta cache de los json
mkdir -p "$DIR"                          # la crea si no existe
 
# Descarga $1 en el archivo $2 y devuelve el codigo HTTP (000 = fallo de red)
bajar() {
  local c                                                        # codigo HTTP
  c=$(curl -sS -m 15 -w '%{http_code}' -o "$2" "$1" 2>/dev/null) # intento 1
  [ -z "$c" ] || [ "$c" = "000" ] && sleep 0.2 &&                # si fallo la red, pausa
    c=$(curl -sS -m 15 -w '%{http_code}' -o "$2" "$1" 2>/dev/null) # unico reintento
  echo "${c:-000}"                                               # devuelve el codigo
}
 
# Imprime el registro en una sola linea, con el peso convertido a kg
mostrar() {
  jq -r '"\(.id), \(.name), \(.weight/10) kg"' "$1"  # hectogramos /10 = kg
}
 
# --- Modo --sync: descarga los 151 originales ---------------------------
if [ "$1" = "--sync" ]; then                       # si el argumento es --sync
  lista=$(mktemp)                                  # temporal para el indice
  bajar "$API/pokemon?limit=151" "$lista" >/dev/null # baja la lista de nombres
  for n in $(jq -r '.results[].name' "$lista"); do # recorre los 151 nombres
    [ -s "$DIR/$n.json" ] && continue              # si ya existe, no lo descarga
    [ "$(bajar "$API/pokemon/$n" "$DIR/$n.json")" = "200" ] ||  # intenta bajarlo
      rm -f "$DIR/$n.json"                         # si fallo, borra el parcial
    sleep 0.2                                      # pausa de 0.2 s entre peticiones
  done
  rm -f "$lista"                                   # limpia el temporal
  exit 0                                           # termina bien
fi
 
# --- Busqueda del pokemon ------------------------------------------------
name=$(echo "$1" | tr 'A-Z' 'a-z')                 # normaliza a minusculas
file="$DIR/$name.json"                             # ruta del cache
 
[ -s "$file" ] && { mostrar "$file"; exit 0; }     # si esta en cache, lo usa
 
code=$(bajar "$API/pokemon/$name" "$file")         # consulta a la API
[ "$code" = "404" ] && { rm -f "$file"; echo "No encontrado"; exit 1; }    # no existe
[ "$code" = "200" ] || { rm -f "$file"; echo "Error HTTP $code"; exit 1; } # otro error
mostrar "$file"                                    # imprime id, nombre y peso
 