import tkinter as tk
from tkinter import messagebox
from tkinter import ttk
import math

def add(x, y):
    return x + y

def subtract(x, y):
    return x - y

def multiply(x, y):
    return x * y

def divide(x, y):
    if y == 0:
        raise ValueError("Cannot divide by zero")
    return x / y

def power(x, y):
    return math.pow(x, y)

def sqrt(x):
    if x < 0:
        raise ValueError("Cannot take the square root of a negative number")
    return math.sqrt(x)

def sin(x):
    return math.sin(math.radians(x))

def cos(x):
    return math.cos(math.radians(x))

def tan(x):
    return math.tan(math.radians(x))

def log(x, base=10):
    if x <= 0:
        raise ValueError("Logarithm only defined for positive numbers")
    return math.log(x, base)

def factorial(x):
    if x < 0:
        raise ValueError("Factorial only defined for non-negative integers")
    return math.factorial(x)

def on_button_click(operation):
    try:
        x = float(entry_x.get())
        y = float(entry_y.get()) if entry_y.get() else None
        if operation == "add":
            result = add(x, y)
        elif operation == "subtract":
            result = subtract(x, y)
        elif operation == "multiply":
            result = multiply(x, y)
        elif operation == "divide":
            result = divide(x, y)
        elif operation == "power":
            result = power(x, y)
        elif operation == "sqrt":
            result = sqrt(x)
        elif operation == "sin":
            result = sin(x)
        elif operation == "cos":
            result = cos(x)
        elif operation == "tan":
            result = tan(x)
        elif operation == "log":
            result = log(x, y)
        elif operation == "factorial":
            result = factorial(x)
        messagebox.showinfo("Result", f"The result is: {result}")
    except ValueError as e:
        messagebox.showerror("Error", str(e))

def on_number_click(number):
    current = entry_x.get()
    entry_x.delete(0, tk.END)
    entry_x.insert(0, current + str(number))

# Create the main window
root = tk.Tk()
root.title("Math Operations")
root.geometry("400x600")
root.resizable(False, False)

# Apply a theme
style = ttk.Style(root)
style.theme_use("clam")

# Define color palette
style.configure("TFrame", background="#282c34")
style.configure("TLabel", background="#282c34", foreground="#61dafb")
style.configure("TButton", background="#61dafb", foreground="#282c34", font=("Helvetica", 12, "bold"))

# Create and place the input fields and labels
frame = ttk.Frame(root, padding="10")
frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

ttk.Label(frame, text="X:").grid(row=0, column=0, padx=5, pady=5)
entry_x = ttk.Entry(frame)
entry_x.grid(row=0, column=1, padx=5, pady=5)

ttk.Label(frame, text="Y:").grid(row=1, column=0, padx=5, pady=5)
entry_y = ttk.Entry(frame)
entry_y.grid(row=1, column=1, padx=5, pady=5)

# Create and place the number buttons
number_frame = ttk.Frame(root, padding="10")
number_frame.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

numbers = [
    (1, 0, 0), (2, 0, 1), (3, 0, 2),
    (4, 1, 0), (5, 1, 1), (6, 1, 2),
    (7, 2, 0), (8, 2, 1), (9, 2, 2),
    (0, 3, 1)
]

for number, row, col in numbers:
    button = ttk.Button(number_frame, text=str(number), command=lambda num=number: on_number_click(num))
    button.grid(row=row, column=col, padx=5, pady=5, sticky=(tk.W, tk.E))

# Create and place the operation buttons
operations = ["add", "subtract", "multiply", "divide", "power", "sqrt", "sin", "cos", "tan", "log", "factorial"]
button_frame = ttk.Frame(root, padding="10")
button_frame.grid(row=2, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

for i, operation in enumerate(operations):
    button = ttk.Button(button_frame, text=operation.capitalize(), command=lambda op=operation: on_button_click(op))
    button.grid(row=i // 3, column=i % 3, padx=5, pady=5, sticky=(tk.W, tk.E))

# Start the main event loop
root.mainloop()