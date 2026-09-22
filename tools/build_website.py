#!/usr/bin/env python3
"""Assemble website/ from the per-report Netlify staging folders.

Each report/essay is deployed independently by tools/deploy-netlify.sh into
its own <report-dir>/netlify/. This script does not render anything itself;
it copies those already-staged folders into one combined, drop-on-Netlify
site with shared navigation across three sections: States, Regions, Essays.

Only finished work is included -- a state/region .qmd with `draft: true`
in its front matter, or one that hasn't been staged yet, is left out.
Re-run this after re-deploying any report to refresh website/ from the
current staged output. Safe to re-run: it fully rebuilds website/ each time.

Usage: python3 tools/build_website.py
"""

import re
import shutil
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SITE_DIR = REPO_ROOT / "website"

# (slug, title, dek, path to that report's netlify/ staging dir)
STATES = [
    (
        "california",
        "California",
        "The largest state roster in the TEAM model, and where readmission risk concentrates.",
        REPO_ROOT / "states" / "california" / "netlify",
    ),
]

REGIONS = []  # No region report is finished yet -- all carry draft: true.

ESSAYS = [
    (
        "napoleon-of-crime",
        "The Thief Who Ran a Company Without Ever Naming It One",
        "For twenty years, Adam Worth was the most wanted man in Europe and almost nobody knew his real name. What he actually built, underneath the theft, was a business.",
        REPO_ROOT / "newsletter" / "napoleon-of-crime" / "netlify",
    ),
    (
        "why-la-one-team-hospital",
        "Why Does Los Angeles Have Only One Hospital in Medicare's TEAM Model?",
        "The country's largest hospital market almost entirely sat out Medicare's newest mandatory payment program. The reason is a lottery.",
        REPO_ROOT / "newsletter" / "why-la-one-team-hospital" / "netlify",
    ),
]

NAV_LINKS = [
    ("/states/", "States"),
    ("/regions/", "Regions"),
    ("/essays/", "Essays"),
]

# Files that belong to a single report's own standalone deploy, not to the
# combined site (each report staged its own; the site gets one shared set).
EXCLUDE_FROM_COPY = {"robots.txt", "netlify.toml"}

NAV_FRAGMENT = """
<style>
  .rf-sitenav {{
    position: sticky;
    top: 0;
    z-index: 40;
    display: flex;
    align-items: center;
    gap: 1.75rem;
    padding: 0.85rem 1.25rem;
    background: #ffffff;
    border-bottom: 1px solid #e2e8f0;
    font-family: -apple-system, "DM Sans", Helvetica, Arial, sans-serif;
  }}
  .rf-sitenav a {{
    color: #475569;
    text-decoration: none;
    font-size: 0.92rem;
    font-weight: 500;
  }}
  .rf-sitenav a:hover {{ color: #2b62e7; }}
  .rf-sitenav .rf-brand {{
    color: #1e293b;
    font-weight: 700;
    font-size: 0.98rem;
    margin-right: auto;
  }}
  .rf-sitenav .rf-brand:hover {{ color: #1e293b; }}
</style>
<nav class="rf-sitenav">
  <a class="rf-brand" href="/">Rainfall Health Reports</a>
  {links}
</nav>
""".strip()

PAGE_SHELL = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="{description}">
</head>
<body>
{nav}
<main class="rf-landing">
{body}
</main>
<style>
  body {{
    margin: 0;
    font-family: -apple-system, "DM Sans", Helvetica, Arial, sans-serif;
    color: #1e293b;
    background: #f8fafc;
  }}
  .rf-landing {{
    max-width: 860px;
    margin: 0 auto;
    padding: 2.5rem 1.25rem 4rem;
  }}
  .rf-landing h1 {{ font-size: 1.9rem; margin-bottom: 0.4rem; }}
  .rf-landing .rf-sub {{ color: #475569; font-size: 1.05rem; margin-bottom: 2.2rem; }}
  .rf-section-title {{
    font-size: 0.8rem;
    font-weight: 700;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: #2b62e7;
    margin: 2.2rem 0 0.9rem;
  }}
  .rf-card {{
    display: block;
    padding: 1.1rem 1.3rem;
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    text-decoration: none;
    color: inherit;
    margin-bottom: 0.75rem;
    transition: border-color 0.15s ease;
  }}
  .rf-card:hover {{ border-color: #2b62e7; }}
  .rf-card h3 {{ margin: 0 0 0.3rem; font-size: 1.05rem; color: #1e293b; }}
  .rf-card p {{ margin: 0; font-size: 0.92rem; color: #475569; line-height: 1.5; }}
  .rf-empty {{
    padding: 1.1rem 1.3rem;
    border: 1px dashed #cbd5e1;
    border-radius: 10px;
    color: #64748b;
    font-size: 0.92rem;
  }}
</style>
</body>
</html>
"""


def nav_html(active=None):
    links = "\n  ".join(
        '<a href="{href}"{cur}>{label}</a>'.format(
            href=href, label=label, cur=' aria-current="page"' if href == active else ""
        )
        for href, label in NAV_LINKS
    )
    return NAV_FRAGMENT.format(links=links)


def inject_nav(html_path: Path, active: str) -> None:
    """Insert the shared nav bar as the first thing inside <body> of a
    Quarto-rendered report page, without touching the rest of the markup."""
    html = html_path.read_text(encoding="utf-8")
    match = re.search(r"<body[^>]*>", html, re.IGNORECASE)
    if not match:
        raise ValueError(f"No <body> tag found in {html_path}")
    insert_at = match.end()
    html = html[:insert_at] + "\n" + nav_html(active) + "\n" + html[insert_at:]
    html_path.write_text(html, encoding="utf-8")


def copy_staged(src: Path, dest: Path) -> None:
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(src, dest)
    for name in EXCLUDE_FROM_COPY:
        p = dest / name
        if p.exists():
            p.unlink()


def card(href: str, title: str, dek: str) -> str:
    return f'<a class="rf-card" href="{href}">\n<h3>{title}</h3>\n<p>{dek}</p>\n</a>'


def build_section_landing(section_path: str, title: str, entries, empty_msg: str) -> None:
    active = f"/{section_path}/"
    if entries:
        cards = "\n".join(
            card(f"/{section_path}/{slug}/", t, d) for slug, t, d, _ in entries
        )
        body = f"<h1>{title}</h1>\n{cards}"
    else:
        body = f"<h1>{title}</h1>\n<div class='rf-empty'>{empty_msg}</div>"
    html = PAGE_SHELL.format(
        title=f"{title} · Rainfall Health Reports",
        description=title,
        nav=nav_html(active),
        body=body,
    )
    out_dir = SITE_DIR / section_path
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "index.html").write_text(html, encoding="utf-8")


def build_home() -> None:
    def section(section_path, title, entries, empty_msg):
        if entries:
            cards = "\n".join(
                card(f"/{section_path}/{slug}/", t, d) for slug, t, d, _ in entries
            )
        else:
            cards = f"<div class='rf-empty'>{empty_msg}</div>"
        return f'<p class="rf-section-title">{title}</p>\n{cards}'

    body = (
        "<h1>Rainfall Health Reports</h1>\n"
        '<p class="rf-sub">Analysis of the CMS TEAM model and related bundled-payment programs, '
        "by state, by region, and in shorter essays.</p>\n"
        + section("states", "States", STATES, "No finished state report yet.")
        + "\n"
        + section("regions", "Regions", REGIONS, "No finished region report yet.")
        + "\n"
        + section("essays", "Essays", ESSAYS, "No published essays yet.")
    )
    html = PAGE_SHELL.format(
        title="Rainfall Health Reports",
        description="Analysis of the CMS TEAM model, by state, by region, and in shorter essays.",
        nav=nav_html(None),
        body=body,
    )
    SITE_DIR.mkdir(parents=True, exist_ok=True)
    (SITE_DIR / "index.html").write_text(html, encoding="utf-8")


def build_entries(section_path: str, entries) -> None:
    for slug, _title, _dek, staged_dir in entries:
        if not staged_dir.exists():
            print(f"  SKIP {section_path}/{slug}: no staged netlify/ dir at {staged_dir}")
            continue
        dest = SITE_DIR / section_path / slug
        copy_staged(staged_dir, dest)
        inject_nav(dest / "index.html", active=f"/{section_path}/")
        print(f"  copied {staged_dir.relative_to(REPO_ROOT)} -> {dest.relative_to(REPO_ROOT)}")


def main():
    if SITE_DIR.exists():
        shutil.rmtree(SITE_DIR)
    SITE_DIR.mkdir(parents=True)

    print("Copying staged reports:")
    build_entries("states", STATES)
    build_entries("regions", REGIONS)
    build_entries("essays", ESSAYS)

    print("Building landing pages:")
    build_home()
    build_section_landing("states", "States", STATES, "No finished state report yet.")
    build_section_landing("regions", "Regions", REGIONS, "No finished region report yet.")
    build_section_landing("essays", "Essays", ESSAYS, "No published essays yet.")
    print(f"  wrote {SITE_DIR / 'index.html'}, states/, regions/, essays/ landing pages")

    (SITE_DIR / "netlify.toml").write_text(
        '[build]\n  publish = "."\n  command = ""\n', encoding="utf-8"
    )
    # Deliberately no robots.txt here: every per-report deploy blocks crawlers
    # by design, but this combined site is the public one meant to be found.
    print(f"\nDone. website/ is ready to drag into Netlify Drop.")


if __name__ == "__main__":
    main()
