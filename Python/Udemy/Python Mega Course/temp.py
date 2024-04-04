filenames = ['data/file1.txt', 'data/file2.txt', 'data/file3.txt']

for filename in filenames:
    filename = filename.replace('data/', '')
    print(filename)