#!/usr/bin/env python3
"""Generate App Store panel slides (1290x2796) via headless Chrome.

Three templates, calibrated against the existing GymBuddy slide set:
- device: headline on top, framed iPhone screenshot below (cut at bottom)
- statement: centered typography slide (logo + 3 lines + subline)
- lockscreen: stylized lock screen with the rest-timer Live Activity banner
  (composed, not a raw shot — brand wallpaper, neutral 17:21 clock; used for
  slot 4 in both languages since the simulator can't render a ticking lock)

Usage: python3 make_store_slides.py [all|ghost|lockscreen]
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


# --- Stylized lock screen (slot 4) -------------------------------------------

LOCKSCREEN_CSS = """
.lockscreen {
  position:relative; width:858px; height:1880px;
  background:
    radial-gradient(ellipse 700px 460px at 50% 66%, rgba(255,79,0,0.26), rgba(140,60,15,0.10) 55%, rgba(10,10,11,0) 76%),
    linear-gradient(180deg, #131315 0%, #0a0a0b 40%, #1c1109 68%, #2e1707 100%);
}
.lock { position:absolute; top:78px; width:100%; text-align:center; }
.lock svg { width:30px; height:30px; opacity:0.9; }
.ls-date { position:absolute; top:128px; width:100%; text-align:center;
  font-size:33px; font-weight:600; color:rgba(245,245,247,0.92); }
.ls-clock { position:absolute; top:150px; width:100%; text-align:center;
  font-size:190px; font-weight:700; letter-spacing:-3px; color:#f5f5f7; }
.banner {
  position:absolute; left:28px; right:28px; bottom:212px;
  background:rgba(13,13,15,0.97); border-radius:38px; padding:36px 38px 38px;
}
.b-top { display:flex; align-items:baseline; justify-content:space-between; }
.b-kicker { font-size:22px; font-weight:900; letter-spacing:3px; color:#ff4f00; }
.b-time { font-family:"SF Mono", ui-monospace, Menlo, monospace;
  font-size:56px; font-weight:900; color:#ff4f00; }
.b-exercise { margin-top:4px; font-size:35px; font-weight:900; letter-spacing:0.5px; color:#fafafa; }
.b-bar { margin-top:26px; height:9px; border-radius:5px; background:#39393d; overflow:hidden; }
.b-bar div { width:66%; height:100%; border-radius:5px; background:#ff4f00; }
.b-bottom { margin-top:28px; display:flex; align-items:center; justify-content:space-between; }
.b-next { font-size:19px; font-weight:800; letter-spacing:1.5px; color:#a1a1a6; }
.b-skip { background:#ff4f00; border-radius:999px; padding:14px 28px;
  font-size:20px; font-weight:900; letter-spacing:1.5px; color:#0a0a0b; }
.quick { position:absolute; bottom:62px; width:84px; height:84px; border-radius:50%;
  background:rgba(255,255,255,0.20); display:flex; align-items:center; justify-content:center; }
.quick svg { width:34px; height:34px; }
.quick.flash { left:88px; }
.quick.cam { right:88px; }
.homebar { position:absolute; bottom:16px; left:50%; transform:translateX(-50%);
  width:250px; height:6px; border-radius:3px; background:rgba(255,255,255,0.9); }
"""

LOCK_SVG = ('<svg viewBox="0 0 24 24" fill="none"><rect x="5" y="10.5" width="14" height="10" '
            'rx="2.6" fill="#f5f5f7"/><path d="M8 10.5V7.6a4 4 0 1 1 8 0v2.9" stroke="#f5f5f7" '
            'stroke-width="2.4" fill="none"/></svg>')
FLASH_SVG = ('<svg viewBox="0 0 24 24" fill="#f5f5f7"><path d="M9 2h6v3.5L13.6 8v12.6a1.6 1.6 0 0 1-3.2 0V8L9 5.5Z"/></svg>')
CAM_SVG = ('<svg viewBox="0 0 24 24" fill="#f5f5f7"><path d="M4 7.5h3.2L9 5.2h6L16.8 7.5H20a1.5 1.5 0 0 1 1.5 1.5v9A1.5 1.5 0 0 1 20 19.5H4A1.5 1.5 0 0 1 2.5 18V9A1.5 1.5 0 0 1 4 7.5Z"/>'
           '<circle cx="12" cy="13" r="3.4" fill="#0a0a0b"/></svg>')

LOCKSCREEN_HTML = """<!DOCTYPE html><html><head><meta charset="utf-8"><style>{css}{ls_css}</style></head>
<body>
  <div class="headline">{line1}<br><span class="accent">{line2}</span></div>
  <div class="device"><div class="screen">
    <div class="lockscreen">
      <div class="lock">{lock_svg}</div>
      <div class="ls-date">{date}</div>
      <div class="ls-clock">17:21</div>
      <div class="banner">
        <div class="b-top"><span class="b-kicker">{kicker}</span><span class="b-time">1:19</span></div>
        <div class="b-exercise">{exercise}</div>
        <div class="b-bar"><div></div></div>
        <div class="b-bottom"><span class="b-next">{next}</span><span class="b-skip">{skip}</span></div>
      </div>
      <div class="quick flash">{flash_svg}</div>
      <div class="quick cam">{cam_svg}</div>
      <div class="homebar"></div>
    </div>
  </div></div>
</body></html>"""


def lockscreen_slide(line1, line2, date, kicker, exercise, next_label, skip, out):
    render(LOCKSCREEN_HTML.format(
        css=BASE_CSS, ls_css=LOCKSCREEN_CSS, lock_svg=LOCK_SVG, flash_svg=FLASH_SVG,
        cam_svg=CAM_SVG, line1=line1, line2=line2, date=date, kicker=kicker,
        exercise=exercise, next=next_label, skip=skip), SCRATCH / out)


if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "all"

    if which in ("all", "ghost"):
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

    if which in ("all", "lockscreen"):
        # Slot 4: rest-timer Live Activity — banner strings mirror the app's
        # RestActivityAttributes content (L + ExerciseLocalization) exactly.
        lockscreen_slide("Dein Timer lebt", "auf dem Lockscreen.",
                         "Montag, 6. Juli", "PAUSE · SATZ 3", "KH-BANKDRÜCKEN",
                         "DANN: EINARMIGES KH-RUDERN", "ÜBERSPRINGEN",
                         "de-04-pausen-timer.png")
        lockscreen_slide("Your timer lives", "on your Lock Screen.",
                         "Monday, July 6", "REST · SET 3", "DUMBBELL BENCH PRESS",
                         "THEN: ONE-ARM DUMBBELL ROW", "SKIP",
                         "en-04-rest-timer.png")
