#!/usr/bin/env bash
#
# pokedex.sh - Consulta datos de un Pokémon en la PokeAPI
#
# Uso:
#   ./pokedex.sh <nombre-pokemon>
#
# Salida:
#   id,nombre,altura   (si existe)
#   "No encontrado" y sale con código 1 (si no existe, HTTP 404)

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Uso: $0 <nombre-pokemon>" >&2
    exit 1
fi

nombre="$1"
url="https://pokeapi.co/api/v2/pokemon/${nombre}"

# Descargamos el cuerpo de la respuesta y capturamos el código HTTP por separado
respuesta_tmp="$(mktemp)"
trap 'rm -f "$respuesta_tmp"' EXIT

http_code="$(curl -s -o "$respuesta_tmp" -w '%{http_code}' "$url")"

if [ "$http_code" = "404" ]; then
    echo "No encontrado"
    exit 1
elif [ "$http_code" != "200" ]; then
    echo "Error: la API respondió con código HTTP $http_code" >&2
    exit 1
fi

jq -r '[.id, .name, .height] | @csv' "$respuesta_tmp"