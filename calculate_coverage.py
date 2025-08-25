import re

total_lines = 0
hit_lines = 0

with open('coverage/lcov.info', 'r') as f:
    for line in f:
        if line.startswith('LF:'):
            total_lines += int(line.split(':')[1])
        if line.startswith('LH:'):
            hit_lines += int(line.split(':')[1])

if total_lines == 0:
    coverage = 0
else:
    coverage = (hit_lines / total_lines) * 100

print(f'Total lines: {total_lines}')
print(f'Hit lines: {hit_lines}')
print(f'Coverage: {coverage:.2f}%')