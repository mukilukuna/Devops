todos = []
while True:
    gebruikers_input = input(
        "je krijgt vier opties om uit te kiezen. die zijn: 'Compleet', 'stop', 'toon' en 'toevoegen' 'aanpassen': ")
    gebruikers_input = gebruikers_input.strip()
    match gebruikers_input:
        case "stop" | "quit":
            break
        case "toon" | "show":
            file = open("Python/Udemy/Python Mega Course/todosave.txt", "r")
            todos = file.readlines()
            file.close()
            for index, item in enumerate(todos):
                print(f"{index + 1}, {item}",)
        case "toevoegen" | "add":
            todo = input("wat is de todo: ") + "\n"

            file = open("Python/Udemy/Python Mega Course/todosave.txt", "r")
            todos = file.readlines()
            file.close()

            todos.append(todo.capitalize())

            file = open("Python/Udemy/Python Mega Course/todosave.txt", "w")
            file.writelines(todos)
            file.close()
        case "aanpassen" | "edit":
            for index, item in enumerate(todos):
                print(f"{index +1}, {item}")
            number = int(
                input("Wat is de nummer van de todo die je wilt aanpassen: "))
            number = number - 1
            new_todo = input("naar wat wil je het aanpassen?: ") + "\n"
            todos[number] = new_todo
        case "compleet" | "afronden":
            file = open("Python/Udemy/Python Mega Course/todosave.txt", "r")
            todos = file.readlines()
            file.close()
            for index, item in enumerate(todos):
                print(f"{index + 1}, {item}")
            keuze = int(
                input("type de index van de item die u wilt afronden: "))
            item_om_te_verwijderen = todos[keuze - 1]
            todos.remove(item_om_te_verwijderen)
        case _:
            print("Jouw input wordt niet herkend door de programma, probeer het opnieuw")
for todo in enumerate(todos):
    print(todo)
