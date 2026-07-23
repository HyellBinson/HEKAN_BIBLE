import sqlite3
import xml.etree.ElementTree as ET
import os
import re

db_path = "../assets/bible.db"

bible_versions = {
    "KJV": "../assets/data/en_kjv.xml",
    "NIV": "../assets/data/en_niv.xml",
    "NLT": "../assets/data/en_nlt.xml",
    "ESV": "../assets/data/en_esv.xml",
    "PIDGIN": "../assets/data/en_pidgin.xml",
    "HAUSA": "../assets/data/en_hausa.xml"
}

BOOK_NAMES = {
    "1": "Genesis",
    "2": "Exodus",
    "3": "Leviticus",
    "4": "Numbers",
    "5": "Deuteronomy",
    "6": "Joshua",
    "7": "Judges",
    "8": "Ruth",
    "9": "1 Samuel",
    "10": "2 Samuel",
    "11": "1 Kings",
    "12": "2 Kings",
    "13": "1 Chronicles",
    "14": "2 Chronicles",
    "15": "Ezra",
    "16": "Nehemiah",
    "17": "Esther",
    "18": "Job",
    "19": "Psalms",
    "20": "Proverbs",
    "21": "Ecclesiastes",
    "22": "Song of Solomon",
    "23": "Isaiah",
    "24": "Jeremiah",
    "25": "Lamentations",
    "26": "Ezekiel",
    "27": "Daniel",
    "28": "Hosea",
    "29": "Joel",
    "30": "Amos",
    "31": "Obadiah",
    "32": "Jonah",
    "33": "Micah",
    "34": "Nahum",
    "35": "Habakkuk",
    "36": "Zephaniah",
    "37": "Haggai",
    "38": "Zechariah",
    "39": "Malachi",
    "40": "Matthew",
    "41": "Mark",
    "42": "Luke",
    "43": "John",
    "44": "Acts",
    "45": "Romans",
    "46": "1 Corinthians",
    "47": "2 Corinthians",
    "48": "Galatians",
    "49": "Ephesians",
    "50": "Philippians",
    "51": "Colossians",
    "52": "1 Thessalonians",
    "53": "2 Thessalonians",
    "54": "1 Timothy",
    "55": "2 Timothy",
    "56": "Titus",
    "57": "Philemon",
    "58": "Hebrews",
    "59": "James",
    "60": "1 Peter",
    "61": "2 Peter",
    "62": "1 John",
    "63": "2 John",
    "64": "3 John",
    "65": "Jude",
    "66": "Revelation",
}

os.makedirs(os.path.dirname(db_path), exist_ok=True)


def clean_text(text):
    if not text:
        return ""
    text = re.sub(r"\{.*?\}", "", text)
    text = re.sub(r"\s+", " ", text)
    text = text.replace(" ,", ",").replace(" .", ".").replace(" ;", ";").replace(" :", ":")
    return text.strip()


conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS verses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    version TEXT,
    book TEXT,
    chapter INTEGER,
    verse INTEGER,
    text TEXT
)
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS bookmarks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    version TEXT,
    book TEXT,
    chapter INTEGER,
    verse INTEGER,
    text TEXT
)
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    version TEXT,
    book TEXT,
    chapter INTEGER,
    verse INTEGER,
    note TEXT
)
""")

cursor.execute("DELETE FROM verses")

total = 0

print("Importing Bible versions...")


for version, xml_path in bible_versions.items():

    if not os.path.exists(xml_path):
        print(f"❌ Missing file: {xml_path}")
        continue

    print(f"✅ Importing {version}")

    tree = ET.parse(xml_path)
    root = tree.getroot()

    # =========================
    # PIDGIN FORMAT (UNCHANGED)
    # =========================
    if root.find(".//testament") is not None and version == "PIDGIN":

        for book in root.iter("book"):

            book_number = book.get("number", "")
            book_name = BOOK_NAMES.get(str(book_number), f"Book {book_number}")

            for chapter in book.iter("chapter"):

                chapter_number = int(chapter.get("number", "0"))

                for verse in chapter.iter("verse"):

                    verse_number = int(verse.get("number", "0"))
                    verse_text = clean_text(verse.text)

                    if verse_text:
                        cursor.execute("""
                        INSERT INTO verses (version, book, chapter, verse, text)
                        VALUES (?, ?, ?, ?, ?)
                        """, (
                            version,
                            book_name,
                            chapter_number,
                            verse_number,
                            verse_text
                        ))

                        total += 1

        continue

    # =========================
    # HAUSA FORMAT (FIXED ADDITION)
    # =========================
    if root.find(".//testament") is not None and version == "HAUSA":

        for book in root.iter("book"):

            book_number = book.get("number", "")
            book_name = BOOK_NAMES.get(str(book_number), f"Book {book_number}")

            for chapter in book.iter("chapter"):

                chapter_number = int(chapter.get("number", "0"))

                for verse in chapter.iter("verse"):

                    verse_number = int(verse.get("number", "0"))
                    verse_text = clean_text(verse.text)

                    if verse_text:
                        cursor.execute("""
                        INSERT INTO verses (version, book, chapter, verse, text)
                        VALUES (?, ?, ?, ?, ?)
                        """, (
                            version,
                            book_name,
                            chapter_number,
                            verse_number,
                            verse_text
                        ))

                        total += 1

        continue

    # =========================
    # NIV / ESV / NLT FORMAT
    # =========================
    if root.find(".//BIBLEBOOK") is not None:

        for book in root.findall(".//BIBLEBOOK"):

            book_name = book.get("bname") or book.get("bsname")

            for chapter in book.findall(".//CHAPTER"):

                chapter_number = int(chapter.get("cnumber", "0"))

                for verse in chapter.findall(".//VERS"):

                    verse_number = int(verse.get("vnumber", "0"))
                    verse_text = clean_text(verse.text)

                    if verse_text:
                        cursor.execute("""
                        INSERT INTO verses (version, book, chapter, verse, text)
                        VALUES (?, ?, ?, ?, ?)
                        """, (
                            version,
                            book_name,
                            chapter_number,
                            verse_number,
                            verse_text
                        ))

                        total += 1

        continue

    # =========================
    # KJV FORMAT
    # =========================
    for book in root.findall("b"):

        book_name = book.get("n")

        for chapter in book.findall("c"):

            chapter_number = int(chapter.get("n"))

            for verse in chapter.findall("v"):

                verse_number = int(verse.get("n"))
                verse_text = clean_text(verse.text)

                if verse_text:
                    cursor.execute("""
                    INSERT INTO verses (version, book, chapter, verse, text)
                    VALUES (?, ?, ?, ?, ?)
                    """, (
                        version,
                        book_name,
                        chapter_number,
                        verse_number,
                        verse_text
                    ))

                    total += 1


conn.commit()
conn.close()

print(f"🎉 IMPORT COMPLETE! TOTAL VERSES: {total}")