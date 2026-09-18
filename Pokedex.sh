#!/usr/bin/env python3
import urllib.request
import json
import sys

def main():
    while True:
        print("=========================")
        print("        POKEDEX")
        print("=========================")
        print("")
        
        try:
            pokemon_input = input("Escribe el nombre de un pokemon (o 'salir' para terminar): ").strip().lower()
        except (KeyboardInterrupt, EOFError):
            print("\n¡Hasta luego!")
            sys.exit(0)

        # Condición para salir del programa
        if pokemon_input in ['salir', 'exit', 'q']:
            print("¡Hasta luego!")
            break

        if not pokemon_input:
            print("")
            continue

        url = f"https://pokeapi.co/api/v2/pokemon/{pokemon_input}"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})

        try:
            with urllib.request.urlopen(req) as response:
                data = json.loads(response.read().decode('utf-8'))
                
                name = data['name'].capitalize()
                types = [t['type']['name'] for t in data['types']]
                types_str = ", ".join(types)

                print(f"\n{name}")
                print(f"Tipo: {types_str}\n")

        except urllib.error.HTTPError as e:
            if e.code == 404:
                print("Pokemon no encontrado.\n")
            else:
                print(f"Error al consultar la API (Código: {e.code}).\n")
        except urllib.error.URLError:
            print("Error al conectar con la PokéAPI. Comprueba tu conexión a internet.\n")

if __name__ == "__main__":
    main()
