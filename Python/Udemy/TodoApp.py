todos = []
while True:
    gebruikers_input = input(
        "je krijgt drie opties om uit te kiezen. die zijn: 'stop', 'toon' en 'toevoegen' 'aanpassen': ")
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
        case "aanpassen" | "edit":
            number = int(
                input("Wat is de nummer van de todo die je wilt aanpassen: "))
            number = number - 1
            new_todo = input("naar wat wil je het aanpassen?: ")
            todos[number] = new_todo
        case _:
            print("Jouw input wordt niet herkend door de programma, probeer het opnieuw")
print(todos)
