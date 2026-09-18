#!/usr/bin/env bash
# Indica que el script debe ejecutarse usando Bash.
#
# pokedex.sh - Consulta datos de un Pokémon en la PokeAPI.
#
# Uso:
#   ./pokedex.sh <nombre-pokemon> # Ejecuta el script con el nombre del Pokemon.
#
# Salida:
#   id:(id), nombre:(nombre), altura:(altura)   # Muestra los datos si el Pokemon existe.
#   "No encontrado" y sale con código 1          # Informa si la API devuelve HTTP 404.

set -euo pipefail # Detiene errores, variables no definidas y fallos dentro de tuberias.

if [ $# -ne 1 ]; then # Comprueba que se haya recibido exactamente un argumento.
    echo "Uso: $0 <nombre-pokemon>" >&2 # Muestra la forma correcta de usar el script.
    exit 1 # Termina con error porque falta o sobra un argumento.
fi

nombre="$1" # Guarda el nombre del Pokemon recibido como primer argumento.
url="https://pokeapi.co/api/v2/pokemon/${nombre}" # Construye la URL de consulta a la PokeAPI.

# Descarga el cuerpo de la respuesta y captura el codigo HTTP por separado.
respuesta_tmp="$(mktemp)" # Crea un archivo temporal para guardar la respuesta JSON.
trap 'rm -f "$respuesta_tmp"' EXIT # Borra el archivo temporal al terminar el script.

http_code="$(curl -s -o "$respuesta_tmp" -w '%{http_code}' "$url")" # Consulta la API y guarda su codigo HTTP.

if [ "$http_code" = "404" ]; then # Comprueba si el Pokemon no existe.
    echo "No encontrado" # Informa que no se encontro el Pokemon solicitado.
    exit 1 # Termina indicando que la busqueda no tuvo resultados.
elif [ "$http_code" != "200" ]; then # Comprueba si ocurrio otro error HTTP.
    echo "Error: la API respondió con código HTTP $http_code" >&2 # Muestra el codigo del error.
    exit 1 # Termina indicando que la consulta fallo.
fi

id="$(sed -n 's/.*"id":[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$respuesta_tmp")" # Extrae el identificador desde el JSON.
nombre_api="$(sed -n 's/.*"id":[[:space:]]*[0-9][0-9]*,[[:space:]]*"name":[[:space:]]*"\([^"]*\)".*/\1/p' "$respuesta_tmp")" # Extrae el nombre principal asociado al identificador.
altura="$(sed -n 's/.*"height":[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$respuesta_tmp")" # Extrae la altura desde el JSON.
printf 'Identificador de pokemon: "%s", nombre del pokemon: "%s", altura: "%sdm"\n' "$id" "$nombre_api" "$altura" # Muestra el identificador y el nombre del Pokemon.

