filepath = "./memfiles/decimal.mem"
file = open(filepath, mode="w")
resolution = 10
num = 10**resolution
lines = []
for i in range(30):
    num /= 2
    cur_num = round(num)
    print(cur_num)
    lines.append(hex(cur_num)[2:] + "\n")
file.writelines(lines)