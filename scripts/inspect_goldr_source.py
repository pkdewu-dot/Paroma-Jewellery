import re
import sys
import requests
from urllib.parse import urljoin


PAGE_URL = "https://www.goldr.org/24-karat-gold-price-bangladesh/"
SCRIPT_URL = "https://www.goldr.org/price.ultra.js"


HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/131.0.0.0 Safari/537.36"
    ),
    "Accept": (
        "text/html,application/xhtml+xml,"
        "application/xml;q=0.9,*/*;q=0.8"
    ),
    "Accept-Language": "en-US,en;q=0.9",
}


def save_file(filename, content):
    with open(filename, "w", encoding="utf-8") as f:
        f.write(content)


def main():
    print("=" * 80)
    print("GOLDR 24K SOURCE INSPECTION")
    print("=" * 80)
    print()

    session = requests.Session()
    session.headers.update(HEADERS)

    # ---------------------------------------------------------
    # 1. Download 24K page HTML
    # ---------------------------------------------------------

    print("1. Downloading GoldR 24K page...")
    print(PAGE_URL)
    print()

    try:
        response = session.get(
            PAGE_URL,
            timeout=60,
            allow_redirects=True,
        )

        print("HTTP STATUS:", response.status_code)
        print("FINAL URL:", response.url)
        print("CONTENT TYPE:", response.headers.get("content-type"))
        print("CONTENT LENGTH:", len(response.text))
        print()

        page_html = response.text

        save_file(
            "goldr_page_source.html",
            page_html,
        )

    except Exception as e:
        print("PAGE REQUEST ERROR:", repr(e))
        page_html = ""

    # ---------------------------------------------------------
    # 2. Check if verification/challenge is present
    # ---------------------------------------------------------

    print("-" * 80)
    print("2. Checking page response...")
    print("-" * 80)

    lower_html = page_html.lower()

    challenge_words = [
        "verification could not be completed",
        "verify you are human",
        "captcha",
        "challenge",
        "cloudflare",
        "just a moment",
    ]

    for word in challenge_words:
        if word in lower_html:
            print("FOUND POSSIBLE CHALLENGE:", word)

    print()

    # ---------------------------------------------------------
    # 3. Find every JavaScript file used by page
    # ---------------------------------------------------------

    print("-" * 80)
    print("3. JAVASCRIPT FILES FOUND ON PAGE")
    print("-" * 80)

    script_urls = []

    script_pattern = re.compile(
        r'<script[^>]+src=["\']([^"\']+)["\']',
        re.IGNORECASE,
    )

    for match in script_pattern.findall(page_html):
        absolute_url = urljoin(
            PAGE_URL,
            match,
        )

        if absolute_url not in script_urls:
            script_urls.append(absolute_url)

    if script_urls:
        for index, url in enumerate(script_urls, start=1):
            print(f"{index}. {url}")
    else:
        print("NO EXTERNAL JAVASCRIPT FILES FOUND")

    print()

    # ---------------------------------------------------------
    # 4. Download GoldR price.ultra.js directly
    # ---------------------------------------------------------

    print("-" * 80)
    print("4. DOWNLOADING GoldR price.ultra.js")
    print("-" * 80)

    try:
        js_response = session.get(
            SCRIPT_URL,
            timeout=60,
        )

        print("HTTP STATUS:", js_response.status_code)
        print("CONTENT TYPE:", js_response.headers.get("content-type"))
        print("CONTENT LENGTH:", len(js_response.text))
        print()

        price_js = js_response.text

        save_file(
            "goldr_price_ultra.js",
            price_js,
        )

        print("price.ultra.js saved successfully.")

    except Exception as e:
        print("JAVASCRIPT REQUEST ERROR:", repr(e))
        price_js = ""

    print()

    # ---------------------------------------------------------
    # 5. Search JavaScript for API/endpoint URLs
    # ---------------------------------------------------------

    print("-" * 80)
    print("5. POSSIBLE API / ENDPOINT URLs")
    print("-" * 80)

    combined_text = page_html + "\n" + price_js

    url_pattern = re.compile(
        r'https?://[^\s"\'<>]+',
        re.IGNORECASE,
    )

    found_urls = []

    for url in url_pattern.findall(combined_text):
        url = url.rstrip(");,]}")

        if url not in found_urls:
            found_urls.append(url)

    if found_urls:
        for url in found_urls:
            print(url)
    else:
        print("NO FULL URL FOUND")

    print()

    # ---------------------------------------------------------
    # 6. Search for endpoint-looking strings
    # ---------------------------------------------------------

    print("-" * 80)
    print("6. POSSIBLE ENDPOINT / API STRINGS")
    print("-" * 80)

    endpoint_pattern = re.compile(
        r"""
        (?:
            fetch\s*\(\s*["']([^"']+)["']
        )
        |
        (?:
            axios\.(?:get|post)\s*\(\s*["']([^"']+)["']
        )
        |
        (?:
            url\s*[:=]\s*["']([^"']+)["']
        )
        |
        (?:
            endpoint\s*[:=]\s*["']([^"']+)["']
        )
        |
        (?:
            api(?:Url|URL)?\s*[:=]\s*["']([^"']+)["']
        )
        |
        (?:
            ["']([^"']*(?:api|json|price|rate|gold)[^"']*)["']
        )
        """,
        re.IGNORECASE | re.VERBOSE,
    )

    endpoint_matches = []

    for match in endpoint_pattern.findall(combined_text):
        for item in match:
            item = item.strip()

            if not item:
                continue

            if item not in endpoint_matches:
                endpoint_matches.append(item)

    if endpoint_matches:
        for item in endpoint_matches:
            print(item)
    else:
        print("NO OBVIOUS ENDPOINT STRING FOUND")

    print()

    # ---------------------------------------------------------
    # 7. Search for 24K-related code
    # ---------------------------------------------------------

    print("-" * 80)
    print("7. 24K / GOLD RELATED SOURCE LINES")
    print("-" * 80)

    keywords = [
        "24k",
        "24K",
        "24 karat",
        "xau",
        "usd/bdt",
        "usdbdt",
        "price",
        "gold",
        "vat",
        "duty",
        "live24",
        "paka",
        "bhori",
    ]

    lines = combined_text.splitlines()

    printed = 0

    for line_number, line in enumerate(lines, start=1):
        lower_line = line.lower()

        matched = False

        for keyword in keywords:
            if keyword.lower() in lower_line:
                matched = True
                break

        if matched:
            clean = line.strip()

            if clean:
                print(
                    f"{line_number}: "
                    f"{clean[:1200]}"
                )

                printed += 1

        if printed >= 300:
            print()
            print("Output limited to first 300 matching lines.")
            break

    if printed == 0:
        print("NO RELEVANT SOURCE LINE FOUND")

    print()

    # ---------------------------------------------------------
    # 8. Search HTML for special data attributes
    # ---------------------------------------------------------

    print("-" * 80)
    print("8. DATA ATTRIBUTES / 24K MARKERS")
    print("-" * 80)

    data_patterns = [
        r'data-[a-zA-Z0-9_-]+\s*=\s*["\'][^"\']+["\']',
        r'id\s*=\s*["\'][^"\']*(?:24|gold|price)[^"\']*["\']',
        r'class\s*=\s*["\'][^"\']*(?:24|gold|price)[^"\']*["\']',
    ]

    found_markers = []

    for pattern in data_patterns:
        for match in re.findall(
            pattern,
            page_html,
            flags=re.IGNORECASE,
        ):
            if match not in found_markers:
                found_markers.append(match)

    if found_markers:
        for marker in found_markers[:300]:
            print(marker)
    else:
        print("NO SPECIAL MARKERS FOUND")

    print()

    # ---------------------------------------------------------
    # 9. Final result
    # ---------------------------------------------------------

    print("=" * 80)
    print("SOURCE INSPECTION COMPLETE")
    print("=" * 80)
    print()
    print("Generated files:")
    print("1. goldr_page_source.html")
    print("2. goldr_price_ultra.js")
    print()

    print(
        "These files are diagnostic only. "
        "Nothing in market.json or the Flutter app was changed."
    )

    print("=" * 80)

    sys.exit(0)


if __name__ == "__main__":
    main()
