#!/usr/bin/env python3
import sys
import ipaddress

def encode_route(dest, prefix, gw):
    prefix = int(prefix)
    dest_bytes = ipaddress.IPv4Address(dest).packed[:(prefix + 7) // 8]
    gw_bytes = ipaddress.IPv4Address(gw).packed
    return bytes([prefix]) + dest_bytes + gw_bytes

if __name__ == "__main__":
    if (len(sys.argv) - 1) % 3 != 0 or len(sys.argv) < 4:
        print("Usage: opt121.py <dest> <prefix> <gw> [<dest2> <prefix2> <gw2> ...]")
        sys.exit(1)

    routes = []
    args = sys.argv[1:]

    for i in range(0, len(args), 3):
        dest = args[i]
        prefix = args[i+1]
        gw = args[i+2]
        routes.append(encode_route(dest, prefix, gw))

    result = b''.join(routes)
    print(result.hex().upper())
