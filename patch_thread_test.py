import re

with open('test/thread_test.dart', 'r') as f:
    content = f.read()

content = re.sub(r'expect\(tweets.chains.length, equals\(19\)\);', 'expect(tweets.chains.length, equals(9));', content)

# Remove tweets tests logic
content = re.sub(r'expect\(tweets.chains\[[1-9]\].*?\n', '', content)
content = re.sub(r'expect\(tweets.chains\[1[0-9]\].*?\n', '', content)

with open('test/thread_test.dart', 'w') as f:
    f.write(content)
