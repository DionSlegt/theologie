#!/usr/bin/env python3
"""Export OT/NT oefeninhoud uit Swift-bron naar Webapp/data/ot-nt.json."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SWIFT = ROOT / "APP" / "Studie" / "Studie"
OUT = Path(__file__).resolve().parents[1] / "data" / "ot-nt.json"

INIT_PREFIXES = (
    ".init(",
    "OTKadersVraag(",
    "Hs2JacobsonChanOefenVraag(",
    "NTStromingVraag(",
    "NTPersonenVraag(",
    "NTQuizVraag(",
    "NTBegripQuizItem(",
)


def balanced_paren_slice(text: str, open_idx: int) -> str:
    depth = 0
    i = open_idx
    while i < len(text):
        c = text[i]
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return text[open_idx : i + 1]
        elif c in ('"', "'"):
            quote = c
            i += 1
            while i < len(text):
                if text[i] == "\\":
                    i += 2
                    continue
                if text[i] == quote:
                    break
                i += 1
        i += 1
    return text[open_idx:]


def strip_swift_string(s: str) -> str:
    s = s.strip()
    if s.startswith('"""'):
        inner = s[3:]
        if inner.endswith('"""'):
            inner = inner[:-3]
        return inner.strip("\n")
    if len(s) >= 2 and s[0] == s[-1] and s[0] in '"\'':
        s = s[1:-1]
    return s.replace("\\n", "\n").replace('\\"', '"').replace("\\'", "'")


def antwoord_per_regel(block: str) -> str:
    lines = re.findall(r'"((?:[^"\\]|\\.)*)"', block, re.DOTALL)
    cleaned = [ln.replace("\\n", "\n").replace('\\"', '"') for ln in lines]
    return "\n\n".join(cleaned)


def resolve_static_var(content: str, name: str) -> str | None:
    m0 = re.search(
        rf"(?:private )?static let {re.escape(name)}\s*=\s*\"((?:[^\"\\]|\\.)*)\"",
        content,
        re.DOTALL,
    )
    if m0:
        return strip_swift_string('"' + m0.group(1) + '"')
    m = re.search(
        rf"private static let {re.escape(name)}\s*=\s*\[(.*?)\]\.joined\(separator:\s*\"\\n\"\)",
        content,
        re.DOTALL,
    )
    if m:
        return antwoord_per_regel(m.group(1)).replace("\n\n", "\n")
    m2 = re.search(
        rf"private static let {re.escape(name)}\s*=\s*\[(.*?)\]\.joined\(separator:\s*\"\\n\\n\"\)",
        content,
        re.DOTALL,
    )
    if m2:
        return antwoord_per_regel(m2.group(1))
    m3 = re.search(
        rf"static let {re.escape(name)}\s*=\s*Hs2JacobsonChanOpmaak\.antwoordPerRegel\(\[(.*?)\]\)",
        content,
        re.DOTALL,
    )
    if m3:
        return antwoord_per_regel(m3.group(1))
    return None


def field_value(body: str, field: str, full_content: str) -> str | None:
    m = re.search(
        rf"{field}:\s*(\"\"\"(.*?)\"\"\"|\"((?:[^\"\\]|\\.)*)\"|otMdBlok\(\[(.*?)\]\)|Hs2JacobsonChanOpmaak\.antwoordPerRegel\(\[(.*?)\]\)|Hs2CanonOTInhoud\.(\w+)|(\w+))",
        body,
        re.DOTALL,
    )
    if not m:
        return None
    if m.group(2) is not None:
        return strip_swift_string('"""' + m.group(2) + '"""')
    if m.group(3) is not None:
        return strip_swift_string('"' + m.group(3) + '"')
    if m.group(4) is not None:
        return antwoord_per_regel(m.group(4))
    if m.group(5) is not None:
        return antwoord_per_regel(m.group(5))
    if m.group(6):
        return resolve_static_var(full_content, m.group(6))
    if m.group(7):
        return resolve_static_var(full_content, m.group(7))
    return None


def clean_text(s: str) -> str:
    lines = [ln.strip() for ln in s.split("\n")]
    out: list[str] = []
    for ln in lines:
        if ln == "" and out and out[-1] == "":
            continue
        out.append(ln)
    return "\n".join(out).strip()


def parse_init_body(body: str, full_content: str) -> tuple[str | None, str | None]:
    id_m = re.search(r'id:\s*"([^"]+)"', body)
    if not id_m:
        return None, None

    prompt = None
    for key in ("promptMarkdown", "termMarkdown", "prompt"):
        prompt = field_value(body, key, full_content)
        if prompt:
            break

    builder = re.search(
        r"OTPersoonPromptBuilder\.drieVragen\(\s*nummer:\s*(\d+),\s*naam:\s*\"([^\"]+)\",\s*gebiedEnPeriodeVraag:\s*\"([^\"]+)\"\s*\)",
        body,
    )
    if builder:
        n, naam, gebied = builder.groups()
        prompt = (
            f"**{n}. {naam}**\n\n"
            f"- {gebied}\n"
            f"- Typeer deze periode.\n"
            f"- Typeer de politieke situatie in het Oude Nabije Oosten in deze periode."
        )

    answer = None
    for key in ("antwoordMarkdown", "antwoord"):
        answer = field_value(body, key, full_content)
        if answer:
            break

    if prompt:
        prompt = clean_text(prompt)
    if answer:
        answer = clean_text(answer)
    return prompt, answer


def extract_inits_from_text(text: str, full_content: str) -> list[dict]:
    items = []
    for prefix in INIT_PREFIXES:
        start = 0
        while True:
            idx = text.find(prefix, start)
            if idx == -1:
                break
            open_paren = idx + len(prefix) - 1
            chunk = balanced_paren_slice(text, open_paren)
            body = chunk[1:-1]
            id_m = re.search(r'id:\s*"([^"]+)"', body)
            if id_m:
                prompt, answer = parse_init_body(body, full_content)
                if prompt and answer:
                    items.append(
                        {"id": id_m.group(1), "prompt": prompt, "answer": answer}
                    )
            start = idx + len(chunk)
    return items


def enum_body(content: str, enum_name: str) -> str | None:
    m = re.search(rf"private enum {enum_name}\s*\{{", content)
    if not m:
        m = re.search(rf"fileprivate enum {enum_name}\s*\{{", content)
    if not m:
        return None
    start = m.end()
    depth = 1
    i = start
    while i < len(content) and depth:
        if content[i] == "{":
            depth += 1
        elif content[i] == "}":
            depth -= 1
        i += 1
    return content[start : i - 1]


def extract_from_enum(content: str, enum_name: str) -> list[dict]:
    body = enum_body(content, enum_name)
    if not body:
        return []
    return extract_inits_from_text(body, content)


def extract_rijen(content: str) -> list[dict]:
    items = []
    for m in re.finditer(
        r'Rij\(titel:\s*"((?:[^"\\]|\\.)*)",\s*uitleg:\s*"((?:[^"\\]|\\.)*)"\)',
        content,
    ):
        titel = strip_swift_string('"' + m.group(1) + '"')
        uitleg = strip_swift_string('"' + m.group(2) + '"')
        items.append(
            {"id": f"lex-{len(items)}", "prompt": f"**{titel}**", "answer": uitleg}
        )
    return items


def read_swift(name: str) -> str:
    return (SWIFT / name).read_text(encoding="utf-8")


def extract_kaders_ordered(content: str) -> list[dict]:
    body = enum_body(content, "OudeTestamentKadersData") or ""
    items = extract_inits_from_text(body, content)
    by_id = {i["id"]: i for i in items}
    order: list[str] = []
    for iid in re.findall(r'id:\s*"(ot-kaders-[^"]+)"', body):
        if iid not in order:
            order.append(iid)
    return [by_id[i] for i in order if i in by_id]


def extract_opbouw_nt(content: str) -> list[dict]:
    body = enum_body(content, "OpbouwNTContent") or ""
    intro_m = re.search(
        r"static let introEnVraag: String = \[(.*?)\]\.joined\(separator:",
        body,
        re.DOTALL,
    )
    intro_a = re.search(
        r"static let introAntwoordMarkdown: String = \[(.*?)\]\.joined\(separator:",
        body,
        re.DOTALL,
    )
    items = []
    if intro_m and intro_a:
        items.append(
            {
                "id": "nt-opbouw-intro",
                "prompt": clean_text(antwoord_per_regel(intro_m.group(1))),
                "answer": clean_text(antwoord_per_regel(intro_a.group(1))),
            }
        )
    for m in re.finditer(
        r"OpbouwNTCategorie\(\s*volgnummer:\s*(\d+),\s*titelMarkdown:\s*\"((?:[^\"\\]|\\.)*)\",\s*bodyMarkdown:\s*\[(.*?)\]\.joined",
        body,
        re.DOTALL,
    ):
        num, titel, body_lines = m.groups()
        titel = strip_swift_string('"' + titel + '"')
        items.append(
            {
                "id": f"nt-opbouw-cat-{num}",
                "prompt": titel,
                "answer": clean_text(antwoord_per_regel(body_lines)),
            }
        )
    return items


def extract_achtenmeier(content: str) -> list[dict]:
    body = enum_body(content, "AchtenmeierCanonInhoud") or ""
    items = []
    for m in re.finditer(
        r"\.informatief\(id:\s*\"([^\"]+)\",\s*markdown:\s*(\w+)\)",
        body,
    ):
        sid, ref = m.groups()
        md = resolve_static_var(content, ref) or resolve_static_var(body, ref)
        if md:
            items.append(
                {
                    "id": f"nt-am-{sid}",
                    "kind": "info",
                    "prompt": "Lees",
                    "answer": clean_text(md),
                }
            )
    for m in re.finditer(
        r"\.toets\(id:\s*\"([^\"]+)\",\s*vraagMarkdown:\s*(\w+),\s*antwoordMarkdown:\s*(\w+)\)",
        body,
    ):
        sid, vref, aref = m.groups()
        vraag = resolve_static_var(content, vref) or resolve_static_var(body, vref)
        antw = resolve_static_var(content, aref) or resolve_static_var(body, aref)
        if vraag and antw:
            items.append(
                {
                    "id": f"nt-am-toets-{sid}",
                    "kind": "quiz",
                    "prompt": clean_text(vraag),
                    "answer": clean_text(antw),
                }
            )
    return items


def main() -> None:
    packs: dict[str, dict] = {}

    beg = read_swift("OudeTestamentBegrippenView.swift")
    packs["ot-begrippen"] = {
        "title": "II. Begrippen",
        "shuffle": True,
        "items": extract_from_enum(beg, "OudeTestamentBegrippenData"),
    }

    hs2b = read_swift("OudeTestamentHs2BegrippenView.swift")
    packs["ot-hs2-begrippen"] = {
        "title": "Begrippen (Hs 2)",
        "shuffle": True,
        "items": extract_from_enum(hs2b, "OudeTestamentHs2BegrippenData"),
    }

    kaders = read_swift("OudeTestamentKadersInvullenView.swift")
    packs["ot-kaders"] = {
        "title": "I. Historische en Geografische Kaders",
        "shuffle": False,
        "items": extract_kaders_ordered(kaders),
    }

    personen = read_swift("OudeTestamentPersonenUitOTView.swift")
    packs["ot-personen"] = {
        "title": "III. Personen uit het Oude Testament",
        "shuffle": False,
        "items": extract_from_enum(personen, "OudeTestamentPersonenData"),
    }

    hs2 = read_swift("OudeTestamentHs2JacobsonChanViews.swift")
    packs["ot-hs2-opbouw"] = {
        "title": "Opbouw OT",
        "shuffle": True,
        "items": extract_from_enum(hs2, "Hs2OpbouwOTVragenData"),
    }
    packs["ot-hs2-ontwikkeling"] = {
        "title": "Ontwikkeling OT",
        "shuffle": False,
        "items": extract_from_enum(hs2, "Hs2OntwikkelingOTVragenData"),
    }
    packs["ot-hs2-canon"] = {
        "title": "Canon OT",
        "shuffle": True,
        "items": extract_from_enum(hs2, "Hs2CanonOTVragenData"),
    }
    packs["ot-hs2-verschil"] = {
        "title": "Verschil ‘achter’ en ‘in’ de tekst",
        "shuffle": True,
        "items": extract_from_enum(hs2, "Hs2VerschilAchterInTekstVragenData"),
    }

    nt_tijd = read_swift("NieuweTestamentTijdsperiodeQuizView.swift")
    packs["nt-tijdsperiode"] = {
        "title": "Tijdsperiode",
        "shuffle": False,
        "items": extract_from_enum(nt_tijd, "NieuweTestamentTijdsperiodeVragen"),
    }

    nt_beg = read_swift("NieuweTestamentBegrippenView.swift")
    body_beg = enum_body(nt_beg, "NieuweTestamentBegrippenData") or ""
    historisch = extract_inits_from_text(
        re.search(
            r"private static let historischeItems.*?=\s*\[(.*?)\]",
            body_beg,
            re.DOTALL,
        ).group(1)
        if re.search(r"private static let historischeItems", body_beg)
        else "",
        nt_beg,
    )
    hs3 = extract_inits_from_text(
        re.search(
            r"private static let powellHs3Items.*?=\s*\[(.*?)\]",
            body_beg,
            re.DOTALL,
        ).group(1)
        if re.search(r"private static let powellHs3Items", body_beg)
        else "",
        nt_beg,
    )
    packs["nt-begrippen-hs12"] = {
        "title": "Begrippen (hs 1–2)",
        "shuffle": True,
        "items": historisch + extract_rijen(nt_beg),
    }
    packs["nt-begrippen-hs3"] = {
        "title": "Begrippen (hs 3)",
        "shuffle": True,
        "items": hs3,
    }

    nt_pers = read_swift("NieuweTestamentBelangrijkePersonenQuizView.swift")
    packs["nt-personen"] = {
        "title": "Belangrijke personen",
        "shuffle": False,
        "items": extract_from_enum(nt_pers, "NieuweTestamentBelangrijkePersonenData"),
    }

    nt_strom = read_swift("NieuweTestamentStromingenQuizView.swift")
    packs["nt-stromingen"] = {
        "title": "Stromingen",
        "shuffle": False,
        "items": extract_from_enum(nt_strom, "NieuweTestamentStromingenData"),
    }

    nt_opb = read_swift("NieuweTestamentOpbouwNTView.swift")
    packs["nt-opbouw"] = {
        "title": "Opbouw/type boeken NT",
        "shuffle": False,
        "items": extract_opbouw_nt(nt_opb),
    }

    nt_ach = read_swift("NieuweTestamentAchtenmeierCanonView.swift")
    packs["nt-achtenmeier"] = {
        "title": "Canonvorming NT",
        "shuffle": False,
        "items": extract_achtenmeier(nt_ach),
    }

    catalog = {
        "version": 1,
        "ot": {
            "title": "Oude Testament",
            "sections": [
                {
                    "header": "Hs 1 Jacobson & Chan",
                    "links": [
                        {"label": "I. Historische en Geografische Kaders", "pack": "ot-kaders"},
                        {"label": "II. Begrippen", "pack": "ot-begrippen"},
                        {"label": "III. Personen uit het Oude Testament", "pack": "ot-personen"},
                    ],
                },
                {
                    "header": "Hs 2 Jacobson & Chan",
                    "links": [
                        {"label": "Opbouw OT", "pack": "ot-hs2-opbouw"},
                        {"label": "Canon OT", "pack": "ot-hs2-canon"},
                        {"label": "Ontwikkeling OT", "pack": "ot-hs2-ontwikkeling"},
                        {"label": "Verschil ‘achter’ en ‘in’ de tekst", "pack": "ot-hs2-verschil"},
                        {"label": "Begrippen", "pack": "ot-hs2-begrippen"},
                    ],
                },
            ],
        },
        "nt": {
            "title": "Nieuwe Testament",
            "combinedOrder": [
                "nt-tijdsperiode",
                "nt-begrippen-hs12",
                "nt-personen",
                "nt-stromingen",
                "nt-opbouw",
                "nt-begrippen-hs3",
                "nt-achtenmeier",
            ],
            "sections": [
                {
                    "header": "Oefenen",
                    "links": [{"label": "Gecombineerd oefenen", "combined": True}],
                },
                {
                    "header": "Hs 1–2 Powell",
                    "links": [
                        {"label": "Tijdsperiode", "pack": "nt-tijdsperiode"},
                        {"label": "Begrippen", "pack": "nt-begrippen-hs12"},
                        {"label": "Belangrijke personen", "pack": "nt-personen"},
                        {"label": "Stromingen", "pack": "nt-stromingen"},
                    ],
                },
                {
                    "header": "Hs 3 Powell",
                    "links": [
                        {"label": "Opbouw/type boeken NT", "pack": "nt-opbouw"},
                        {"label": "Begrippen", "pack": "nt-begrippen-hs3"},
                    ],
                },
                {
                    "header": "Achtenmeier",
                    "links": [{"label": "Canonvorming NT", "pack": "nt-achtenmeier"}],
                },
            ],
        },
        "packs": packs,
    }

    for pid, pack in packs.items():
        n = len(pack.get("items") or [])
        print(f"  {pid}: {n} items")
        if n == 0:
            print(f"    WARNING: empty pack {pid}")

    OUT.write_text(json.dumps(catalog, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
