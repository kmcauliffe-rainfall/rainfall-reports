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
    (
        "new-york",
        "New York",
        "The second-largest state roster in the TEAM model — and where the readmissions story everyone repeats turns out to be wrong.",
        REPO_ROOT / "states" / "new-york" / "netlify",
    ),
    (
        "new-jersey",
        "New Jersey",
        "The worst readmissions profile of any large state roster in the TEAM model — verified against live CMS data, not the headline number that circulates.",
        REPO_ROOT / "states" / "new-jersey" / "netlify",
    ),
    (
        "massachusetts",
        "Massachusetts",
        "Strong on hip and knee replacement, hot on everything else — not the academic-medicine paradox the old headline number suggested.",
        REPO_ROOT / "states" / "massachusetts" / "netlify",
    ),
    (
        "florida",
        "Florida",
        "The largest readmissions gap of any state checked so far isn't hip and knee — it's heart attack, at nearly twice the national rate.",
        REPO_ROOT / "states" / "florida" / "netlify",
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
        "The country's largest hospital market almost entirely sat out Medicare's newest mandatory payment program. The reason isn't policy, and it isn't politics. It's a lottery.",
        REPO_ROOT / "newsletter" / "why-la-one-team-hospital" / "netlify",
    ),
    (
        "the-lotterys-biggest-misses",
        "Why Do Miami, Tampa, and Los Angeles Each Have Only One Hospital in Medicare's TEAM Model?",
        "Three of the country's biggest, most recognizable hospital markets came up almost empty in Medicare's newest mandatory payment program. In every case, the same kind of hospital volunteered to fill the gap.",
        REPO_ROOT / "newsletter" / "the-lotterys-biggest-misses" / "netlify",
    ),
    (
        "the-team-hospital-with-no-surgeries",
        "Why Is a Nursing Home With No Operating Room on Medicare's Mandatory Surgery List?",
        "Laguna Honda Hospital has no emergency room and, by CMS's own quality data, performs none of the five surgeries Medicare's TEAM model is built around. It's on the mandatory roster anyway, for a reason that has nothing to do with what the hospital does.",
        REPO_ROOT / "newsletter" / "the-team-hospital-with-no-surgeries" / "netlify",
    ),
    (
        "cjr-history-team-selection",
        "San Francisco Got Let Off the Hook Under CJR. Under TEAM, It Became California's Biggest Market.",
        "Los Angeles stayed a mandatory CJR market for nine years for being expensive. San Francisco got downgraded to voluntary in 2018. Under TEAM's own, separate lottery, LA drew one hospital, voluntarily. San Francisco drew 37, mandatorily -- the most of any market in California.",
        REPO_ROOT / "newsletter" / "cjr-history-team-selection" / "netlify",
    ),
    (
        "modesto-the-market-that-lost-twice",
        "Modesto and San Francisco Had the Same CJR History. One Got 37 TEAM Hospitals. The Other Got Zero.",
        "San Francisco and Modesto both lost mandatory CJR status in 2018 and kept running the program voluntarily through its final day -- the same trajectory, right up to TEAM's own separate lottery. San Francisco drew 37 hospitals, mandatorily. Modesto drew none, not even a single voluntary joiner.",
        REPO_ROOT / "newsletter" / "modesto-the-market-that-lost-twice" / "netlify",
    ),
    (
        "the-one-hospital-towns",
        "Two California Markets Have Exactly One TEAM Hospital Each — Because That's All There Is",
        "Los Angeles has one hospital in Medicare's TEAM model because a huge metro got skipped by the lottery and one CJR veteran volunteered in. Crescent City and Hanford-Corcoran have one hospital each too — for the opposite reason: there's only one hospital in either market, and this time the lottery actually caught them.",
        REPO_ROOT / "newsletter" / "the-one-hospital-towns" / "netlify",
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

# Section metadata: icon glyph + one-word kicker shown on every card in
# that section, so a mixed grid (e.g. the homepage) still reads at a glance.
SECTION_META = {
    "states": {"kicker": "Whitepaper", "empty": "No finished state report yet."},
    "regions": {"kicker": "Whitepaper", "empty": "No finished region report yet."},
    "essays": {"kicker": "Essay", "empty": "No published essays yet."},
}

SHARED_CSS = """
  @font-face {
    font-family: "DM Sans";
    src: url("/fonts/DMSans-Variable.ttf") format("truetype-variations");
    font-weight: 100 1000;
    font-display: swap;
  }
  @font-face {
    font-family: "DM Sans";
    src: url("/fonts/DMSans-Regular.ttf") format("truetype");
    font-weight: 400;
    font-display: swap;
  }
  @font-face {
    font-family: "DM Sans";
    src: url("/fonts/DMSans-Medium.ttf") format("truetype");
    font-weight: 500;
    font-display: swap;
  }
  @font-face {
    font-family: "DM Sans";
    src: url("/fonts/DMSans-Bold.ttf") format("truetype");
    font-weight: 700;
    font-display: swap;
  }
  :root {
    --rain-navy: #1e293b;
    --rain-blue: #2b62e7;
    --rain-blue-deep: #1d4ed8;
    --rain-muted: #64748b;
    --rain-slate: #475569;
    --rain-line: #e2e8f0;
    --rain-bg: #f8fafc;
    --rain-card: #ffffff;
    --rain-card-hover: #f5f8ff;
  }
  * { box-sizing: border-box; }
  html { -webkit-text-size-adjust: 100%; }
  body {
    margin: 0;
    font-family: "DM Sans", -apple-system, Helvetica, Arial, sans-serif;
    color: var(--rain-navy);
    background: var(--rain-bg);
    -webkit-font-smoothing: antialiased;
  }
  a { color: var(--rain-blue); }
"""

NAV_FRAGMENT = """
<style>
{nav_css}
</style>
<nav class="rf-sitenav">
  <a class="rf-brand" href="/">
    <img src="/assets/rainfall-logo.svg" alt="" class="rf-brand-mark">
    <span>Rainfall Health <span class="rf-brand-sub">Reports</span></span>
  </a>
  <div class="rf-sitenav-links">
  {links}
  </div>
</nav>
""".strip()

NAV_CSS = """
  @font-face {
    font-family: "DM Sans";
    src: url("/fonts/DMSans-Medium.ttf") format("truetype");
    font-weight: 500;
    font-display: swap;
  }
  @font-face {
    font-family: "DM Sans";
    src: url("/fonts/DMSans-Bold.ttf") format("truetype");
    font-weight: 700;
    font-display: swap;
  }
  :root {
    --rain-navy: #1e293b;
    --rain-blue: #2b62e7;
    --rain-muted: #64748b;
    --rain-slate: #475569;
    --rain-line: #e2e8f0;
  }
  .rf-sitenav {
    position: sticky;
    top: 0;
    z-index: 40;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1.5rem;
    padding: 0.9rem 1.5rem;
    background: rgba(255, 255, 255, 0.92);
    backdrop-filter: blur(8px);
    border-bottom: 1px solid var(--rain-line);
  }
  .rf-brand {
    display: flex;
    align-items: center;
    gap: 0.55rem;
    color: var(--rain-navy);
    text-decoration: none;
    font-weight: 700;
    font-size: 1rem;
    letter-spacing: -0.01em;
    white-space: nowrap;
  }
  .rf-brand:hover { color: var(--rain-navy); }
  .rf-brand-mark { height: 22px; width: 22px; display: block; }
  .rf-brand-sub { font-weight: 500; color: var(--rain-muted); }
  .rf-sitenav-links { display: flex; align-items: center; gap: 1.5rem; }
  .rf-sitenav-links a {
    color: var(--rain-slate);
    text-decoration: none;
    font-size: 0.92rem;
    font-weight: 500;
    padding: 0.3rem 0;
    border-bottom: 2px solid transparent;
    transition: color 0.15s ease, border-color 0.15s ease;
  }
  .rf-sitenav-links a:hover { color: var(--rain-blue); }
  .rf-sitenav-links a[aria-current="page"] {
    color: var(--rain-navy);
    border-bottom-color: var(--rain-blue);
  }
  @media (max-width: 520px) {
    .rf-sitenav { padding: 0.8rem 1rem; }
    .rf-sitenav-links { gap: 1rem; }
    .rf-brand-sub { display: none; }
  }
"""

FOOTER_HTML = """
<footer class="rf-footer">
  <div class="rf-footer-inner">
    <p class="rf-footer-brand">Rainfall Health Reports</p>
    <p>Independent analysis of CMS's TEAM bundled-payment model and related programs. Not affiliated with CMS or any hospital named in these reports.</p>
    <p class="rf-footer-meta">Rainfall Health is not a hospital, health system, or health care provider, and this content does not constitute clinical, legal, financial, or regulatory advice. &middot; <a href="https://www.rainfallhealth.com/cms-team/" target="_blank" rel="noopener">rainfallhealth.com</a></p>
  </div>
</footer>
"""

FOOTER_CSS = """
  .rf-footer {
    border-top: 1px solid var(--rain-line);
    margin-top: 3rem;
  }
  .rf-footer-inner {
    max-width: 900px;
    margin: 0 auto;
    padding: 1.75rem 1.5rem 2.5rem;
    color: var(--rain-muted);
    font-size: 0.85rem;
    line-height: 1.6;
  }
  .rf-footer-brand {
    color: var(--rain-navy);
    font-weight: 700;
    margin: 0 0 0.35rem;
  }
  .rf-footer-inner p { margin: 0 0 0.35rem; }
  .rf-footer-meta { color: #94a3b8; }
  .rf-footer-meta a { color: var(--rain-muted); }
"""

PAGE_SHELL = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="{description}">
<link rel="icon" href="/assets/rainfall-logo.svg" type="image/svg+xml">
<style>
{shared_css}
{nav_css}
  .rf-landing {{
    max-width: 900px;
    margin: 0 auto;
    padding: 3rem 1.5rem 2rem;
  }}
  .rf-hero-kicker {{
    font-size: 0.78rem;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--rain-blue);
    margin: 0 0 0.6rem;
  }}
  .rf-landing h1 {{
    font-size: clamp(1.7rem, 4vw, 2.35rem);
    line-height: 1.15;
    letter-spacing: -0.01em;
    margin: 0 0 0.6rem;
  }}
  .rf-landing .rf-sub {{
    color: var(--rain-slate);
    font-size: 1.05rem;
    line-height: 1.55;
    max-width: 640px;
    margin: 0 0 2.4rem;
  }}
  .rf-section-title {{
    display: flex;
    align-items: baseline;
    gap: 0.6rem;
    font-size: 0.78rem;
    font-weight: 700;
    letter-spacing: 0.07em;
    text-transform: uppercase;
    color: var(--rain-blue);
    margin: 2.6rem 0 1rem;
  }}
  .rf-section-title:first-of-type {{ margin-top: 0; }}
  .rf-section-count {{
    font-weight: 500;
    letter-spacing: normal;
    text-transform: none;
    color: var(--rain-muted);
    font-size: 0.8rem;
  }}
  .rf-back {{
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    color: var(--rain-muted);
    text-decoration: none;
    font-size: 0.88rem;
    font-weight: 500;
    margin-bottom: 1.6rem;
  }}
  .rf-back:hover {{ color: var(--rain-blue); }}
  .rf-grid {{
    display: grid;
    gap: 0.85rem;
  }}
  .rf-card {{
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    padding: 1.25rem 1.4rem;
    background: var(--rain-card);
    border: 1px solid var(--rain-line);
    border-radius: 12px;
    text-decoration: none;
    color: inherit;
    box-shadow: 0 1px 2px rgba(15, 23, 42, 0.03);
    transition: border-color 0.15s ease, box-shadow 0.15s ease, transform 0.15s ease, background 0.15s ease;
  }}
  .rf-card:hover {{
    border-color: var(--rain-blue);
    background: var(--rain-card-hover);
    box-shadow: 0 6px 16px rgba(43, 98, 231, 0.1);
    transform: translateY(-1px);
  }}
  .rf-card-kicker {{
    font-size: 0.72rem;
    font-weight: 700;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: var(--rain-muted);
  }}
  .rf-card h3 {{
    margin: 0;
    font-size: 1.08rem;
    line-height: 1.35;
    color: var(--rain-navy);
    font-weight: 700;
  }}
  .rf-card p {{
    margin: 0;
    font-size: 0.92rem;
    color: var(--rain-slate);
    line-height: 1.55;
  }}
  .rf-card-arrow {{
    align-self: flex-end;
    margin-top: -1.6rem;
    color: var(--rain-line);
    font-size: 1.1rem;
    transition: color 0.15s ease, transform 0.15s ease;
  }}
  .rf-card:hover .rf-card-arrow {{ color: var(--rain-blue); transform: translateX(2px); }}
  .rf-empty {{
    padding: 1.25rem 1.4rem;
    border: 1px dashed #cbd5e1;
    border-radius: 12px;
    color: var(--rain-muted);
    font-size: 0.92rem;
  }}
{footer_css}
  @media (max-width: 560px) {{
    .rf-landing {{ padding: 2.2rem 1.15rem 1.5rem; }}
  }}
</style>
</head>
<body>
{nav}
<main class="rf-landing">
{body}
</main>
{footer}
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
    return NAV_FRAGMENT.format(links=links, nav_css=NAV_CSS)


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


def card(href: str, title: str, dek: str, kicker: str) -> str:
    return (
        f'<a class="rf-card" href="{href}">\n'
        f'<p class="rf-card-kicker">{kicker}</p>\n'
        f"<h3>{title}</h3>\n"
        f"<p>{dek}</p>\n"
        f'<span class="rf-card-arrow" aria-hidden="true">&rarr;</span>\n'
        "</a>"
    )


def _page(title: str, description: str, nav: str, body: str) -> str:
    return PAGE_SHELL.format(
        title=title,
        description=description,
        nav=nav,
        body=body,
        shared_css=SHARED_CSS,
        nav_css=NAV_CSS,
        footer_css=FOOTER_CSS,
        footer=FOOTER_HTML,
    )


def build_section_landing(section_path: str, title: str, entries, empty_msg: str) -> None:
    active = f"/{section_path}/"
    kicker = SECTION_META.get(section_path, {}).get("kicker", "")
    count = f'<span class="rf-section-count">{len(entries)}</span>' if entries else ""
    if entries:
        cards = '<div class="rf-grid">\n' + "\n".join(
            card(f"/{section_path}/{slug}/", t, d, kicker) for slug, t, d, _ in entries
        ) + "\n</div>"
    else:
        cards = f"<div class='rf-empty'>{empty_msg}</div>"
    body = (
        '<a class="rf-back" href="/">&larr; All reports</a>\n'
        f"<h1>{title}</h1>\n{cards}"
    )
    html = _page(
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
        kicker = SECTION_META.get(section_path, {}).get("kicker", "")
        if entries:
            cards = '<div class="rf-grid">\n' + "\n".join(
                card(f"/{section_path}/{slug}/", t, d, kicker) for slug, t, d, _ in entries
            ) + "\n</div>"
        else:
            cards = f"<div class='rf-empty'>{empty_msg}</div>"
        return (
            f'<p class="rf-section-title"><a href="/{section_path}/" style="color:inherit;text-decoration:none;">{title}</a>'
            f' <span class="rf-section-count">{len(entries)}</span></p>\n{cards}'
        )

    body = (
        '<p class="rf-hero-kicker">CMS TEAM Model &middot; Bundled Payments</p>\n'
        "<h1>Rainfall Health Reports</h1>\n"
        '<p class="rf-sub">Independent analysis of the CMS TEAM model and related bundled-payment '
        "programs — full state and regional whitepapers, plus shorter essays on specific findings.</p>\n"
        + section("states", "States", STATES, "No finished state report yet.")
        + "\n"
        + section("regions", "Regions", REGIONS, "No finished region report yet.")
        + "\n"
        + section("essays", "Essays", ESSAYS, "No published essays yet.")
    )
    html = _page(
        title="Rainfall Health Reports",
        description="Independent analysis of the CMS TEAM model, by state, by region, and in shorter essays.",
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

    # Shared fonts/logo for the site shell (nav + landing pages). Individual
    # report pages carry their own copies inside their staged netlify/ dirs.
    shutil.copytree(REPO_ROOT / "fonts", SITE_DIR / "fonts")
    (SITE_DIR / "assets").mkdir(parents=True, exist_ok=True)
    for name in ("rainfall-logo.svg", "rainfall-logo.png"):
        src = REPO_ROOT / "assets" / name
        if src.exists():
            shutil.copy2(src, SITE_DIR / "assets" / name)

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
