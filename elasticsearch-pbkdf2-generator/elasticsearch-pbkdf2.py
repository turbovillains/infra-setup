#!/usr/bin/env python3
# https://gist.githubusercontent.com/npdgm/c028a56aaca11764e7de58740311d723/raw/adc412ec322d7164d06cf272b90fd6034979dd8a/elasticsearch-pbkdf2.py
try:
    import argparse
    from getpass import getpass
    from secrets import token_bytes
    from binascii import b2a_base64
    from hashlib import pbkdf2_hmac
except ImportError as err:
    print('Python 3.6 or newer is required!\n')
    raise err

DESCRIPTION = '''
Computes PBKDF2 password hashes for ElasticSearch xpack\n
Uses PBKDF2 key derivation function with HMAC-SHA512 as a pseudorandom function
using a specified number of iterations. It conforms to the getPbkdf2Hash()
implementation for xpack.security.authc.password_hashing.algorithm values
pbkdf2, pbkdf2_1000, pbkdf2_10000, pbkdf2_50000, pbkdf2_100000, pbkdf2_500000,
or pbkdf2_1000000.
'''

parser = argparse.ArgumentParser(description=DESCRIPTION, formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('--iterations', type=int, default=10000,
                    choices=(1000, 10000, 50000, 100000, 500000, 1000000),
                    help='Number of iterations (default: %(default)s)')
parser.add_argument('--password', '-p', help='Provide cleartext password as argument instead of reading input')
args = parser.parse_args()

if args.password:
    password = args.password.encode()
else:
    password = getpass('Password: ').encode()
assert(len(password))

salt = token_bytes(32)
salt_b64 = b2a_base64(salt, newline=False).decode()
assert(len(salt_b64) == 44)

pbkdf2 = pbkdf2_hmac('sha512', password, salt, args.iterations, dklen=32)
pbkdf2_b64 = b2a_base64(pbkdf2, newline=False).decode()
assert(len(pbkdf2_b64) == 44)

elastic_hash = '{{PBKDF2}}{}${}${}'.format(args.iterations, salt_b64, pbkdf2_b64)
print(elastic_hash)
