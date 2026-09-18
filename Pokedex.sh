#!/usr/bin/env bash
# Indica que el archivo debe ejecutarse con Bash.

API_URL="https://pokeapi.co/api/v2/pokemon" # Guarda la dirección base de la PokéAPI.

while true; do # Repite el menú hasta que el usuario decida salir.
    echo "=========================" # Imprime la línea superior del encabezado.
    echo "        POKEDEX" # Imprime el título de la aplicación.
    echo "=========================" # Imprime la línea inferior del encabezado.
    echo # Deja una línea en blanco para mejorar la lectura.

    read -r -p "Escribe el nombre de un pokemon (o 'salir' para terminar): " pokemon_input # Lee el nombre del Pokémon.
    pokemon_input=$(printf '%s' "$pokemon_input" | tr '[:upper:]' '[:lower:]' | sed 's/^ *//;s/ *$//') # Limpia espacios y convierte la entrada a minúsculas.

    if [[ "$pokemon_input" == "salir" || "$pokemon_input" == "exit" || "$pokemon_input" == "q" ]]; then # Comprueba las opciones para salir.
        echo "¡Hasta luego!" # Muestra el mensaje de despedida.
        break # Termina el bucle principal.
    fi # Finaliza la comprobación de salida.

    if [[ -z "$pokemon_input" ]]; then # Comprueba si no se escribió ningún nombre.
        echo # Deja una línea en blanco antes de volver al menú.
        continue # Regresa al comienzo del bucle.
    fi # Finaliza la comprobación de entrada vacía.

    response=$(curl -sS -L -A "Mozilla/5.0" -w $'\n%{http_code}' "$API_URL/$pokemon_input" 2>/dev/null) # Consulta la API y añade el código HTTP al final.
    http_code=$(printf '%s\n' "$response" | tail -n 1) # Extrae el código HTTP de la respuesta.
    data=$(printf '%s\n' "$response" | sed '$d') # Separa el JSON del código HTTP.

    if [[ "$http_code" == "404" ]]; then # Comprueba si el Pokémon no existe.
        echo "Pokemon no encontrado." # Informa de que no se encontró el Pokémon.
        echo # Deja una línea en blanco.
        continue # Regresa al menú para realizar otra consulta.
    fi # Finaliza la comprobación de Pokémon inexistente.

    if [[ "$http_code" != "200" || -z "$data" ]]; then # Comprueba errores HTTP o una respuesta vacía.
        echo "Error al consultar la API (Código: $http_code)." # Muestra el código del error recibido.
        echo # Deja una línea en blanco.
        continue # Regresa al menú para realizar otra consulta.
    fi # Finaliza la comprobación de errores de consulta.

    name=$(printf '%s' "$data" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n 1 | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/') # Extrae el nombre del Pokémon.
    name="${name^}" # Convierte la primera letra del nombre a mayúscula.
    types=$(printf '%s' "$data" | grep -o '"type"[[:space:]]*:[[:space:]]*{[^}]*}' | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | paste -sd ', ' -) # Extrae y une los tipos del Pokémon.
    abilities=$(printf '%s' "$data" | grep -o '"ability"[[:space:]]*:[[:space:]]*{[^}]*}' | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | paste -sd ', ' -) # Extrae y une las habilidades del Pokémon.

    echo # Deja una línea antes de mostrar los datos.
    echo "$name" # Muestra el nombre del Pokémon consultado.
    echo "Tipo: $types" # Muestra los tipos del Pokémon.
    echo "Habilidades: $abilities" # Muestra las habilidades del Pokémon.
    echo # Deja una línea en blanco después del resultado.
done # Finaliza el bucle principal cuando se selecciona una opción de salida.