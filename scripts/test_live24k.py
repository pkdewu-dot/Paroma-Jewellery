import requests

URL = "https://www.goldr.org/live24k.json"

headers = {
    "User-Agent": "Mozilla/5.0",
    "Accept": "application/json,text/plain,*/*",
    "Referer": "https://www.goldr.org/",
}

print("=" * 70)
print("GOLDR LIVE24K ENDPOINT TEST")
print("=" * 70)
print()

try:
    response = requests.get(
        URL,
        headers=headers,
        timeout=60,
    )

    print("STATUS:", response.status_code)
    print("CONTENT TYPE:", response.headers.get("content-type"))
    print("CONTENT LENGTH:", len(response.content))
    print()

    print("RESPONSE:")
    print("-" * 70)
    print(response.text[:20000])
    print("-" * 70)

except Exception as e:
    print("ERROR:", repr(e))

print()
print("=" * 70)
print("TEST COMPLETE")
print("=" * 70)
