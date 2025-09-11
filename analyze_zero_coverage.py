lines = open('coverage/lcov.info').readlines()
files = {}
current_file = None

for line in lines:
    if line.startswith('SF:'):
        current_file = line.split(':')[1].strip()
        files[current_file] = {'total': 0, 'hit': 0}
    if line.startswith('LF:') and current_file:
        files[current_file]['total'] = int(line.split(':')[1])
    if line.startswith('LH:') and current_file:
        files[current_file]['hit'] = int(line.split(':')[1])

zero_cov = [f for f, data in files.items() if data['total'] > 0 and data['hit'] == 0 and 'generated' not in f]
for f in zero_cov:
    print(f)