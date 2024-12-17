a = 6
b = 5.5
c = "tuk"
d = "je"
e = "3"
f = []
g = tuple(f)
h = 17

print(a/int(b))  # 1.2
print(type(h % b))  # float
print(c*2+e)  # tuktuk3
# print(c*e+2) #type error
print(c+str(d))  # tukje
print(b*10**3)  # 5500
print(str(b) < e)  # False
print(g.append(7))  # typeerror
