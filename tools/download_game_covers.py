#!/usr/bin/env python3
"""Download local offline game cover images for the GameVault catalog.

- Uses Steam's public Store search endpoint (no API key).
- Verifies the returned Steam title matches the catalog entry before downloading.
- Downloads portrait library artwork (library_600x900.jpg) when available.
- Saves covers as <game-id>.jpg in assets/game_covers/.
- Validates files are real images (not HTML/error pages).
- Skips existing valid files.
- Never substitutes a different game's cover.
- Reports successful downloads, skipped files, and games not found/unavailable on Steam.

This script does not modify the Flutter app/catalog/UI.
"""

from __future__ import annotations

import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Optional


@dataclass(frozen=True)
class GameEntry:
    id: str
    title: str


# Catalog entries (id, title) inspected from:
# lib/features/browse_games/data/datasources/games_local_data_source.dart
CATALOG: list[GameEntry] = [
    GameEntry("zelda-botw", "The Legend of Zelda: Breath of the Wild"),
    GameEntry("elden-ring", "Elden Ring"),
    GameEntry("minecraft", "Minecraft"),
    GameEntry("stardew-valley", "Stardew Valley"),
    GameEntry("hades", "Hades"),
    GameEntry("god-of-war-2018", "God of War"),
    GameEntry("witcher-3", "The Witcher 3: Wild Hunt"),
    GameEntry("hollow-knight", "Hollow Knight"),
    GameEntry("gta-v", "Grand Theft Auto V"),
    GameEntry("fortnite", "Fortnite"),
    GameEntry("celeste", "Celeste"),
    GameEntry("red-dead-redemption-2", "Red Dead Redemption 2"),
    GameEntry("half-life-2", "Half-Life 2"),
    GameEntry("doom-2016", "DOOM"),
    GameEntry("doom-eternal", "DOOM Eternal"),
    GameEntry("dark-souls", "Dark Souls"),
    GameEntry("dark-souls-iii", "Dark Souls III"),
    GameEntry("sekiro", "Sekiro: Shadows Die Twice"),
    GameEntry("bloodborne", "Bloodborne"),
    GameEntry("skyrim", "The Elder Scrolls V: Skyrim"),
    GameEntry("oblivion", "The Elder Scrolls IV: Oblivion"),
    GameEntry("baldurs-gate-3", "Baldur's Gate 3"),
    GameEntry("persona-5-royal", "Persona 5 Royal"),
    GameEntry("final-fantasy-vii-remake", "Final Fantasy VII Remake"),
    GameEntry("final-fantasy-x", "Final Fantasy X"),
    GameEntry("chrono-trigger", "Chrono Trigger"),
    GameEntry("resident-evil-2-remake", "Resident Evil 2"),
    GameEntry("resident-evil-4-remake", "Resident Evil 4"),
    GameEntry("resident-evil-7", "Resident Evil 7: Biohazard"),
    GameEntry("silent-hill-2", "Silent Hill 2"),
    GameEntry("alan-wake-2", "Alan Wake 2"),
    GameEntry("horizon-zero-dawn", "Horizon Zero Dawn"),
    GameEntry("ghost-of-tsushima", "Ghost of Tsushima"),
    GameEntry("assassins-creed-valhalla", "Assassin's Creed Valhalla"),
    GameEntry("cyberpunk-2077", "Cyberpunk 2077"),
    GameEntry("super-mario-odyssey", "Super Mario Odyssey"),
    GameEntry("super-mario-world", "Super Mario World"),
    GameEntry("ori-and-the-will-of-the-wisps", "Ori and the Will of the Wisps"),
    GameEntry("cuphead", "Cuphead"),
    GameEntry("dead-cells", "Dead Cells"),
    GameEntry("undertale", "Undertale"),
    GameEntry("terraria", "Terraria"),
    GameEntry("subnautica", "Subnautica"),
    GameEntry("slay-the-spire", "Slay the Spire"),
    GameEntry("disco-elysium", "Disco Elysium"),
    GameEntry("outer-wilds", "Outer Wilds"),
    GameEntry("vampire-survivors", "Vampire Survivors"),
    GameEntry("limbo", "Limbo"),
    GameEntry("inside", "Inside"),
    GameEntry("shovel-knight", "Shovel Knight"),
    GameEntry("factorio", "Factorio"),
    GameEntry("cities-skylines", "Cities: Skylines"),
    GameEntry("civilization-vi", "Sid Meier's Civilization VI"),
    GameEntry("age-of-empires-ii-de", "Age of Empires II: Definitive Edition"),
    GameEntry("starcraft", "StarCraft"),
    GameEntry("forza-horizon-5", "Forza Horizon 5"),
    GameEntry("mario-kart-8-deluxe", "Mario Kart 8 Deluxe"),
    GameEntry("need-for-speed-underground-2", "Need for Speed: Underground 2"),
    GameEntry("a-plague-tale-innocence", "A Plague Tale: Innocence"),
    GameEntry("hellblade-senuas-sacrifice", "Hellblade: Senua's Sacrifice"),
    GameEntry("control", "Control"),
    GameEntry("lies-of-p", "Lies of P"),
    GameEntry("nier-automata", "NieR:Automata"),
    GameEntry("monster-hunter-world", "Monster Hunter: World"),
    GameEntry("monster-hunter-rise", "Monster Hunter Rise"),
]

# Extra search terms to improve chances of a correct, verifiable match.
# (We still verify the returned title before downloading.)
SEARCH_TERMS_OVERRIDES: dict[str, list[str]] = {
    "doom-2016": ["DOOM 2016", "DOOM"],
    "dark-souls-iii": ["DARK SOULS III", "Dark Souls 3"],
    "gta-v": ["Grand Theft Auto V", "GTA V"],
    "witcher-3": ["The Witcher 3: Wild Hunt"],
    "skyrim": ["The Elder Scrolls V: Skyrim Special Edition", "The Elder Scrolls V: Skyrim"],
    "oblivion": ["The Elder Scrolls IV: Oblivion Game of the Year Edition", "The Elder Scrolls IV: Oblivion"],
    "resident-evil-2-remake": ["Resident Evil 2 2019", "RESIDENT EVIL 2 / BIOHAZARD RE:2", "Resident Evil 2"],
    "resident-evil-4-remake": ["Resident Evil 4 2023", "Resident Evil 4"],
    "resident-evil-7": ["Resident Evil 7 Biohazard", "RESIDENT EVIL 7 biohazard"],
    "nier-automata": ["NieR:Automata", "NieR Automata"],
    "age-of-empires-ii-de": ["Age of Empires II: Definitive Edition"],
    "cities-skylines": ["Cities: Skylines"],
    "civilization-vi": ["Sid Meier's Civilization VI", "Civilization VI"],
    "hellblade-senuas-sacrifice": ["Hellblade: Senua's Sacrifice"],
    "assassins-creed-valhalla": ["Assassin's Creed Valhalla"],
    "monster-hunter-world": ["Monster Hunter: World"],
    "monster-hunter-rise": ["MONSTER HUNTER RISE", "Monster Hunter Rise"],
    "final-fantasy-vii-remake": ["FINAL FANTASY VII REMAKE INTERGRADE", "FINAL FANTASY VII REMAKE"],
    "god-of-war-2018": ["God of War"],  # may not be on Steam; matching must be verified
}

# For some catalog entries, accept specific normalized Steam names as correct matches.
# Keys are catalog game IDs; values are normalized title strings considered acceptable.
ACCEPTABLE_NORMALIZED_TITLES: dict[str, set[str]] = {
    "doom-2016": {"doom"},
    "resident-evil-2-remake": {
        "resident evil 2",
        "resident evil 2 biohazard re 2",
        "resident evil 2 biohazard re2",
        "biohazard re 2",
    },
    "resident-evil-4-remake": {"resident evil 4"},
    "resident-evil-7": {
        "resident evil 7 biohazard",
        "resident evil 7 biohazard biohazard 7 resident evil",
        "biohazard 7 resident evil",
    },
    "skyrim": {
        "the elder scrolls v skyrim",
        "the elder scrolls v skyrim special edition",
    },
    "oblivion": {
        "the elder scrolls iv oblivion",
        "the elder scrolls iv oblivion game of the year edition",
        "the elder scrolls iv oblivion game of the year edition deluxe",
    },
    "nier-automata": {"nier automata"},
    "civilization-vi": {"sid meiers civilization vi", "civilization vi"},
    "final-fantasy-vii-remake": {
        "final fantasy vii remake intergrade",
        "final fantasy vii remake",
    },
    "monster-hunter-rise": {"monster hunter rise"},
    "dark-souls": {"dark souls prepare to die edition", "dark souls remastered", "dark souls"},
}

USER_AGENT = "GameVaultCoverDownloader/1.0 (local offline asset preparation; no API key)"
STEAM_SEARCH_URL = "https://store.steampowered.com/api/storesearch/"
LIBRARY_IMAGE_URLS = [
    "https://steamcdn-a.akamaihd.net/steam/apps/{appid}/library_600x900.jpg",
    "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/{appid}/library_600x900.jpg",
]


def normalize_title(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("\u2019", "'").replace("\u2018", "'")
    text = text.replace("\u2122", "").replace("\u00ae", "").replace("\u00a9", "")
    # Normalize accented chars lightly for matching (NieR/Automata variants etc.)
    replacements = {
        "\u00e4": "a", "\u00e0": "a", "\u00e1": "a", "\u00e2": "a",
        "\u00eb": "e", "\u00e8": "e", "\u00e9": "e", "\u00ea": "e",
        "\u00ef": "i", "\u00ec": "i", "\u00ed": "i", "\u00ee": "i",
        "\u00f6": "o", "\u00f2": "o", "\u00f3": "o", "\u00f4": "o",
        "\u00fc": "u", "\u00f9": "u", "\u00fa": "u", "\u00fb": "u",
    }
    for src, dst in replacements.items():
        text = text.replace(src, dst)
    text = re.sub(r"[^a-z0-9]+", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def titles_match(game: GameEntry, steam_name: str) -> bool:
    catalog_norm = normalize_title(game.title)
    steam_norm = normalize_title(steam_name)
    if not catalog_norm or not steam_norm:
        return False
    if catalog_norm == steam_norm:
        return True
    allowed = ACCEPTABLE_NORMALIZED_TITLES.get(game.id, set())
    if steam_norm in allowed:
        return True
    # Conservative containment checks for cases like subtitles/editions where the
    # core catalog title is fully present and specific enough.
    if game.id in {"doom-2016"} and catalog_norm == "doom" and steam_norm == "doom":
        return True
    if catalog_norm == steam_norm.replace(" edition", "").replace(" definitive edition", "").strip():
        # only if the full base remains equal (safe)
        return True
    return False


def http_get_bytes(url: str, timeout: int = 20) -> tuple[Optional[bytes], Optional[str], Optional[str]]:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            content_type = resp.headers.get("Content-Type", "")
            final_url = resp.geturl()
            data = resp.read()
            return data, content_type, final_url
    except Exception as e:
        return None, None, str(e)


def http_get_json(url: str, timeout: int = 20) -> tuple[Optional[dict], Optional[str]]:
    data, content_type, err_or_url = http_get_bytes(url, timeout=timeout)
    if data is None:
        return None, err_or_url or "request failed"
    # Guard against HTML error pages returned as 200 OK
    if is_html_bytes(data):
        return None, f"received HTML instead of JSON (content-type={content_type})"
    try:
        return json.loads(data.decode("utf-8", errors="replace")), None
    except Exception as e:
        return None, f"json decode error: {e}"


def is_html_bytes(data: bytes) -> bool:
    head = data[:512].lstrip().lower()
    return (
        head.startswith(b"<!doctype html")
        or head.startswith(b"<html")
        or head.startswith(b"<head")
        or head.startswith(b"<body")
        or b"<html" in head
    )


def is_valid_image_bytes(data: bytes) -> bool:
    if not data or len(data) < 64:
        return False
    if is_html_bytes(data):
        return False
    # JPEG
    if data.startswith(b"\xff\xd8\xff"):
        return True
    # PNG
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return True
    # WebP (RIFF....WEBP)
    if len(data) >= 12 and data[0:4] == b"RIFF" and data[8:12] == b"WEBP":
        return True
    # GIF
    if data.startswith(b"GIF87a") or data.startswith(b"GIF89a"):
        return True
    return False


def existing_valid_image(path: Path) -> bool:
    if not path.exists() or not path.is_file():
        return False
    try:
        data = path.read_bytes()
    except Exception:
        return False
    return is_valid_image_bytes(data)


def search_steam(game: GameEntry) -> tuple[Optional[dict], str]:
    terms = SEARCH_TERMS_OVERRIDES.get(game.id, [game.title])
    last_reason = "no results"
    for term in terms:
        query = urllib.parse.urlencode({"term": term, "l": "english", "cc": "US"})
        url = f"{STEAM_SEARCH_URL}?{query}"
        payload, err = http_get_json(url)
        if err:
            last_reason = f"search error for '{term}': {err}"
            continue
        items = payload.get("items") if isinstance(payload, dict) else None
        if not items:
            last_reason = f"no search results for '{term}'"
            continue
        # Find a verified match; never pick a different game.
        for item in items:
            if not isinstance(item, dict):
                continue
            name = str(item.get("name", ""))
            appid = item.get("id")
            if not name or not appid:
                continue
            if titles_match(game, name):
                return {"id": appid, "name": name, "query": term}, "matched"
        last_reason = f"no verified title match in results for '{term}'"
        time.sleep(0.2)
    return None, last_reason


def download_library_image(appid: int | str) -> tuple[Optional[bytes], str]:
    last_reason = "no image url succeeded"
    for tmpl in LIBRARY_IMAGE_URLS:
        url = tmpl.format(appid=appid)
        data, content_type, err_or_url = http_get_bytes(url)
        if data is None:
            last_reason = f"download failed: {err_or_url}"
            continue
        if is_html_bytes(data):
            last_reason = f"received HTML/error page instead of image from {url}"
            continue
        if not is_valid_image_bytes(data):
            last_reason = f"downloaded data is not a valid image from {url} (content-type={content_type})"
            continue
        # Ensure it looks like the portrait library art request succeeded with real bytes.
        return data, f"ok ({url})"
    return None, last_reason


def ensure_output_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def write_report(
    report_path: Path,
    successes: list[str],
    skipped: list[str],
    not_found: list[tuple[str, str]],
    unavailable_on_steam: list[str],
) -> None:
    lines: list[str] = []
    lines.append("GameVault cover download report")
    lines.append("==============================")
    lines.append("")
    lines.append(f"Successful downloads ({len(successes)}):")
    lines.extend([f"  - {s}" for s in successes] or ["  - (none)"])
    lines.append("")
    lines.append(f"Skipped (already existed and valid) ({len(skipped)}):")
    lines.extend([f"  - {s}" for s in skipped] or ["  - (none)"])
    lines.append("")
    lines.append(f"Not found / could not verify match / download unavailable ({len(not_found)}):")
    lines.extend([f"  - {gid}: {reason}" for gid, reason in not_found] or ["  - (none)"])
    lines.append("")
    lines.append("Games unavailable on Steam or requiring manual images (IDs):")
    # Per requirement: report IDs for games unavailable on Steam so user can provide separately.
    # We include all not-found/unavailable cases as IDs needing manual provision (no wrong covers).
    manual_ids = sorted(set(unavailable_on_steam))
    lines.extend([f"  - {gid}" for gid in manual_ids] or ["  - (none)"])
    lines.append("")
    lines.append("Note: No cover was substituted for a different game.")
    report_path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    script_path = Path(__file__).resolve()
    project_root = script_path.parents[1]  # tools/ -> game_list/
    covers_dir = project_root / "assets" / "game_covers"
    ensure_output_dir(covers_dir)

    successes: list[str] = []
    skipped: list[str] = []
    not_found: list[tuple[str, str]] = []
    unavailable_ids: list[str] = []

    print(f"Project root: {project_root}")
    print(f"Output directory: {covers_dir}")
    print(f"Catalog entries: {len(CATALOG)}")
    print("")

    for idx, game in enumerate(CATALOG, start=1):
        out_path = covers_dir / f"{game.id}.jpg"
        prefix = f"[{idx}/{len(CATALOG)}] {game.id}"

        # 9. Skip files that already exist and are valid.
        if existing_valid_image(out_path):
            print(f"{prefix}: SKIP (valid image already exists)")
            skipped.append(f"{game.id} ({game.title}) -> {out_path.name}")
            continue
        elif out_path.exists():
            print(f"{prefix}: existing file is invalid/not an image, will try to replace with a verified download")
            try:
                out_path.unlink()
            except Exception:
                pass

        # 3/4. Search Steam and verify title match.
        match, reason = search_steam(game)
        if not match:
            print(f"{prefix}: NOT FOUND ({reason})")
            not_found.append((game.id, reason))
            unavailable_ids.append(game.id)
            time.sleep(0.25)
            continue

        appid = match["id"]
        steam_name = match["name"]
        print(f"{prefix}: matched Steam app {appid} '{steam_name}' (query='{match['query']}')")

        # 5. Download portrait library_600x900.jpg when available.
        image_data, dl_reason = download_library_image(appid)
        if not image_data:
            msg = f"matched '{steam_name}' (appid {appid}) but portrait cover unavailable: {dl_reason}"
            print(f"{prefix}: UNAVAILABLE ({msg})")
            not_found.append((game.id, msg))
            unavailable_ids.append(game.id)
            time.sleep(0.25)
            continue

        # 8. Validate image bytes (not HTML/error) before saving.
        if not is_valid_image_bytes(image_data):
            msg = f"matched '{steam_name}' (appid {appid}) but downloaded file failed image validation"
            print(f"{prefix}: UNAVAILABLE ({msg})")
            not_found.append((game.id, msg))
            unavailable_ids.append(game.id)
            time.sleep(0.25)
            continue

        try:
            out_path.write_bytes(image_data)
        except Exception as e:
            msg = f"failed to save image: {e}"
            print(f"{prefix}: ERROR ({msg})")
            not_found.append((game.id, msg))
            unavailable_ids.append(game.id)
            continue

        # Post-save validation.
        if not existing_valid_image(out_path):
            msg = "saved file is not a valid image (post-save validation failed)"
            print(f"{prefix}: ERROR ({msg})")
            try:
                out_path.unlink()
            except Exception:
                pass
            not_found.append((game.id, msg))
            unavailable_ids.append(game.id)
            continue

        print(f"{prefix}: DOWNLOADED -> {out_path.name}")
        successes.append(f"{game.id} ({game.title}) <= Steam '{steam_name}' appid {appid}")
        time.sleep(0.3)

    report_path = project_root / "tools" / "game_cover_download_report.txt"
    write_report(report_path, successes, skipped, not_found, unavailable_ids)

    print("")
    print("Summary")
    print("-------")
    print(f"Successful downloads: {len(successes)}")
    print(f"Skipped (valid existing): {len(skipped)}")
    print(f"Not found/unavailable (manual images needed): {len(not_found)}")
    print(f"Report written to: {report_path}")
    if unavailable_ids:
        unique_ids = sorted(set(unavailable_ids))
        print(f"IDs needing manual images ({len(unique_ids)}): {', '.join(unique_ids)}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
