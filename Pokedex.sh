#!/usr/bin/env python3  # Indica que el archivo debe ejecutarse con Python 3.

import urllib.request  # Importa las herramientas para realizar peticiones HTTP.
import json  # Importa las herramientas para interpretar respuestas en formato JSON.
import sys  # Importa funciones del sistema, como salir del programa.


def main():  # Define la función principal del programa.
    while True:  # Repite el menú hasta que el usuario decida salir.
        print("=========================")  # Imprime la línea superior del encabezado.
        print("        POKEDEX")  # Imprime el título de la aplicación.
        print("=========================")  # Imprime la línea inferior del encabezado.
        print("")  # Deja una línea en blanco para mejorar la lectura.

        try:  # Intenta leer el nombre del Pokémon introducido por el usuario.
            pokemon_input = input("Escribe el nombre de un pokemon (o 'salir' para terminar): ").strip().lower()  # Lee, limpia y convierte a minúsculas la entrada.
        except (KeyboardInterrupt, EOFError):  # Captura Ctrl+C y el final inesperado de la entrada.
            print("\n¡Hasta luego!")  # Muestra el mensaje de despedida.
            sys.exit(0)  # Termina el programa indicando que finalizó correctamente.

        if pokemon_input in ['salir', 'exit', 'q']:  # Comprueba las opciones que permiten salir.
            print("¡Hasta luego!")  # Muestra el mensaje de despedida.
            break  # Rompe el bucle principal y finaliza el menú.

        if not pokemon_input:  # Comprueba si el usuario no escribió ningún nombre.
            print("")  # Deja una línea en blanco antes de volver al menú.
            continue  # Salta al comienzo de la siguiente iteración.

        url = f"https://pokeapi.co/api/v2/pokemon/{pokemon_input}"  # Construye la dirección de consulta para el Pokémon indicado.
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})  # Crea la petición HTTP con un identificador de navegador.

        try:  # Intenta conectarse a la PokéAPI y procesar su respuesta.
            with urllib.request.urlopen(req) as response:  # Abre la dirección y guarda la respuesta temporalmente.
                data = json.loads(response.read().decode('utf-8'))  # Lee la respuesta, la decodifica y la convierte desde JSON.

                name = data['name'].capitalize()  # Obtiene el nombre y pone su primera letra en mayúscula.
                types = [t['type']['name'] for t in data['types']]  # Extrae el nombre de cada tipo del Pokémon.
                types_str = ", ".join(types)  # Une los tipos en una sola cadena separada por comas.
                abilities = [a['ability']['name'] for a in data['abilities']]  # Extrae el nombre de cada habilidad del Pokémon.
                abilities_str = ", ".join(abilities)  # Une las habilidades en una sola cadena separada por comas.

                print(f"\n{name}")  # Muestra el nombre del Pokémon consultado.
                print(f"Tipo: {types_str}")  # Muestra los tipos del Pokémon.
                print(f"Habilidades: {abilities_str}\n")  # Muestra las habilidades del Pokémon y deja una línea en blanco.

        except urllib.error.HTTPError as e:  # Captura errores HTTP devueltos por el servidor.
            if e.code == 404:  # Comprueba si el servidor indica que el Pokémon no existe.
                print("Pokemon no encontrado.\n")  # Informa de que no se encontró el Pokémon.
            else:  # Atiende cualquier otro código de error HTTP.
                print(f"Error al consultar la API (Código: {e.code}).\n")  # Muestra el código del error recibido.
        except urllib.error.URLError:  # Captura errores de conexión con la API.
            print("Error al conectar con la PokéAPI. Comprueba tu conexión a internet.\n")  # Informa de que no fue posible conectar.


if __name__ == "__main__":  # Comprueba si el archivo se está ejecutando directamente.
    main()  # Inicia la función principal del programa.