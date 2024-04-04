print("Python Calculator App".title())


def play_again():
    return input("Do you want to play again (y/n): ").strip().lower() == "y"


while True:
    first_number = int(input("Enter first number: "))
    second_number = int(input("Enter second number: "))
    operator = input("Choose an operator (+, -, *, /, **): ")

    if operator == "+":
        print(f"{first_number} + {second_number} = {first_number + second_number}")
    elif operator == "-":
        print(f"{first_number} - {second_number} = {first_number - second_number}")
    elif operator == "*":
        print(f"{first_number} * {second_number} = {first_number * second_number}")
    elif operator == "/":
        print(f"{first_number} / {second_number} = {first_number / second_number}")
    elif operator == "**":
        print(f"{first_number} ** {second_number} = {first_number ** second_number}")
    else:
        print("Invalid operator!")
        break

    if not play_again():
        print("Ending game...")
        break
