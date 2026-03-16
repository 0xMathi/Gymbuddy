#!/usr/bin/env python3
"""Generate 20 exercise images via xAI Grok (grok-imagine-image) → Assets.xcassets.
Style: 3D anatomical illustration, dark background, highlighted muscles in orange/red.
"""

import json
import os
import time
import base64
import subprocess

GROK_API_KEY = os.environ.get("XAI_API_KEY", "")
API_URL = "https://api.x.ai/v1/images/generations"
ASSETS_DIR = "/Users/mathias/GymBuddy/GymBuddy/Assets.xcassets"

STYLE = (
    "Dark near-black background. Body rendered in realistic 3D anatomical CGI style "
    "with detailed visible muscle fibers in light grey and white. "
    "{muscles} highlighted in vivid red-orange. "
    "Black athletic shorts. Photorealistic 3D anatomy illustration like professional "
    "fitness app. No text, no labels, clean composition."
)

EXERCISES = [
    {
        "name": "exercise_bankdruecken",
        "pose": "Muscular male athlete lying on flat bench performing barbell bench press, "
                "3/4 front-top view, arms fully extended pushing loaded barbell straight up. "
                "Flat bench visible below. Barbell with weight plates.",
        "muscles": "Pectoral chest muscles",
    },
    {
        "name": "exercise_schraegbankdruecken",
        "pose": "Muscular male athlete lying on incline bench (45 degree angle) performing "
                "incline barbell bench press, side view, arms fully extended pushing barbell up. "
                "Incline bench clearly visible.",
        "muscles": "Upper pectoral chest muscles",
    },
    {
        "name": "exercise_kurzhantel_flys",
        "pose": "Muscular male athlete lying on flat bench performing dumbbell chest fly, "
                "3/4 top view, arms wide open holding dumbbells at sides at chest level. "
                "Dumbbells in both hands.",
        "muscles": "Pectoral chest muscles",
    },
    {
        "name": "exercise_schulterdruecken",
        "pose": "Muscular male athlete seated on bench performing overhead barbell shoulder press, "
                "slight front-side view, arms fully extended pressing barbell overhead. "
                "Barbell with weight plates overhead.",
        "muscles": "Deltoid shoulder muscles",
    },
    {
        "name": "exercise_seitheben",
        "pose": "Muscular male athlete standing performing dumbbell lateral raises, "
                "front view, both arms raised to shoulder height to the sides, "
                "dumbbells in both hands at shoulder level.",
        "muscles": "Lateral deltoid shoulder muscles",
    },
    {
        "name": "exercise_trizepsdruecken_am_kabel",
        "pose": "Muscular male athlete standing at cable machine performing triceps pushdown, "
                "side view, elbows tucked to sides, arms fully extended downward pushing cable bar. "
                "Cable machine visible behind.",
        "muscles": "Triceps muscles on back of upper arms",
    },
    {
        "name": "exercise_skull_crushers",
        "pose": "Muscular male athlete lying on flat bench performing skull crushers "
                "(lying triceps extension), side view, arms raised vertically holding EZ-bar "
                "above forehead with elbows bent 90 degrees. Bench visible.",
        "muscles": "Triceps muscles",
    },
    {
        "name": "exercise_kreuzheben",
        "pose": "Muscular male athlete performing conventional deadlift, side view, "
                "standing upright at top position with loaded barbell held at hip level, "
                "back straight, chest up. Heavy barbell with weight plates.",
        "muscles": "Lower back erector spinae and hamstring muscles",
    },
    {
        "name": "exercise_klimmzuege",
        "pose": "Muscular male athlete performing pull-ups on horizontal bar, "
                "front view, chin above bar, arms fully bent pulling body up. "
                "Pull-up bar visible at top.",
        "muscles": "Latissimus dorsi and upper back muscles",
    },
    {
        "name": "exercise_langhantel_rudern",
        "pose": "Muscular male athlete performing bent-over barbell row, side view, "
                "torso bent forward parallel to ground, pulling loaded barbell up to lower chest. "
                "Barbell with weight plates.",
        "muscles": "Upper back rhomboid and latissimus muscles",
    },
    {
        "name": "exercise_kabelrudern",
        "pose": "Muscular male athlete seated on cable row machine, side view, "
                "torso upright, arms fully extended forward pulling cable handles to abdomen. "
                "Cable machine visible.",
        "muscles": "Mid-back and latissimus muscles",
    },
    {
        "name": "exercise_face_pulls",
        "pose": "Muscular male athlete standing at cable machine performing face pulls, "
                "slight side-front view, elbows raised high to shoulder level, "
                "pulling rope toward face with both hands. Cable rope attachment visible.",
        "muscles": "Rear deltoid and upper trapezius muscles",
    },
    {
        "name": "exercise_langhantel_curls",
        "pose": "Muscular male athlete standing performing barbell bicep curl, "
                "side view, arms fully curled up bringing barbell to chin level, "
                "elbows close to torso. Barbell visible.",
        "muscles": "Bicep muscles on front of upper arms",
    },
    {
        "name": "exercise_hammer_curls",
        "pose": "Muscular male athlete standing performing hammer curls with dumbbells, "
                "slight front-side view, one arm curled up with neutral grip (thumb up), "
                "dumbbell vertical. Both dumbbells visible.",
        "muscles": "Bicep and brachialis muscles",
    },
    {
        "name": "exercise_kniebeugen",
        "pose": "Muscular male athlete performing barbell back squat, side view, "
                "in deep parallel squat position, barbell across upper back, "
                "knees bent 90 degrees, back straight. Heavy barbell with weight plates.",
        "muscles": "Quadriceps and glute muscles",
    },
    {
        "name": "exercise_rumaenisches_kreuzheben",
        "pose": "Muscular male athlete performing Romanian deadlift with barbell, side view, "
                "hinging at hips, torso leaning forward, legs nearly straight, "
                "barbell close to legs at mid-shin level.",
        "muscles": "Hamstring muscles on back of thighs",
    },
    {
        "name": "exercise_beinpresse",
        "pose": "Muscular male athlete seated in leg press machine, side view, "
                "legs fully extended pushing heavy platform away, feet flat on platform. "
                "Leg press machine frame visible.",
        "muscles": "Quadriceps front thigh muscles",
    },
    {
        "name": "exercise_beinstrecker",
        "pose": "Muscular male athlete seated in leg extension machine, side view, "
                "legs fully extended horizontally, ankle pad visible on shins. "
                "Leg extension machine seat and frame visible.",
        "muscles": "Quadriceps front thigh muscles",
    },
    {
        "name": "exercise_beinbeuger",
        "pose": "Muscular male athlete lying face down on lying leg curl machine, side view, "
                "legs curled up toward glutes at 90 degrees, ankle pad behind heels. "
                "Leg curl machine visible.",
        "muscles": "Hamstring muscles on back of thighs",
    },
    {
        "name": "exercise_wadenheben_stehend",
        "pose": "Muscular male athlete performing standing calf raise, side view, "
                "rising up on tiptoes on edge of elevated platform, arms holding support bar. "
                "Full lower leg and feet clearly visible.",
        "muscles": "Calf gastrocnemius muscles",
    },
]


def generate_image(exercise: dict) -> bytes | None:
    prompt = f"{exercise['pose']} {STYLE.format(muscles=exercise['muscles'])}"

    payload = json.dumps({
        "model": "grok-imagine-image",
        "prompt": prompt,
        "n": 1,
        "response_format": "b64_json",
    })

    result = subprocess.run(
        [
            "curl", "-s", "-X", "POST", API_URL,
            "-H", f"Authorization: Bearer {GROK_API_KEY}",
            "-H", "Content-Type: application/json",
            "-d", payload,
        ],
        capture_output=True, text=True, timeout=120
    )

    try:
        d = json.loads(result.stdout)
        if "data" in d:
            return base64.b64decode(d["data"][0]["b64_json"])
        else:
            print(f"  API error: {json.dumps(d)[:200]}")
            return None
    except Exception as e:
        print(f"  ERROR: {e} — stdout: {result.stdout[:200]}")
        return None


def save_to_xcassets(name: str, image_bytes: bytes):
    imageset_dir = os.path.join(ASSETS_DIR, f"{name}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)

    png_path = os.path.join(imageset_dir, f"{name}.png")
    with open(png_path, "wb") as f:
        f.write(image_bytes)

    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal", "scale": "1x"}],
        "info": {"author": "xcode", "version": 1}
    }
    with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

    print(f"  Saved → {imageset_dir}/")


def main():
    if not GROK_API_KEY:
        raise SystemExit("ERROR: XAI_API_KEY environment variable not set.")
    print(f"GymBuddy Exercise Image Generator — Grok 3D Anatomy Style")
    print(f"Generating {len(EXERCISES)} images\n")

    success = 0
    failed = []

    for i, exercise in enumerate(EXERCISES, 1):
        name = exercise["name"]
        print(f"[{i:02d}/{len(EXERCISES)}] {name}")

        image_bytes = generate_image(exercise)

        if image_bytes and len(image_bytes) > 10_000:
            save_to_xcassets(name, image_bytes)
            success += 1
            print(f"  OK → {len(image_bytes):,} bytes")
        else:
            failed.append(name)
            print(f"  FAILED")

        if i < len(EXERCISES):
            time.sleep(2)

    print(f"\n{'='*60}")
    print(f"Done: {success}/{len(EXERCISES)} images generated")
    if failed:
        print(f"Failed ({len(failed)}): {', '.join(failed)}")


if __name__ == "__main__":
    main()
