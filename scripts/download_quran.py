import json
import time
import requests

BASE = "https://api.quran.com/api/v4"
HEADERS = {"Accept": "application/json"}
OUT = "assets/data/quran.json"
SESSION = requests.Session()
SESSION.headers.update(HEADERS)

def get(url):
    r = SESSION.get(url, timeout=15)
    r.raise_for_status()
    return r.json()

def fetch_with_retry(url, retries=3, delay=2):
    for attempt in range(retries):
        try:
            return get(url)
        except Exception as e:
            if attempt < retries - 1:
                print(f"  retry {attempt+1} after error: {e}")
                time.sleep(delay)
            else:
                raise

print("Fetching surah names...")
data = fetch_with_retry(f"{BASE}/chapters?language=ar")
surah_names = {str(c["id"]): c["name_arabic"] for c in data["chapters"]}
print(f"  Got {len(surah_names)} surahs")

pages = {}
total = 604
for page_num in range(1, total + 1):
    url = f"{BASE}/verses/by_page/{page_num}?translations=&fields=text_uthmani,chapter_id,verse_number,page_number&per_page=50"
    data = fetch_with_retry(url)
    pages[str(page_num)] = data["verses"]
    if page_num % 50 == 0 or page_num == total:
        print(f"  {page_num}/{total} pages done")
    time.sleep(0.05)

result = {"surah_names": surah_names, "pages": pages}
with open(OUT, "w", encoding="utf-8") as f:
    json.dump(result, f, ensure_ascii=False, separators=(",", ":"))

size_mb = len(json.dumps(result, ensure_ascii=False).encode()) / 1024 / 1024
print(f"\nSaved to {OUT} ({size_mb:.1f} MB)")
