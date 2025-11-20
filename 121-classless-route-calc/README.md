# DHCP Option 121 — Classless Static Route Hex Calculator

A simple, cross‑platform calculator for generating **DHCP Option 121 (Classless Static Route)** hex values.  
Works on **Linux, macOS, Windows** and is valid for **MikroTik, Cisco, Linux clients, BSD, etc.**

This tool converts:
- **Destination subnet**
- **Prefix length**
- **Gateway IP**

into the raw **binary‑encoded hex** required by DHCP Option 121 (RFC 3442).

---

## 🚀 Usage

Save the script as **`opt121.py`** and run:

```bash
python3 opt121.py <dest> <prefix> <gateway>
```

Example:

```bash
python3 opt121.py 169.254.169.254 32 188.116.50.193
```

### ✔️ Features
- Outputs raw uppercase hex
- Supports multiple routes in a single command
- Correctly encodes prefix lengths
- Requires no external dependencies

---

## 🧠 How It Works

DHCP Option 121 encodes routes as:

```
<prefix-length> <destination-bytes> <gateway-4bytes>
```

Destination bytes depend on prefix:
- /0 → 0 bytes  
- /8 → 1 byte  
- /16 → 2 bytes  
- /24 → 3 bytes  
- /32 → 4 bytes  

The script handles this automatically.

---

## 🧩 Python Script

```python
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
```

---

## 🧪 Examples

### Multiple routes

```bash
python3 opt121.py \
    169.254.169.254 32 188.116.50.193 \
    0.0.0.0 0 188.116.50.193
```

### Output

```
20A9FEA9FEBC7432C1 00BC7432C1
```

Concatenate them for use in RouterOS, ISC DHCP, or dnsmasq.

---

## 💡 Want More?

I can generate:
- A **web‑based HTML/JS calculator**
- A **RouterOS script** that builds the hex automatically
- A version in **Go**, **Rust**, or **bash**

Just ask!
