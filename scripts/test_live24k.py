import base64
import hashlib
import json
import os
import sys
from pathlib import Path

import requests
from Crypto.Cipher import AES


URL = "https://www.goldr.org/live24k.json"


def pkcs7_unpad(data: bytes) -> bytes:
    if not data:
        return data

    pad = data[-1]

    if pad < 1 or pad > AES.block_size:
        return data

    if data[-pad:] != bytes([pad]) * pad:
        return data

    return data[:-pad]


def decrypt_aes(ciphertext: bytes, key: bytes, iv: bytes):
    try:
        if len(key) not in (16, 24, 32):
            return None

        if len(iv) != 16:
            return None

        cipher = AES.new(key, AES.MODE_CBC, iv)
        decrypted = cipher.decrypt(ciphertext)
        decrypted = pkcs7_unpad(decrypted)

        return decrypted
    except Exception:
        return None


def print_candidate(name, plaintext):
    if not plaintext:
        return

    try:
        text = plaintext.decode("utf-8", errors="replace").strip()
    except Exception:
        return

    if not text:
        return

    print()
    print("=" * 80)
    print("POSSIBLE DECRYPTION")
    print("METHOD:", name)
    print("=" * 80)
    print(text[:5000])
    print("=" * 80)

    try:
        parsed = json.loads(text)

        print()
        print("JSON DETECTED")
        print(json.dumps(parsed, ensure_ascii=False, indent=2)[:10000])

        with open("goldr_decrypted_candidate.json", "w", encoding="utf-8") as f:
            json.dump(parsed, f, ensure_ascii=False, indent=2)

    except Exception:
        with open("goldr_decrypted_candidate.txt", "w", encoding="utf-8") as f:
            f.write(text)


def make_candidates():
    values = [
        "goldr.org",
        "www.goldr.org",
        "https://goldr.org",
        "https://www.goldr.org",
        "https://www.goldr.org/",
        "https://www.goldr.org/live24k.json",
        "goldr",
        "GoldR",
        "24k",
        "live24k",
        "live24k.json",
    ]

    candidates = []

    for value in values:
        raw = value.encode("utf-8")

        candidates.append(
            (
                f"raw:{value}",
                raw,
            )
        )

        candidates.append(
            (
                f"sha256:{value}",
                hashlib.sha256(raw).digest(),
            )
        )

        candidates.append(
            (
                f"md5:{value}",
                hashlib.md5(raw).digest(),
            )
        )

        candidates.append(
            (
                f"sha1:{value}",
                hashlib.sha1(raw).digest(),
            )
        )

    return candidates


def main():
    print("=" * 80)
    print("GoldR live24k.json encryption diagnostic")
    print("=" * 80)

    try:
        response = requests.get(
            URL,
            timeout=30,
            headers={
                "User-Agent": (
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                    "AppleWebKit/537.36 "
                    "(KHTML, like Gecko) "
                    "Chrome/154.0.0.0 Safari/537.36"
                ),
                "Accept": "application/json,text/plain,*/*",
                "Referer": "https://www.goldr.org/",
            },
        )
    except Exception as e:
        print("REQUEST ERROR:", repr(e))
        sys.exit(1)

    print("STATUS:", response.status_code)
    print("CONTENT TYPE:", response.headers.get("content-type"))
    print("CONTENT LENGTH:", len(response.content))

    print()
    print("RESPONSE HEADERS:")
    for key, value in response.headers.items():
        print(f"{key}: {value}")

    print()
    print("RAW RESPONSE:")
    print(response.text)

    # Save exact raw response
    with open("goldr_live24k_response.json", "w", encoding="utf-8") as f:
        f.write(response.text)

    if response.status_code != 200:
        print()
        print("Request was not successful.")
        sys.exit(1)

    try:
        data = response.json()
    except Exception as e:
        print("JSON ERROR:", repr(e))
        sys.exit(1)

    print()
    print("TOP LEVEL KEYS:", list(data.keys()))

    if not data.get("success"):
        print("success is not true")
        sys.exit(1)

    encrypted_data = data.get("d")
    iv_string = data.get("i")

    if not encrypted_data or not iv_string:
        print("Missing encrypted data or IV.")
        sys.exit(1)

    print()
    print("IV STRING:", iv_string)
    print("ENCRYPTED DATA LENGTH:", len(encrypted_data))

    try:
        iv = base64.b64decode(iv_string)
    except Exception as e:
        print("IV BASE64 ERROR:", repr(e))
        sys.exit(1)

    try:
        ciphertext = base64.b64decode(encrypted_data)
    except Exception as e:
        print("DATA BASE64 ERROR:", repr(e))
        sys.exit(1)

    print("IV BYTES:", len(iv))
    print("CIPHERTEXT BYTES:", len(ciphertext))

    print()
    print("=" * 80)
    print("TRYING CANDIDATE AES KEYS")
    print("=" * 80)

    found = 0

    candidates = make_candidates()

    # Also try the IV itself as a key
    candidates.append(("raw_iv", iv))

    for name, key in candidates:
        plaintext = decrypt_aes(ciphertext, key, iv)

        if not plaintext:
            continue

        try:
            decoded = plaintext.decode("utf-8", errors="replace").strip()
        except Exception:
            continue

        # Only show candidates that look meaningful.
        meaningful = False

        if decoded.startswith("{") or decoded.startswith("["):
            meaningful = True

        if "price" in decoded.lower():
            meaningful = True

        if "vori" in decoded.lower():
            meaningful = True

        if "24" in decoded:
            meaningful = True

        if meaningful:
            found += 1
            print_candidate(name, plaintext)

    print()
    print("=" * 80)

    if found == 0:
        print("NO DIRECT CANDIDATE KEY WORKED.")
        print("The raw encrypted response has been saved.")
    else:
        print("FOUND", found, "POSSIBLE DECRYPTION(S).")

    print("=" * 80)


if __name__ == "__main__":
    main()
