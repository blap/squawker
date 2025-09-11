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

urls_in_zero = any('urls.dart' in f for f in zero_cov)
share_in_zero = any('share_util.dart' in f for f in zero_cov)
cache_in_zero = any('cache.dart' in f for f in zero_cov)

print(f'urls.dart in zero coverage: {urls_in_zero}')
print(f'share_util.dart in zero coverage: {share_in_zero}')
print(f'cache.dart in zero coverage: {cache_in_zero}')

# Print all zero coverage files to see the current status
print('\nFiles with 0% coverage:')
for f in zero_cov:
    print(f)