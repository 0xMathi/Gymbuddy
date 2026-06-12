#!/usr/bin/env python3
"""Generate GymBuddy exercise + plan images via OpenAI gpt-image-1.

Writes directly into Assets.xcassets (replaces the old CoreGraphics images).
Idempotent: skips images whose target file already exists — delete a .jpg to regenerate it.

Usage:
    OPENAI_API_KEY=sk-... python3 scripts/generate_exercise_images.py [--quality low|medium|high] [--only slug]

Cost (gpt-image-1, 1536x1024): low ~$0.02/img, medium ~$0.07/img.
23 images at medium ≈ $1.60, at low ≈ $0.40.
"""

import argparse
import base64
import json
import os
import subprocess
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "GymBuddy", "Assets.xcassets")

# One shared style constant so every image looks like the same campaign.
STYLE = (
    "Minimalist premium fitness illustration. Near-black background (#0A0A0B). "
    "A single athlete as a dark charcoal silhouette with subtle depth, performing the exercise "
    "with perfect form. Dramatic electric-orange (#FF4F00) rim light along the body and equipment, "
    "soft orange glow accent in one corner, lots of clean negative space. "
    "Bold Nike-campaign mood, cinematic side angle. No text, no logos, no watermark, no faces in detail."
)

# slug -> scene (slugs must match Exercise.imageName: "exercise_<slug>")
EXERCISES = {
    "bankdruecken": "barbell bench press on a flat bench, bar just above the chest",
    "beinbeuger": "lying leg curl machine, heels curling the pad towards the glutes",
    "beinpresse": "45-degree leg press machine, legs pressing the sled",
    "beinstrecker": "seated leg extension machine, legs extended",
    "face_pulls": "standing cable face pull, rope pulled towards the forehead",
    "hammer_curls": "standing dumbbell hammer curls, neutral grip",
    "kabelrudern": "seated cable row, handle pulled to the torso, straight back",
    "klimmzuege": "pull-up on a bar, chin above the bar, full body visible",
    "kniebeugen": "heavy barbell back squat at parallel depth in a power rack",
    "kreuzheben": "conventional barbell deadlift, bar at mid-shin, flat back",
    "kurzhantel_flys": "dumbbell chest flys on a flat bench, arms wide open",
    "langhantel_curls": "standing barbell biceps curl, elbows tucked",
    "langhantel_rudern": "bent-over barbell row, torso hinged forward",
    "rumaenisches_kreuzheben": "Romanian deadlift, barbell sliding along the thighs, hips back",
    "schraegbankdruecken": "incline barbell bench press on a 30-degree bench",
    "schulterdruecken": "seated overhead barbell shoulder press, bar above the head",
    "seitheben": "standing dumbbell lateral raises, arms at shoulder height",
    "skull_crushers": "lying EZ-bar skull crushers on a flat bench, forearms lowering the bar",
    "trizepsdruecken_am_kabel": "standing cable triceps pushdown, elbows locked at the sides",
    "wadenheben_stehend": "standing calf raise on a raised block, heels lifted high",
    # Exercises from the user's Mon/Wed/Fri seed plans
    "kh_bankdruecken": "flat dumbbell bench press, one dumbbell in each hand above the chest",
    "kh_bankdruecken_flach": "flat dumbbell bench press seen from a low three-quarter angle, dumbbells pressed up",
    "einarmiges_kh_rudern": "one-arm dumbbell row, knee and hand supported on a flat bench",
    "schraegbankdruecken_kh": "incline dumbbell press on a 30-degree bench",
    "langhantel_rudern_stehend": "standing bent-over barbell row, torso hinged, bar pulled to the waist",
    "kabelzug_seitenheben": "single-arm cable lateral raise at a cable tower",
    "kabel_bizeps_curls": "standing cable biceps curl with a straight bar attachment",
    "kabel_overhead_trizeps": "overhead cable triceps extension with rope, facing away from the tower",
    "kniebeuge_langhantel": "barbell back squat at full depth, front three-quarter view",
    "ausfallschritte_kh": "walking lunge holding a dumbbell in each hand",
    "hip_thrusts": "barbell hip thrust, upper back on a bench, hips extended",
    "bizeps_curls_kh": "standing alternating dumbbell biceps curls",
    "trizeps_druecken_seil": "cable rope triceps pushdown, rope split at the bottom",
    "t_bar_rudern___kh_rudern": "T-bar row, chest up, handle pulled to the torso",
    "kh_kreuzheben_oder_rdl": "dumbbell Romanian deadlift, dumbbells sliding along the thighs",
    "hanging_leg_raises": "hanging leg raise on a pull-up bar, legs lifted to 90 degrees",
    "dips": "parallel-bar dips, elbows bent at depth, slight forward lean",
}

# Plan card motifs (StartScreenView.imageNameFor)
PLANS = {
    "plan_push": "powerful barbell bench press moment, bar driving upward, chest and shoulders engaged",
    "plan_pull": "explosive pull-up at the top position, back muscles flared, gripping the bar",
    "plan_legs": "deep heavy barbell squat in a power rack, quads under tension",
}


def load_api_key() -> str:
    key = os.environ.get("OPENAI_API_KEY", "").strip()
    if not key:
        for envfile in (".env.local", ".env"):
            path = os.path.join(ROOT, envfile)
            if os.path.exists(path):
                for line in open(path):
                    if line.strip().startswith("OPENAI_API_KEY"):
                        key = line.split("=", 1)[1].strip().strip("\"'")
                        break
            if key:
                break
    if not key:
        sys.exit("FEHLER: OPENAI_API_KEY fehlt (Umgebung oder .env.local). Abbruch — keine Platzhalter-Generierung.")
    return key


def generate(key: str, prompt: str, quality: str) -> bytes:
    body = json.dumps({
        "model": "gpt-image-1",
        "prompt": prompt,
        "size": "1536x1024",
        "quality": quality,
        # NOTE: no 'response_format' param — removed from the API
    }).encode()
    req = urllib.request.Request(
        "https://api.openai.com/v1/images/generations",
        data=body,
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=300) as resp:
        data = json.loads(resp.read())
    item = data["data"][0]
    if item.get("b64_json"):
        return base64.b64decode(item["b64_json"])
    if item.get("url"):
        with urllib.request.urlopen(item["url"], timeout=120) as r:
            return r.read()
    raise RuntimeError(f"Unexpected API response keys: {list(item)}")


def write_imageset(name: str, png_data: bytes) -> str:
    imageset = os.path.join(ASSETS, f"{name}.imageset")
    os.makedirs(imageset, exist_ok=True)

    # Remove stale image files from the old pipeline
    for f in os.listdir(imageset):
        if f.lower().endswith((".png", ".jpg", ".jpeg")):
            os.remove(os.path.join(imageset, f))

    tmp_png = os.path.join(imageset, f"{name}.png")
    jpg = os.path.join(imageset, f"{name}.jpg")
    with open(tmp_png, "wb") as f:
        f.write(png_data)

    # API returns PNG (2-4 MB) — compress to JPEG (<500 KB)
    subprocess.run(
        ["sips", "-s", "format", "jpeg", "-s", "formatOptions", "78", tmp_png, "--out", jpg],
        check=True, capture_output=True,
    )
    os.remove(tmp_png)

    with open(os.path.join(imageset, "Contents.json"), "w") as f:
        json.dump({
            "images": [{"filename": f"{name}.jpg", "idiom": "universal"}],
            "info": {"author": "xcode", "version": 1},
        }, f, indent=2)
    return jpg


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--quality", default="medium", choices=["low", "medium", "high"])
    parser.add_argument("--only", help="generate a single slug (e.g. 'bankdruecken' or 'plan_push')")
    args = parser.parse_args()

    key = load_api_key()

    targets: dict[str, str] = {}
    for slug, scene in EXERCISES.items():
        targets[f"exercise_{slug}"] = f"EXERCISE: {scene}. {STYLE}"
    for slug, scene in PLANS.items():
        targets[slug] = f"SCENE: {scene}. {STYLE}"

    if args.only:
        match = args.only if args.only in targets else f"exercise_{args.only}"
        if match not in targets:
            sys.exit(f"FEHLER: unbekannter Slug '{args.only}'")
        targets = {match: targets[match]}

    ok = failed = skipped = 0
    for name, prompt in targets.items():
        jpg = os.path.join(ASSETS, f"{name}.imageset", f"{name}.jpg")
        if os.path.exists(jpg):
            skipped += 1
            print(f"⏭  {name} (existiert)")
            continue
        try:
            data = generate(key, prompt, args.quality)
            path = write_imageset(name, data)
            size_kb = os.path.getsize(path) // 1024
            ok += 1
            print(f"✅ {name} ({size_kb} KB)")
        except Exception as e:  # report and continue — rerun resumes via skip-if-exists
            failed += 1
            print(f"❌ {name}: {e}")

    print(f"\nFertig: {ok} generiert, {skipped} übersprungen, {failed} fehlgeschlagen.")
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
