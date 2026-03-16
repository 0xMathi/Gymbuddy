#!/bin/zsh
# Generates 20 AI exercise images via nano-banana (Gemini) → Assets.xcassets

ASSETS="/Users/mathias/GymBuddy/GymBuddy/Assets.xcassets"
BUN="$HOME/.bun/bin/bun"
CLI="$HOME/tools/nano-banana-2/src/cli.ts"
STYLE="Minimalist athletic silhouette illustration. Nearly black background. White light grey silhouette athlete. Bright orange #FF4F00 muscle highlight. No text no labels. Flat bold Nike poster aesthetic. Wide 16:9 format."

gen() {
  local name="$1"
  local prompt="$2"
  local dir="$ASSETS/${name}.imageset"
  mkdir -p "$dir"
  $BUN run $CLI "$prompt $STYLE" --aspect 16:9 --output "$name" --dir "$dir"
  # nano-banana saves as .png
  if [ -f "$dir/${name}.png" ]; then
    echo "  ✓ Saved"
  else
    echo "  ✗ Failed"
  fi
}

echo "Generating 20 exercise images via Gemini (nano-banana)..."
echo ""

gen "exercise_bankdruecken" "Male athlete performing barbell bench press lying on bench side view. Chest pectoral muscles highlighted orange."
gen "exercise_schraegbankdruecken" "Male athlete performing incline barbell bench press side view. Upper chest muscles highlighted orange."
gen "exercise_kurzhantel_flys" "Male athlete performing dumbbell chest fly lying on bench arms wide open. Chest muscles highlighted orange."
gen "exercise_schulterdruecken" "Male athlete performing overhead barbell shoulder press standing side view. Shoulder deltoid muscles highlighted orange."
gen "exercise_seitheben" "Male athlete performing lateral raises with dumbbells arms raised to sides front view. Side deltoid muscles highlighted orange."
gen "exercise_trizepsdruecken_am_kabel" "Male athlete performing cable triceps pushdown side view elbows tucked. Triceps muscles highlighted orange."
gen "exercise_skull_crushers" "Male athlete performing skull crushers lying triceps extension on bench side view. Triceps muscles highlighted orange."
gen "exercise_kreuzheben" "Male athlete performing deadlift with barbell side view hinging from hips. Lower back and hamstring muscles highlighted orange."
gen "exercise_klimmzuege" "Male athlete performing pull-ups on bar front view chin above bar arms overhead. Latissimus dorsi back muscles highlighted orange."
gen "exercise_langhantel_rudern" "Male athlete performing bent-over barbell row side view torso parallel to ground. Upper back muscles highlighted orange."
gen "exercise_kabelrudern" "Male athlete performing seated cable row side view pulling handles to torso. Mid-back muscles highlighted orange."
gen "exercise_face_pulls" "Male athlete performing face pull cable exercise side view arms pulling rope toward face elbows flared. Rear deltoid muscles highlighted orange."
gen "exercise_langhantel_curls" "Male athlete performing standing barbell bicep curl side view arms curled up. Bicep muscles highlighted orange."
gen "exercise_hammer_curls" "Male athlete performing hammer curls with dumbbells side view neutral grip. Bicep brachialis muscles highlighted orange."
gen "exercise_kniebeugen" "Male athlete performing barbell back squat side view in deep squat position. Quadriceps thigh muscles highlighted orange."
gen "exercise_rumaenisches_kreuzheben" "Male athlete performing Romanian deadlift barbell side view hinging at hips legs slightly bent. Hamstring muscles highlighted orange."
gen "exercise_beinpresse" "Male athlete performing leg press machine side view seated legs pushing platform. Quadriceps muscles highlighted orange."
gen "exercise_beinstrecker" "Male athlete performing leg extension machine seated side view legs fully extended. Quadriceps muscles highlighted orange."
gen "exercise_beinbeuger" "Male athlete performing lying leg curl machine side view face down curling legs toward glutes. Hamstring muscles highlighted orange."
gen "exercise_wadenheben_stehend" "Male athlete performing standing calf raise on step edge side view rising on tiptoes. Calf gastrocnemius muscles highlighted orange."

echo ""
echo "Done."
