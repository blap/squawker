import re

file_coverage = {}
current_file = None

with open('coverage/lcov.info', 'r') as f:
    for line in f:
        if line.startswith('SF:'):
            current_file = line.split(':')[1].strip()
            file_coverage[current_file] = {'total': 0, 'hit': 0}
        if line.startswith('LF:'):
            file_coverage[current_file]['total'] = int(line.split(':')[1])
        if line.startswith('LH:'):
            file_coverage[current_file]['hit'] = int(line.split(':')[1])

for file, data in file_coverage.items():
    total = data['total']
    hit = data['hit']
    if total == 0:
        coverage = 0
    else:
        coverage = (hit / total) * 100
    print(f'{file}: {coverage:.2f}%')