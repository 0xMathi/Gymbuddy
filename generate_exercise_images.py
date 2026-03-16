#!/usr/bin/env python3
"""Generate 20 exercise images via Hugging Face Inference API and integrate into Assets.xcassets."""

import json
import os
import time
import urllib.request
import urllib.error

HF_TOKEN = os.environ.get("HF_TOKEN", "")
API_URL = "https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell"
ASSETS_DIR = "/Users/mathias/GymBuddy/GymBuddy/Assets.xcassets"

EXERCISES = [
    {
        "name": "exercise_bankdruecken",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing barbell bench press exercise, side view. Clean white light grey silhouette body. Chest pectoral muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_schraegbankdruecken",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing incline barbell bench press, side view. Clean white light grey silhouette body. Upper chest pectoral muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_kurzhantel_flys",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing dumbbell chest fly exercise lying on bench, front 3/4 view arms wide. Clean white light grey silhouette body. Chest pectoral muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_schulterdruecken",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing overhead barbell shoulder press, side view. Clean white light grey silhouette body. Shoulder deltoid muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_seitheben",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing lateral raises with dumbbells, front view arms raised to sides at shoulder height. Clean white light grey silhouette body. Side lateral deltoid muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_trizepsdruecken_am_kabel",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing cable triceps pushdown exercise, side view elbows tucked. Clean white light grey silhouette body. Triceps muscle on back of upper arm highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_skull_crushers",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing skull crushers lying triceps extension on bench, side view. Clean white light grey silhouette body. Triceps muscle highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_kreuzheben",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing deadlift with barbell, side view hinging from hips. Clean white light grey silhouette body. Lower back erector spinae and hamstring muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_klimmzuege",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing pull-ups on horizontal bar, front view chin above bar. Clean white light grey silhouette body. Latissimus dorsi back muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_langhantel_rudern",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing bent-over barbell row, side view torso parallel to ground. Clean white light grey silhouette body. Upper back rhomboid latissimus muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_kabelrudern",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing seated cable row exercise, side view pulling handles to torso. Clean white light grey silhouette body. Mid-back and latissimus muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_face_pulls",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing face pull exercise with cable rope, side view arms pulling toward face elbows flared. Clean white light grey silhouette body. Rear deltoid and upper trapezius muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_langhantel_curls",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing standing barbell bicep curl, side view arms curled up. Clean white light grey silhouette body. Bicep muscle on front of upper arm highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_hammer_curls",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing hammer curls with dumbbells, side view neutral grip thumbs up. Clean white light grey silhouette body. Bicep and brachialis muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_kniebeugen",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing barbell back squat, side view in deep squat position. Clean white light grey silhouette body. Quadriceps thigh muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_rumaenisches_kreuzheben",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing Romanian deadlift with barbell, side view hinging at hips legs slightly bent. Clean white light grey silhouette body. Hamstring muscles on back of thighs highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_beinpresse",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing leg press machine exercise, side view seated legs pushing platform away. Clean white light grey silhouette body. Quadriceps thigh muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_beinstrecker",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing leg extension machine exercise seated, side view legs fully extended. Clean white light grey silhouette body. Quadriceps front thigh muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_beinbeuger",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing lying leg curl machine exercise, side view lying face down curling legs toward glutes. Clean white light grey silhouette body. Hamstring muscles on back of thighs highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
    {
        "name": "exercise_wadenheben_stehend",
        "prompt": "Minimalist athletic silhouette illustration. Nearly black background. Male athlete performing standing calf raise on edge of step, side view rising up on tiptoes. Clean white light grey silhouette body. Calf gastrocnemius muscles highlighted in vivid bright orange. All other body parts white grey silhouette. No text no labels. Flat bold poster style. Nike campaign aesthetic. Wide 16:9 landscape."
    },
]


def generate_image(exercise: dict) -> bytes | None:
    payload = json.dumps({
        "inputs": exercise["prompt"],
        "parameters": {
            "width": 1024,
            "height": 576,
            "num_inference_steps": 4,
            "guidance_scale": 0.0,
        }
    }).encode("utf-8")

    req = urllib.request.Request(
        API_URL,
        data=payload,
        headers={
            "Authorization": f"Bearer {HF_TOKEN}",
            "Content-Type": "application/json",
            "Accept": "image/png",
        },
        method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            return response.read()
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")[:300]
        print(f"  HTTP {e.code}: {body}")
        return None
    except Exception as e:
        print(f"  ERROR: {e}")
        return None


def save_to_xcassets(name: str, image_bytes: bytes):
    imageset_dir = os.path.join(ASSETS_DIR, f"{name}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)

    # Save PNG
    png_path = os.path.join(imageset_dir, f"{name}.png")
    with open(png_path, "wb") as f:
        f.write(image_bytes)

    # Save Contents.json
    contents = {
        "images": [
            {
                "filename": f"{name}.png",
                "idiom": "universal",
                "scale": "1x"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    json_path = os.path.join(imageset_dir, "Contents.json")
    with open(json_path, "w") as f:
        json.dump(contents, f, indent=2)

    print(f"  Saved → {imageset_dir}/")


def main():
    print(f"Generating {len(EXERCISES)} exercise images via Hugging Face FLUX.1-schnell\n")

    success = 0
    failed = []

    for i, exercise in enumerate(EXERCISES, 1):
        name = exercise["name"]
        print(f"[{i:02d}/{len(EXERCISES)}] {name}")

        image_bytes = generate_image(exercise)

        if image_bytes and len(image_bytes) > 5000:
            save_to_xcassets(name, image_bytes)
            success += 1
            print(f"  OK → {len(image_bytes):,} bytes")
        else:
            failed.append(name)
            if image_bytes:
                print(f"  FAILED (response too small: {len(image_bytes)} bytes)")
            else:
                print(f"  FAILED (no response)")

        # Brief pause between requests to avoid rate limiting
        if i < len(EXERCISES):
            time.sleep(3)

    print(f"\n{'='*60}")
    print(f"Result: {success}/{len(EXERCISES)} images generated successfully")
    if failed:
        print(f"Failed ({len(failed)}): {', '.join(failed)}")


if __name__ == "__main__":
    main()
