#!/usr/bin/env python3
"""Generate public/ download page + QR for AlertaCL IPA."""
from __future__ import annotations

import argparse
import pathlib
import urllib.parse
import urllib.request


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", required=True, help="owner/name")
    args = parser.parse_args()

    ipa = f"https://github.com/{args.repo}/releases/latest/download/AlertaCL-unsigned.ipa"
    releases = f"https://github.com/{args.repo}/releases/latest"
    out = pathlib.Path("public")
    out.mkdir(parents=True, exist_ok=True)

    qr_url = (
        "https://api.qrserver.com/v1/create-qr-code/?size=360x360&data="
        + urllib.parse.quote(ipa)
    )
    (out / "qr-ipa.png").write_bytes(urllib.request.urlopen(qr_url, timeout=30).read())

    html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>AlertaCL — Descargar IPA</title>
<style>
  :root {{ --bg:#0b1524; --fg:#f4f7fb; --muted:#9bb0c4; }}
  * {{ box-sizing:border-box; }}
  body {{
    margin:0; font-family: ui-rounded, "SF Pro Display", system-ui, sans-serif;
    background:
      radial-gradient(1200px 600px at 80% -10%, #3a1520, transparent),
      radial-gradient(900px 500px at -10% 20%, #16304a, transparent),
      var(--bg);
    color: var(--fg); min-height:100vh; display:grid; place-items:center; padding:24px;
  }}
  main {{ max-width:420px; width:100%; text-align:center; }}
  h1 {{ font-size:2.4rem; letter-spacing:-.03em; margin:0 0 .4rem; }}
  p {{ color:var(--muted); line-height:1.5; }}
  img.qr {{
    width:280px; height:280px; border-radius:24px; background:#fff;
    padding:16px; margin:20px 0;
  }}
  a.btn {{
    display:inline-block; margin:.4rem; padding:14px 22px; border-radius:999px;
    background:linear-gradient(135deg,#e22333,#c40a1a); color:#fff;
    text-decoration:none; font-weight:700;
  }}
  a.ghost {{ background:transparent; border:1px solid #456; color:var(--fg); }}
  ol {{ text-align:left; color:var(--muted); }}
</style>
</head>
<body>
<main>
  <h1>AlertaCL</h1>
  <p>Alertas sísmicas para Chile · IPA sin firmar para Sideloadly</p>
  <img class="qr" src="qr-ipa.png" alt="QR descarga IPA"/>
  <p>Escaneá el QR o tocá descargar</p>
  <p>
    <a class="btn" href="{ipa}">Descargar IPA</a>
    <a class="btn ghost" href="{releases}">Releases</a>
  </p>
  <ol>
    <li>Descargá el IPA en una PC</li>
    <li>Abrí Sideloadly e iniciá sesión con tu Apple ID</li>
    <li>Conectá el iPhone e instalá</li>
    <li>En iOS: Ajustes → General → VPN y gestión de dispositivos → confiar</li>
  </ol>
  <p style="font-size:.85rem">Requiere iOS 26+ (Liquid Glass). Critical Alerts de Apple no aplican en sideload.</p>
</main>
</body>
</html>
"""
    (out / "index.html").write_text(html, encoding="utf-8")
    print("page ready", ipa)


if __name__ == "__main__":
    main()
