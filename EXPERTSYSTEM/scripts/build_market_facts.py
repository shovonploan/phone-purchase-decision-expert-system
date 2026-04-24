#!/usr/bin/env python3
"""Build CLIPS market-facts.clp from CSV datasets."""

from __future__ import annotations

import csv
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SMARTPRIX_CSV = ROOT / "smartprix_smartphones_april_2026.csv"
MOBILE_CSV = ROOT / "mobile_phone_price_dataset.csv"
OUTPUT = ROOT / "EXPERTSYSTEM" / "clips" / "market-facts.clp"
BDT_PER_CAD = 90.0


def load_smartprix() -> list[dict]:
    rows = []
    with SMARTPRIX_CSV.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            try:
                rows.append(
                    {
                        "source": "smartprix",
                        "brand": r["brand_name"].strip().lower(),
                        "model": r["model"].strip(),
                        "category": r["price_category"].strip(),
                        "price": int(float(r["price"] or 0)),
                        "spec": float(r["spec_score"] or 0),
                        "vfm": float(r["vfm_score"] or 0),
                        "camera": float(r["rear_camera"] or 0),
                        "refresh": float(r["refresh_rate"] or 0),
                        "ram": float(r["ram"] or 0),
                        "memory": float(r["memory"] or 0),
                        "os": r["os"].strip(),
                    }
                )
            except Exception:
                continue
    return rows


def load_mobile_dataset() -> list[dict]:
    rows = []
    with MOBILE_CSV.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            try:
                rows.append(
                    {
                        "source": "mobile_dataset",
                        "brand": r["Brand"].strip().lower(),
                        "model": r["Model"].strip(),
                        "category": "Synthetic",
                        "price": int(float(r["Price"] or 0)),
                        "spec": float(r["Rating"] or 0) * 20.0,
                        "vfm": float(r["Rating"] or 0),
                        "camera": float((r["Camera"] or "0").replace("MP", "")),
                        "refresh": 120.0,
                        "ram": float((r["RAM"] or "0").replace("GB", "")),
                        "memory": float((r["Storage"] or "0").replace("GB", "")),
                        "os": "Unknown",
                    }
                )
            except Exception:
                continue
    return rows


def select_rows(smart: list[dict], mobile: list[dict]) -> list[dict]:
    selected = []
    seen = set()

    wanted_names = [
        "Samsung Galaxy S25 Ultra",
        "Samsung Galaxy S25 FE",
        "Samsung Galaxy S25 5G",
        "Apple iPhone 17 Pro Max",
        "Apple iPhone 17 Pro",
        "Apple iPhone 17",
        "OnePlus Nord 6",
        "Motorola Edge 60 Pro",
        "Vivo T5 Pro",
        "Xiaomi Redmi Turbo 4 Pro",
        "Realme GT 7 Dream Edition",
        "Oppo K12s",
    ]

    for name in wanted_names:
        row = next((x for x in smart if x["model"] == name), None)
        if row and row["model"] not in seen:
            selected.append(row)
            seen.add(row["model"])

    for category, keep_count in [
        ("Flagship", 3),
        ("Premium", 3),
        ("Mid-Range", 4),
        ("Budget", 4),
    ]:
        rows = sorted(
            [x for x in smart if x["category"] == category],
            key=lambda x: (x["vfm"], x["spec"]),
            reverse=True,
        )
        kept = 0
        for row in rows:
            if row["model"] in seen:
                continue
            selected.append(row)
            seen.add(row["model"])
            kept += 1
            if kept >= keep_count:
                break

    selected.extend(
        sorted(mobile, key=lambda x: (x["vfm"], -x["price"]), reverse=True)[:5]
    )

    return selected


def write_clips(rows: list[dict]) -> None:
    category_map = {
        "Flagship": "flagship",
        "Premium": "premium",
        "Mid-Range": "mid-range",
        "Budget": "budget",
        "Synthetic": "synthetic",
    }

    def esc(text: str) -> str:
        return text.replace('"', "\\\"")

    with OUTPUT.open("w", encoding="utf-8") as f:
        f.write("(deffacts market-phone-dataset\n")
        for r in rows:
            segment = category_map.get(r["category"], "mid-range")
            price_cad = float(r["price"]) / BDT_PER_CAD
            f.write("   (market-phone\n")
            f.write(f"      (source {r['source']})\n")
            f.write(f"      (brand {r['brand']})\n")
            f.write(f"      (model \"{esc(r['model'])}\")\n")
            f.write(f"      (segment {segment})\n")
            f.write(f"      (price-cad {price_cad:.2f})\n")
            f.write(f"      (camera-mp {float(r['camera']):.1f})\n")
            f.write(f"      (refresh-rate {float(r['refresh']):.1f})\n")
            f.write(f"      (ram-gb {float(r['ram']):.1f})\n")
            f.write(f"      (storage-gb {float(r['memory']):.1f})\n")
            f.write(f"      (spec-score {float(r['spec']):.2f})\n")
            f.write(f"      (value-score {float(r['vfm']):.3f})\n")
            f.write(f"      (os \"{esc(r['os'])}\"))\n")
        f.write(")\n")


if __name__ == "__main__":
    smart_rows = load_smartprix()
    mobile_rows = load_mobile_dataset()
    chosen = select_rows(smart_rows, mobile_rows)
    write_clips(chosen)
    print(f"Wrote {OUTPUT} with {len(chosen)} market-phone facts.")
