#!/usr/bin/env bash
# Pokedex.sh - Muestra Nombre, Peso en kg y Ranking general de peso.
# Uso: ./Pokedex.sh snorlax | ./Pokedex.sh --sync

if [ "$#" -ne 1 ]; then
  echo "Error: ingresa solo el nombre de un pokemon o la opcion --sync."
  exit 2
fi

API="https://pokeapi.co/api/v2"
DIR="data"
mkdir -p "$DIR" 

bajar() {
  local c
  c=$(curl -sS -m 15 -w '%{http_code}' -o "$2" "$1" 2>/dev/null)
  [ -z "$c" ] || [ "$c" = "000" ] && sleep 0.2 &&
    c=$(curl -sS -m 15 -w '%{http_code}' -o "$2" "$1" 2>/dev/null)
  echo "${c:-000}"
}

# --- Modo --sync ---------------------------------------------------------
if [ "$1" = "--sync" ]; then
  lista=$(mktemp)
  bajar "$API/pokemon?limit=151" "$lista" >/dev/null
  for n in $(grep -o '"name":"[^"]*"' "$lista" | sed 's/"name":"//;s/"$//'); do
    [ -s "$DIR/$n.json" ] && continue
    [ "$(bajar "$API/pokemon/$n" "$DIR/$n.json")" = "200" ] || rm -f "$DIR/$n.json"
    sleep 0.2
  done
  rm -f "$lista"
  exit 0
fi

# --- Busqueda del pokemon ------------------------------------------------
name=$(echo "$1" | tr 'A-Z' 'a-z')
file="$DIR/$name.json"

if [ ! -s "$file" ]; then
  code=$(bajar "$API/pokemon/$name" "$file")
  if [ "$code" = "404" ]; then
    rm -f "$file"
    echo "Pokemon no encontrado."
    exit 1
  elif [ "$code" != "200" ]; then
    rm -f "$file"
    echo "Error de conexion (HTTP $code)."
    exit 1
  fi
fi

# Procesamiento exacto en Python evitando errores de sintaxis JSON
python3 - "$file" "$DIR" << 'EOF'
import sys
import os
import json

target_file = sys.argv[1]
data_dir = sys.argv[2]

# Cargar el pokemon objetivo
try:
    with open(target_file, 'r', encoding='utf-8') as f:
        target_data = json.load(f)
        target_name = target_data['name'].lower()
        target_weight = target_data['weight']
except Exception as e:
    print("Error al leer el archivo del pokemon consultado.")
    sys.exit(1)

# Cargar la lista completa de la cache
pokemons = []
for filename in os.listdir(data_dir):
    if filename.endswith(".json"):
        filepath = os.path.join(data_dir, filename)
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                d = json.load(f)
                if 'name' in d and 'weight' in d:
                    pokemons.append({
                        'name': d['name'].lower(),
                        'weight': d['weight']
                    })
        except Exception:
            continue

# Ordenar de mayor a menor peso
pokemons.sort(key=lambda x: x['weight'], reverse=True)

total = len(pokemons)
rank = 1
for i, p in enumerate(pokemons, start=1):
    if p['name'] == target_name:
        rank = i
        break

weight_kg = target_weight / 10.0
print(f"Nombre: {target_name}")
print(f"Peso: {weight_kg:.1f} kg")
print(f"Ranking de peso: #{rank} de {total}")
EOF
