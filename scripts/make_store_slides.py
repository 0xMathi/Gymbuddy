#!/usr/bin/env python3
"""Generate App Store panel slides (1290x2796) via headless Chrome.

Two templates, calibrated against the existing GymBuddy slide set:
- device: headline on top, framed iPhone screenshot below (cut at bottom)
- statement: centered typography slide (logo + 3 lines + subline)
"""
import base64
import pathlib
import subprocess
import sys

SCRATCH = pathlib.Path(__file__).parent
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1290, 2796

BASE_CSS = """
* { margin:0; padding:0; box-sizing:border-box; }
html,body { width:1290px; height:2796px; overflow:hidden; }
body {
  background:
    radial-gradient(ellipse 900px 700px at 645px -80px, rgba(255,79,0,0.20), rgba(120,50,10,0.10) 45%, rgba(10,10,11,0) 70%),
    linear-gradient(180deg, #0f0e0f 0%, #0a0a0b 30%, #09090b 100%);
  font-family: -apple-system, "SF Pro Display", "Helvetica Neue", sans-serif;
  -webkit-font-smoothing: antialiased;
  position:relative;
}
.headline {
  position:absolute; top:150px; left:0; width:100%;
  text-align:center; font-weight:800; font-size:104px; line-height:1.06;
  letter-spacing:-2px; color:#f5f5f7;
}
.headline .accent { color:#ff4f00; }
.device {
  position:absolute; top:900px; left:192px; width:906px; height:2000px;
  background:#000; border-radius:144px;
  border:4px solid #3a3a3c;
  box-shadow: 0 0 0 2px rgba(0,0,0,0.9), 0 40px 120px rgba(0,0,0,0.7);
  overflow:hidden;
}
.screen {
  position:absolute; top:20px; left:20px; width:858px; border-radius:126px;
  overflow:hidden; background:#000;
}
.screen img { width:858px; display:block; }
"""

STATEMENT_CSS = """
* { margin:0; padding:0; box-sizing:border-box; }
html,body { width:1290px; height:2796px; overflow:hidden; }
body {
  background:
    radial-gradient(ellipse 750px 650px at 645px 380px, rgba(255,79,0,0.13), rgba(120,50,10,0.06) 45%, rgba(10,10,11,0) 70%),
    linear-gradient(180deg, #0c0b0c 0%, #0a0a0b 40%, #09090b 100%);
  font-family: -apple-system, "SF Pro Display", "Helvetica Neue", sans-serif;
  -webkit-font-smoothing: antialiased;
  position:relative;
}
.block { position:absolute; top:1058px; left:0; width:100%; text-align:center; }
.logo { font-size:34px; font-weight:800; letter-spacing:10px; color:#8e8e93; margin-bottom:56px; }
.logo .gym { color:#ff4f00; }
.lines { font-weight:800; font-size:118px; line-height:1.18; letter-spacing:-2px; color:#f5f5f7; }
.lines .accent { color:#ff4f00; }
.sub { margin-top:64px; font-size:44px; line-height:1.5; font-weight:500; color:#b9b9be; }
"""

DEVICE_HTML = """<!DOCTYPE html><html><head><meta charset="utf-8"><style>{css}</style></head>
<body>
  <div class="headline">{line1}<br><span class="accent">{line2}</span></div>
  <div class="device"><div class="screen"><img src="data:image/png;base64,{img}"></div></div>
</body></html>"""

STATEMENT_HTML = """<!DOCTYPE html><html><head><meta charset="utf-8"><style>{css}</style></head>
<body>
  <div class="block">
    <div class="logo"><span class="gym">GYM</span>BUDDY</div>
    <div class="lines">{line1}<br>{line2}<br><span class="accent">{line3}</span></div>
    <div class="sub">{sub1}<br>{sub2}</div>
  </div>
</body></html>"""


def render(html: str, out: pathlib.Path):
    src = out.with_suffix(".html")
    src.write_text(html)
    subprocess.run([
        CHROME, "--headless=new", f"--screenshot={out}",
        f"--window-size={W},{H}", "--force-device-scale-factor=1",
        "--hide-scrollbars", "--default-background-color=00000000",
        f"file://{src}",
    ], check=True, capture_output=True)
    print("rendered", out.name)


def device_slide(line1, line2, screenshot, out):
    img = base64.b64encode(pathlib.Path(screenshot).read_bytes()).decode()
    render(DEVICE_HTML.format(css=BASE_CSS, line1=line1, line2=line2, img=img), SCRATCH / out)


def statement_slide(line1, line2, line3, sub1, sub2, out):
    render(STATEMENT_HTML.format(css=STATEMENT_CSS, line1=line1, line2=line2,
                                 line3=line3, sub1=sub1, sub2=sub2), SCRATCH / out)


if __name__ == "__main__":
    # EN
    device_slide("See what you lifted", "last time.", SCRATCH / "en-ghost-raw.png", "en-05-last-time.png")
    statement_slide("No account.", "No ads.", "No nonsense.",
                    "100% offline.", "Your data never leaves your phone.",
                    "en-03-no-account.png")
    # DE
    device_slide("Du siehst immer,", "was letztes Mal ging.", SCRATCH / "de-ghost-raw.png", "de-05-letztes-mal.png")
    statement_slide("Kein Account.", "Keine Werbung.", "Kein Quatsch.",
                    "100% offline.", "Deine Daten bleiben auf deinem Handy.",
                    "de-03-kein-account.png")
