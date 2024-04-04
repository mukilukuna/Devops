todos = []
while True:
    gebruikers_input = input(
        "je krijgt drie opties om uit te kiezen. die zijn: 'stop', 'toon' en 'toevoegen': ")
    gebruikers_input = gebruikers_input.strip()
    match gebruikers_input:
        case "stop" | "quit":
            break
        case "toon" | "show":
            for item in todos:
                print(item)
        case "toevoegen" | "add":
            todo = input("wat is de todo: ")
            todos.append(todo.capitalize())
        case _:
            print("Jouw input wordt niet herkend door de programma, probeer het opnieuw")
print(todos)
