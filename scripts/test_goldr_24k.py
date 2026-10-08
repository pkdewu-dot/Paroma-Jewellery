import re
import sys
from playwright.sync_api import sync_playwright


URL = "https://www.goldr.org/24-karat-gold-price-bangladesh/"


def clean_text(text):
    text = text.replace("\xa0", " ")
    text = re.sub(r"[ \t]+", " ", text)
    return text.strip()


def main():
    print("=" * 70)
    print("GOLDR 24K DIAGNOSTIC TEST")
    print("=" * 70)
    print(f"URL: {URL}")
    print()

    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            args=[
                "--no-sandbox",
                "--disable-setuid-sandbox",
                "--disable-dev-shm-usage",
            ],
        )

        page = browser.new_page(
            viewport={"width": 1440, "height": 2200},
            user_agent=(
                "Mozilla/5.0 (X11; Linux x86_64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/131.0.0.0 Safari/537.36"
            ),
        )

        print("1. Opening GoldR page...")
        page.goto(URL, wait_until="domcontentloaded", timeout=60000)

        print("2. Waiting for JavaScript...")
        page.wait_for_timeout(15000)

        print("3. Taking screenshot...")
        page.screenshot(
            path="goldr_24k_debug.png",
            full_page=True,
        )

        print("4. Reading rendered page text...")
        body_text = page.locator("body").inner_text(timeout=30000)
        body_text = clean_text(body_text)

        print()
        print("-" * 70)
        print("RENDERED PAGE TEXT")
        print("-" * 70)
        print(body_text[:20000])
        print("-" * 70)
        print()

        with open("goldr_24k_debug.txt", "w", encoding="utf-8") as f:
            f.write(body_text)

        print("5. Searching for BDT price values...")

        digit_map = str.maketrans(
            "০১২৩৪৫৬৭৮৯",
            "0123456789",
        )

        normalized = body_text.translate(digit_map)

        price_patterns = [
            r"৳\s*([0-9][0-9,]*(?:\.[0-9]+)?)",
            r"([0-9][0-9,]*(?:\.[0-9]+)?)\s*টাকা",
            r"BDT\s*([0-9][0-9,]*(?:\.[0-9]+)?)",
        ]

        found_prices = []

        for pattern in price_patterns:
            matches = re.findall(
                pattern,
                normalized,
                flags=re.IGNORECASE,
            )

            for match in matches:
                value = match.replace(",", "").strip()

                try:
                    number = float(value)

                    if number >= 100000:
                        if value not in found_prices:
                            found_prices.append(value)

                except ValueError:
                    pass

        print()
        print("-" * 70)
        print("POSSIBLE 24K PRICE VALUES")
        print("-" * 70)

        if found_prices:
            for price in found_prices:
                print(f"FOUND: {price}")
        else:
            print("NO PRICE FOUND")

        print("-" * 70)
        print()

        print("6. Inspecting elements containing 24K-related text...")

        keywords = [
            "২৪ ক্যারেট",
            "24 karat",
            "24K",
            "পাকা",
            "ভরি",
        ]

        for keyword in keywords:
            try:
                locator = page.get_by_text(
                    keyword,
                    exact=False,
                )

                count = locator.count()

                print(
                    f"Keyword '{keyword}': "
                    f"{count} element(s)"
                )

                for i in range(min(count, 10)):
                    try:
                        element = locator.nth(i)

                        text = clean_text(
                            element.inner_text()
                        )

                        if text:
                            print(
                                f"  [{i}] "
                                f"{text[:500]}"
                            )

                        html = element.evaluate(
                            "(el) => el.outerHTML"
                        )

                        print(
                            f"      HTML: "
                            f"{html[:1500]}"
                        )

                    except Exception as e:
                        print(
                            f"      Could not inspect "
                            f"element: {e}"
                        )

            except Exception as e:
                print(
                    f"Keyword '{keyword}' error: {e}"
                )

        print()
        print("7. Checking visible BDT elements...")

        try:
            elements = page.locator("body *")
            total = elements.count()
            printed = 0

            for i in range(total):
                if printed >= 100:
                    break

                try:
                    element = elements.nth(i)

                    if not element.is_visible():
                        continue

                    text = clean_text(
                        element.inner_text()
                    )

                    if not text:
                        continue

                    if (
                        "৳" in text
                        or "টাকা" in text
                        or "BDT" in text.upper()
                    ):
                        if len(text) <= 500:
                            print(f"TEXT: {text}")

                            html = element.evaluate(
                                "(el) => el.outerHTML"
                            )

                            print(
                                f"HTML: {html[:1000]}"
                            )

                            print("-" * 30)

                            printed += 1

                except Exception:
                    continue

        except Exception as e:
            print(
                f"DOM inspection failed: {e}"
            )

        print()
        print("=" * 70)

        if found_prices:
            print("RESULT: PRICE DATA WAS FOUND")
            print(
                "The next step can use "
                "the verified DOM/source."
            )
        else:
            print("RESULT: PRICE DATA WAS NOT FOUND")
            print(
                "We need to inspect the "
                "screenshot/log before changing the app."
            )

        print("=" * 70)

        browser.close()

        sys.exit(0)


if __name__ == "__main__":
    main()
