#!/usr/bin/swift
// Generates 20 stylistic exercise images using CoreGraphics.
// Dark (#0A0A0B) background, white silhouette body, orange (#FF4F00) muscle highlight.
// Output: 1024×576 PNG per exercise → Assets.xcassets imagesets

import Cocoa
import CoreGraphics

let ASSETS_DIR = "/Users/mathias/GymBuddy/GymBuddy/Assets.xcassets"
let WIDTH: CGFloat = 1024
let HEIGHT: CGFloat = 576

// MARK: - Color helpers
let bgColor = NSColor(red: 10/255, green: 10/255, blue: 11/255, alpha: 1)
let silhouetteColor = NSColor(red: 220/255, green: 220/255, blue: 225/255, alpha: 1)
let dimColor = NSColor(red: 80/255, green: 80/255, blue: 85/255, alpha: 1)
let orangeColor = NSColor(red: 255/255, green: 79/255, blue: 0/255, alpha: 1)
let orange2Color = NSColor(red: 255/255, green: 130/255, blue: 50/255, alpha: 0.6) // glow
let labelColor = NSColor(red: 255/255, green: 79/255, blue: 0/255, alpha: 1)
let subLabelColor = NSColor(red: 120/255, green: 120/255, blue: 130/255, alpha: 1)

// MARK: - Exercise data
struct ExerciseInfo {
    let assetName: String
    let displayName: String
    let muscleGroup: String
    let bodyDrawing: BodyDrawing
}

enum BodyDrawing {
    case benchPress
    case inclineBenchPress
    case dumbbellFly
    case shoulderPress
    case lateralRaise
    case tricepsPushdown
    case skullCrusher
    case deadlift
    case pullUp
    case bentOverRow
    case seatedCableRow
    case facePull
    case barbellCurl
    case hammerCurl
    case squat
    case romanianDeadlift
    case legPress
    case legExtension
    case legCurl
    case standingCalfRaise
}

let exercises: [ExerciseInfo] = [
    .init(assetName: "exercise_bankdruecken", displayName: "Bankdrücken", muscleGroup: "Brust", bodyDrawing: .benchPress),
    .init(assetName: "exercise_schraegbankdruecken", displayName: "Schrägbank\ndrücken", muscleGroup: "Brust (Oben)", bodyDrawing: .inclineBenchPress),
    .init(assetName: "exercise_kurzhantel_flys", displayName: "Kurzhantel-Flys", muscleGroup: "Brust", bodyDrawing: .dumbbellFly),
    .init(assetName: "exercise_schulterdruecken", displayName: "Schulterdrücken", muscleGroup: "Schultern", bodyDrawing: .shoulderPress),
    .init(assetName: "exercise_seitheben", displayName: "Seitheben", muscleGroup: "Seitliche Schulter", bodyDrawing: .lateralRaise),
    .init(assetName: "exercise_trizepsdruecken_am_kabel", displayName: "Trizepsdrücken", muscleGroup: "Trizeps", bodyDrawing: .tricepsPushdown),
    .init(assetName: "exercise_skull_crushers", displayName: "Skull Crushers", muscleGroup: "Trizeps", bodyDrawing: .skullCrusher),
    .init(assetName: "exercise_kreuzheben", displayName: "Kreuzheben", muscleGroup: "Rücken / Beine", bodyDrawing: .deadlift),
    .init(assetName: "exercise_klimmzuege", displayName: "Klimmzüge", muscleGroup: "Latissimus", bodyDrawing: .pullUp),
    .init(assetName: "exercise_langhantel_rudern", displayName: "Langhantel-Rudern", muscleGroup: "Rücken", bodyDrawing: .bentOverRow),
    .init(assetName: "exercise_kabelrudern", displayName: "Kabelrudern", muscleGroup: "Rücken", bodyDrawing: .seatedCableRow),
    .init(assetName: "exercise_face_pulls", displayName: "Face Pulls", muscleGroup: "Hintere Schulter", bodyDrawing: .facePull),
    .init(assetName: "exercise_langhantel_curls", displayName: "Langhantel-Curls", muscleGroup: "Bizeps", bodyDrawing: .barbellCurl),
    .init(assetName: "exercise_hammer_curls", displayName: "Hammer Curls", muscleGroup: "Bizeps", bodyDrawing: .hammerCurl),
    .init(assetName: "exercise_kniebeugen", displayName: "Kniebeugen", muscleGroup: "Quadrizeps", bodyDrawing: .squat),
    .init(assetName: "exercise_rumaenisches_kreuzheben", displayName: "Rumän. Kreuzheben", muscleGroup: "Hamstrings", bodyDrawing: .romanianDeadlift),
    .init(assetName: "exercise_beinpresse", displayName: "Beinpresse", muscleGroup: "Quadrizeps", bodyDrawing: .legPress),
    .init(assetName: "exercise_beinstrecker", displayName: "Beinstrecker", muscleGroup: "Quadrizeps", bodyDrawing: .legExtension),
    .init(assetName: "exercise_beinbeuger", displayName: "Beinbeuger", muscleGroup: "Hamstrings", bodyDrawing: .legCurl),
    .init(assetName: "exercise_wadenheben_stehend", displayName: "Wadenheben", muscleGroup: "Waden", bodyDrawing: .standingCalfRaise),
]

// MARK: - Drawing

func drawBackground(_ ctx: CGContext) {
    ctx.setFillColor(bgColor.cgColor)
    ctx.fill(CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT))

    // Subtle vignette
    let vignette = CGContext(data: nil, width: Int(WIDTH), height: Int(HEIGHT),
                             bitsPerComponent: 8, bytesPerRow: 0,
                             space: CGColorSpaceCreateDeviceRGB(),
                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    // Just a soft dark border using a radial gradient painted on top
    let center = CGPoint(x: WIDTH/2, y: HEIGHT/2)
    let colors = [NSColor.clear.cgColor, NSColor(white: 0, alpha: 0.5).cgColor] as CFArray
    let locs: [CGFloat] = [0.5, 1.0]
    let gSpace = CGColorSpaceCreateDeviceRGB()
    if let grad = CGGradient(colorsSpace: gSpace, colors: colors, locations: locs) {
        ctx.drawRadialGradient(grad,
            startCenter: center, startRadius: HEIGHT * 0.4,
            endCenter: center, endRadius: HEIGHT * 0.85,
            options: [])
    }
}

func drawText(_ ctx: CGContext, name: String, muscle: String) {
    // Right side text
    let nameFont = NSFont.systemFont(ofSize: 36, weight: .bold)
    let muscleFont = NSFont.systemFont(ofSize: 18, weight: .medium)
    let dividerFont = NSFont.systemFont(ofSize: 11, weight: .regular)

    let nameAttrs: [NSAttributedString.Key: Any] = [
        .font: nameFont,
        .foregroundColor: NSColor.white
    ]
    let muscleAttrs: [NSAttributedString.Key: Any] = [
        .font: muscleFont,
        .foregroundColor: orangeColor
    ]
    let divAttrs: [NSAttributedString.Key: Any] = [
        .font: dividerFont,
        .foregroundColor: subLabelColor
    ]

    let nameStr = NSAttributedString(string: name, attributes: nameAttrs)
    let muscleStr = NSAttributedString(string: muscle.uppercased(), attributes: muscleAttrs)
    let divStr = NSAttributedString(string: "— MUSKELN —", attributes: divAttrs)

    let rightX: CGFloat = WIDTH * 0.58
    let textWidth: CGFloat = WIDTH * 0.38

    // Draw muscle label
    let divSize = divStr.size()
    divStr.draw(in: CGRect(x: rightX, y: HEIGHT - 80, width: textWidth, height: 25))

    let muscleSize = muscleStr.size()
    muscleStr.draw(in: CGRect(x: rightX, y: HEIGHT - 120, width: textWidth, height: 35))

    // Draw name
    nameStr.draw(in: CGRect(x: rightX, y: HEIGHT - 185, width: textWidth, height: 80))

    // Orange accent line
    ctx.setFillColor(orangeColor.cgColor)
    ctx.fill(CGRect(x: rightX, y: HEIGHT - 88, width: 40, height: 2))
}

func drawLimb(_ ctx: CGContext, from: CGPoint, to: CGPoint, width: CGFloat, color: NSColor) {
    ctx.saveGState()
    ctx.setStrokeColor(color.cgColor)
    ctx.setLineWidth(width)
    ctx.setLineCap(.round)
    ctx.move(to: from)
    ctx.addLine(to: to)
    ctx.strokePath()
    ctx.restoreGState()
}

func drawCircle(_ ctx: CGContext, center: CGPoint, radius: CGFloat, color: NSColor) {
    ctx.setFillColor(color.cgColor)
    ctx.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius*2, height: radius*2))
}

func drawFigureParts(_ ctx: CGContext, parts: [(from: CGPoint, to: CGPoint, width: CGFloat, isHighlight: Bool)], headCenter: CGPoint) {
    // Draw dim parts first, then highlighted
    for (from, to, w, isHL) in parts where !isHL {
        drawLimb(ctx, from: from, to: to, width: w, color: silhouetteColor)
    }
    for (from, to, w, isHL) in parts where isHL {
        drawLimb(ctx, from: from, to: to, width: w, color: orangeColor)
    }
    drawCircle(ctx, center: headCenter, radius: 22, color: silhouetteColor)
}

// MARK: - Body Poses

// Coordinate system: origin (0,0) at bottom-left, (1024,576) top-right
// Figures drawn in center-left area roughly 40-55% of width

func poseCenter() -> CGPoint { CGPoint(x: 360, y: 288) }

func drawExercise(_ ctx: CGContext, type: BodyDrawing) {
    let cx = poseCenter().x
    let cy = poseCenter().y

    switch type {

    case .benchPress:
        // Athlete lying on back, arms pushing up
        // Torso horizontal
        let shoulderL = CGPoint(x: cx - 70, y: cy + 30)
        let shoulderR = CGPoint(x: cx + 70, y: cy + 30)
        let hip = CGPoint(x: cx, y: cy - 20)
        let head = CGPoint(x: cx + 100, y: cy + 50)

        let armEndL = CGPoint(x: cx - 55, y: cy + 120)
        let armEndR = CGPoint(x: cx + 55, y: cy + 120)
        let kneeL = CGPoint(x: cx - 40, y: cy - 90)
        let kneeR = CGPoint(x: cx + 40, y: cy - 90)
        let footL = CGPoint(x: cx - 30, y: cy - 160)
        let footR = CGPoint(x: cx + 30, y: cy - 160)

        // Bench
        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(8)
        ctx.move(to: CGPoint(x: cx - 120, y: cy))
        ctx.addLine(to: CGPoint(x: cx + 120, y: cy))
        ctx.strokePath()

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulderL, shoulderR, 28, true),    // chest highlighted
            (shoulderL, hip, 22, false),
            (shoulderR, hip, 22, false),
            (shoulderL, armEndL, 16, true),
            (shoulderR, armEndR, 16, true),
            (hip, kneeL, 18, false),
            (hip, kneeR, 18, false),
            (kneeL, footL, 16, false),
            (kneeR, footR, 16, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

        // Barbell
        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(5)
        ctx.move(to: CGPoint(x: cx - 90, y: cy + 120))
        ctx.addLine(to: CGPoint(x: cx + 90, y: cy + 120))
        ctx.strokePath()

    case .inclineBenchPress:
        // Incline ~30°, seated-ish leaning back
        let shoulderL = CGPoint(x: cx - 40, y: cy + 50)
        let shoulderR = CGPoint(x: cx + 10, y: cy + 70)
        let hip = CGPoint(x: cx - 20, y: cy - 40)
        let head = CGPoint(x: cx + 60, y: cy + 110)
        let armEndL = CGPoint(x: cx - 50, y: cy + 150)
        let armEndR = CGPoint(x: cx + 20, y: cy + 160)
        let kneeL = CGPoint(x: cx - 55, y: cy - 120)
        let footL = CGPoint(x: cx - 40, y: cy - 200)

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulderL, shoulderR, 28, true),
            (shoulderL, hip, 22, false),
            (shoulderL, armEndL, 16, true),
            (shoulderR, armEndR, 16, true),
            (hip, kneeL, 18, false),
            (kneeL, footL, 16, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

        // Barbell
        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(5)
        ctx.move(to: CGPoint(x: cx - 90, y: cy + 155))
        ctx.addLine(to: CGPoint(x: cx + 90, y: cy + 155))
        ctx.strokePath()

    case .dumbbellFly:
        // Lying, arms wide open
        let shoulderL = CGPoint(x: cx - 60, y: cy + 30)
        let shoulderR = CGPoint(x: cx + 60, y: cy + 30)
        let hip = CGPoint(x: cx, y: cy - 20)
        let head = CGPoint(x: cx + 100, y: cy + 50)
        let armEndL = CGPoint(x: cx - 140, y: cy + 60)
        let armEndR = CGPoint(x: cx + 140, y: cy + 60)
        let kneeL = CGPoint(x: cx - 30, y: cy - 90)
        let kneeR = CGPoint(x: cx + 30, y: cy - 90)

        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(8)
        ctx.move(to: CGPoint(x: cx - 120, y: cy))
        ctx.addLine(to: CGPoint(x: cx + 120, y: cy))
        ctx.strokePath()

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulderL, shoulderR, 26, true),
            (shoulderL, hip, 20, false),
            (shoulderR, hip, 20, false),
            (shoulderL, armEndL, 15, true),
            (shoulderR, armEndR, 15, true),
            (hip, kneeL, 18, false),
            (hip, kneeR, 18, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .shoulderPress:
        // Standing, arms raised overhead
        let hip = CGPoint(x: cx, y: cy - 60)
        let shoulder = CGPoint(x: cx, y: cy + 60)
        let head = CGPoint(x: cx, y: cy + 130)
        let elbowL = CGPoint(x: cx - 60, y: cy + 70)
        let elbowR = CGPoint(x: cx + 60, y: cy + 70)
        let handL = CGPoint(x: cx - 50, y: cy + 160)
        let handR = CGPoint(x: cx + 50, y: cy + 160)
        let kneeL = CGPoint(x: cx - 20, y: cy - 150)
        let kneeR = CGPoint(x: cx + 20, y: cy - 150)
        let footL = CGPoint(x: cx - 25, y: cy - 230)
        let footR = CGPoint(x: cx + 25, y: cy - 230)

        // Barbell
        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(5)
        ctx.move(to: CGPoint(x: cx - 90, y: cy + 155))
        ctx.addLine(to: CGPoint(x: cx + 90, y: cy + 155))
        ctx.strokePath()

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, elbowL, 16, true),
            (shoulder, elbowR, 16, true),
            (elbowL, handL, 14, true),
            (elbowR, handR, 14, true),
            (hip, kneeL, 18, false),
            (hip, kneeR, 18, false),
            (kneeL, footL, 16, false),
            (kneeR, footR, 16, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .lateralRaise:
        // Standing, arms raised to sides at shoulder height
        let hip = CGPoint(x: cx, y: cy - 60)
        let shoulder = CGPoint(x: cx, y: cy + 60)
        let head = CGPoint(x: cx, y: cy + 130)
        let armEndL = CGPoint(x: cx - 130, y: cy + 60)
        let armEndR = CGPoint(x: cx + 130, y: cy + 60)
        let kneeL = CGPoint(x: cx - 20, y: cy - 150)
        let kneeR = CGPoint(x: cx + 20, y: cy - 150)
        let footL = CGPoint(x: cx - 25, y: cy - 230)
        let footR = CGPoint(x: cx + 25, y: cy - 230)

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, armEndL, 15, true),
            (shoulder, armEndR, 15, true),
            (hip, kneeL, 18, false),
            (hip, kneeR, 18, false),
            (kneeL, footL, 16, false),
            (kneeR, footR, 16, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .tricepsPushdown:
        // Standing at cable machine, arms down pushing
        let hip = CGPoint(x: cx, y: cy - 50)
        let shoulder = CGPoint(x: cx, y: cy + 60)
        let head = CGPoint(x: cx + 10, y: cy + 130)
        let elbowL = CGPoint(x: cx - 30, y: cy + 55)
        let elbowR = CGPoint(x: cx + 30, y: cy + 55)
        let handL = CGPoint(x: cx - 35, y: cy - 30)
        let handR = CGPoint(x: cx + 35, y: cy - 30)
        let kneeL = CGPoint(x: cx - 20, y: cy - 140)
        let kneeR = CGPoint(x: cx + 20, y: cy - 140)
        let footL = CGPoint(x: cx - 30, y: cy - 220)
        let footR = CGPoint(x: cx + 20, y: cy - 220)

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, elbowL, 15, false),
            (shoulder, elbowR, 15, false),
            (elbowL, handL, 14, true),  // triceps
            (elbowR, handR, 14, true),
            (hip, kneeL, 18, false),
            (hip, kneeR, 18, false),
            (kneeL, footL, 16, false),
            (kneeR, footR, 16, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .skullCrusher:
        // Lying on bench, arms raised then bent at elbow
        let shoulderL = CGPoint(x: cx - 50, y: cy + 30)
        let shoulderR = CGPoint(x: cx + 50, y: cy + 30)
        let hip = CGPoint(x: cx, y: cy - 20)
        let head = CGPoint(x: cx + 90, y: cy + 50)
        let elbowL = CGPoint(x: cx - 45, y: cy + 110)
        let elbowR = CGPoint(x: cx + 45, y: cy + 110)
        let handL = CGPoint(x: cx - 35, y: cy + 60)
        let handR = CGPoint(x: cx + 35, y: cy + 60)
        let kneeL = CGPoint(x: cx - 35, y: cy - 90)
        let kneeR = CGPoint(x: cx + 35, y: cy - 90)

        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(8)
        ctx.move(to: CGPoint(x: cx - 120, y: cy))
        ctx.addLine(to: CGPoint(x: cx + 120, y: cy))
        ctx.strokePath()

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulderL, shoulderR, 24, false),
            (shoulderL, hip, 20, false),
            (shoulderR, hip, 20, false),
            (shoulderL, elbowL, 15, false),
            (shoulderR, elbowR, 15, false),
            (elbowL, handL, 14, true),   // triceps extension
            (elbowR, handR, 14, true),
            (hip, kneeL, 18, false),
            (hip, kneeR, 18, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .deadlift:
        // Hinge at hips, back parallel-ish to ground, barbell hanging
        let hip = CGPoint(x: cx - 20, y: cy + 20)
        let shoulder = CGPoint(x: cx + 60, y: cy + 80)
        let head = CGPoint(x: cx + 100, y: cy + 120)
        let handL = CGPoint(x: cx - 30, y: cy - 50)
        let handR = CGPoint(x: cx + 10, y: cy - 50)
        let kneeL = CGPoint(x: cx - 40, y: cy - 70)
        let kneeR = CGPoint(x: cx + 0, y: cy - 70)
        let footL = CGPoint(x: cx - 50, y: cy - 160)
        let footR = CGPoint(x: cx + 10, y: cy - 160)

        // Barbell
        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(6)
        ctx.move(to: CGPoint(x: cx - 90, y: cy - 50))
        ctx.addLine(to: CGPoint(x: cx + 70, y: cy - 50))
        ctx.strokePath()

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 26, true),   // back highlighted
            (shoulder, handL, 14, false),
            (shoulder, handR, 14, false),
            (hip, kneeL, 20, true),      // lower back/glutes
            (hip, kneeR, 20, true),
            (kneeL, footL, 18, false),
            (kneeR, footR, 18, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .pullUp:
        // Arms overhead gripping bar, body hanging
        let hip = CGPoint(x: cx, y: cy - 50)
        let shoulder = CGPoint(x: cx, y: cy + 80)
        let head = CGPoint(x: cx, y: cy + 150)
        let elbowL = CGPoint(x: cx - 60, y: cy + 140)
        let elbowR = CGPoint(x: cx + 60, y: cy + 140)
        let handL = CGPoint(x: cx - 65, y: cy + 200)
        let handR = CGPoint(x: cx + 65, y: cy + 200)
        let kneeL = CGPoint(x: cx - 15, y: cy - 140)
        let kneeR = CGPoint(x: cx + 15, y: cy - 140)
        let footL = CGPoint(x: cx - 15, y: cy - 220)
        let footR = CGPoint(x: cx + 15, y: cy - 220)

        // Bar
        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(8)
        ctx.move(to: CGPoint(x: cx - 100, y: cy + 205))
        ctx.addLine(to: CGPoint(x: cx + 100, y: cy + 205))
        ctx.strokePath()

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 26, true),   // lats
            (shoulder, elbowL, 16, true),
            (shoulder, elbowR, 16, true),
            (elbowL, handL, 14, false),
            (elbowR, handR, 14, false),
            (hip, kneeL, 18, false),
            (hip, kneeR, 18, false),
            (kneeL, footL, 16, false),
            (kneeR, footR, 16, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .bentOverRow:
        // Torso ~45° forward, arms pulling bar up
        let hip = CGPoint(x: cx - 10, y: cy + 10)
        let shoulder = CGPoint(x: cx + 50, y: cy + 70)
        let head = CGPoint(x: cx + 80, y: cy + 120)
        let handL = CGPoint(x: cx - 30, y: cy - 20)
        let handR = CGPoint(x: cx + 20, y: cy - 20)
        let elbowL = CGPoint(x: cx - 10, y: cy + 40)
        let elbowR = CGPoint(x: cx + 40, y: cy + 40)
        let kneeL = CGPoint(x: cx - 30, y: cy - 80)
        let kneeR = CGPoint(x: cx + 20, y: cy - 80)
        let footL = CGPoint(x: cx - 45, y: cy - 170)
        let footR = CGPoint(x: cx + 15, y: cy - 170)

        // Barbell
        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(5)
        ctx.move(to: CGPoint(x: cx - 80, y: cy - 25))
        ctx.addLine(to: CGPoint(x: cx + 60, y: cy - 25))
        ctx.strokePath()

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 26, true),   // back
            (shoulder, elbowL, 15, false),
            (shoulder, elbowR, 15, false),
            (elbowL, handL, 14, true),
            (elbowR, handR, 14, true),
            (hip, kneeL, 20, false),
            (hip, kneeR, 20, false),
            (kneeL, footL, 18, false),
            (kneeR, footR, 18, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .seatedCableRow:
        // Seated, torso upright, arms pulling handles
        let hip = CGPoint(x: cx - 20, y: cy - 30)
        let shoulder = CGPoint(x: cx - 20, y: cy + 80)
        let head = CGPoint(x: cx - 20, y: cy + 150)
        let elbowL = CGPoint(x: cx - 70, y: cy + 75)
        let elbowR = CGPoint(x: cx + 30, y: cy + 75)
        let handL = CGPoint(x: cx - 70, y: cy + 10)
        let handR = CGPoint(x: cx + 60, y: cy + 10)
        let kneeL = CGPoint(x: cx - 80, y: cy - 110)
        let kneeR = CGPoint(x: cx + 40, y: cy - 110)
        let footL = CGPoint(x: cx - 100, y: cy - 110)
        let footR = CGPoint(x: cx + 90, y: cy - 110)

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 26, true),
            (shoulder, elbowL, 15, false),
            (shoulder, elbowR, 15, false),
            (elbowL, handL, 14, true),
            (elbowR, handR, 14, true),
            (hip, kneeL, 20, false),
            (hip, kneeR, 20, false),
            (kneeL, footL, 16, false),
            (kneeR, footR, 16, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .facePull:
        // Standing, arms raised pulling rope to face
        let hip = CGPoint(x: cx, y: cy - 50)
        let shoulder = CGPoint(x: cx, y: cy + 60)
        let head = CGPoint(x: cx, y: cy + 130)
        let elbowL = CGPoint(x: cx - 75, y: cy + 90)
        let elbowR = CGPoint(x: cx + 75, y: cy + 90)
        let handL = CGPoint(x: cx - 45, y: cy + 120)
        let handR = CGPoint(x: cx + 45, y: cy + 120)
        let kneeL = CGPoint(x: cx - 20, y: cy - 140)
        let kneeR = CGPoint(x: cx + 20, y: cy - 140)
        let footL = CGPoint(x: cx - 25, y: cy - 220)
        let footR = CGPoint(x: cx + 25, y: cy - 220)

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, elbowL, 16, true),  // rear delts
            (shoulder, elbowR, 16, true),
            (elbowL, handL, 14, true),
            (elbowR, handR, 14, true),
            (hip, kneeL, 18, false),
            (hip, kneeR, 18, false),
            (kneeL, footL, 16, false),
            (kneeR, footR, 16, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .barbellCurl:
        // Standing, arms curled up with barbell
        let hip = CGPoint(x: cx, y: cy - 50)
        let shoulder = CGPoint(x: cx, y: cy + 60)
        let head = CGPoint(x: cx, y: cy + 130)
        let elbowL = CGPoint(x: cx - 35, y: cy + 55)
        let elbowR = CGPoint(x: cx + 35, y: cy + 55)
        let handL = CGPoint(x: cx - 40, y: cy + 20)
        let handR = CGPoint(x: cx + 40, y: cy + 20)
        let kneeL = CGPoint(x: cx - 20, y: cy - 140)
        let kneeR = CGPoint(x: cx + 20, y: cy - 140)
        let footL = CGPoint(x: cx - 25, y: cy - 220)
        let footR = CGPoint(x: cx + 25, y: cy - 220)

        // Barbell
        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(5)
        ctx.move(to: CGPoint(x: cx - 90, y: cy + 18))
        ctx.addLine(to: CGPoint(x: cx + 90, y: cy + 18))
        ctx.strokePath()

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, elbowL, 15, false),
            (shoulder, elbowR, 15, false),
            (elbowL, handL, 14, true),   // biceps
            (elbowR, handR, 14, true),
            (hip, kneeL, 18, false),
            (hip, kneeR, 18, false),
            (kneeL, footL, 16, false),
            (kneeR, footR, 16, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .hammerCurl:
        // Standing, one arm curled (neutral grip)
        let hip = CGPoint(x: cx, y: cy - 50)
        let shoulder = CGPoint(x: cx, y: cy + 60)
        let head = CGPoint(x: cx + 15, y: cy + 130)
        let elbowL = CGPoint(x: cx - 35, y: cy + 55)
        let elbowR = CGPoint(x: cx + 35, y: cy + 55)
        let handL = CGPoint(x: cx - 35, y: cy - 10)  // curled side
        let handR = CGPoint(x: cx + 38, y: cy + 55)   // hanging side
        let kneeL = CGPoint(x: cx - 20, y: cy - 140)
        let kneeR = CGPoint(x: cx + 20, y: cy - 140)
        let footL = CGPoint(x: cx - 25, y: cy - 220)
        let footR = CGPoint(x: cx + 25, y: cy - 220)

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, elbowL, 15, false),
            (shoulder, elbowR, 15, false),
            (elbowL, handL, 14, true),
            (elbowR, handR, 14, false),
            (hip, kneeL, 18, false),
            (hip, kneeR, 18, false),
            (kneeL, footL, 16, false),
            (kneeR, footR, 16, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .squat:
        // Deep squat position
        let hip = CGPoint(x: cx, y: cy + 10)
        let shoulder = CGPoint(x: cx, y: cy + 100)
        let head = CGPoint(x: cx + 5, y: cy + 165)
        let armL = CGPoint(x: cx - 55, y: cy + 80)
        let armR = CGPoint(x: cx + 55, y: cy + 80)
        let kneeL = CGPoint(x: cx - 70, y: cy - 40)
        let kneeR = CGPoint(x: cx + 70, y: cy - 40)
        let footL = CGPoint(x: cx - 60, y: cy - 130)
        let footR = CGPoint(x: cx + 60, y: cy - 130)

        // Barbell across shoulders
        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(5)
        ctx.move(to: CGPoint(x: cx - 100, y: cy + 100))
        ctx.addLine(to: CGPoint(x: cx + 100, y: cy + 100))
        ctx.strokePath()

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, armL, 15, false),
            (shoulder, armR, 15, false),
            (hip, kneeL, 22, true),   // quads
            (hip, kneeR, 22, true),
            (kneeL, footL, 20, true),
            (kneeR, footR, 20, true),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .romanianDeadlift:
        // Hip hinge, legs slightly bent, barbell hanging
        let hip = CGPoint(x: cx - 10, y: cy + 20)
        let shoulder = CGPoint(x: cx + 55, y: cy + 80)
        let head = CGPoint(x: cx + 85, y: cy + 130)
        let handL = CGPoint(x: cx - 25, y: cy - 50)
        let handR = CGPoint(x: cx + 20, y: cy - 50)
        let kneeL = CGPoint(x: cx - 25, y: cy - 90)
        let kneeR = CGPoint(x: cx + 20, y: cy - 90)
        let footL = CGPoint(x: cx - 30, y: cy - 170)
        let footR = CGPoint(x: cx + 25, y: cy - 170)

        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(5)
        ctx.move(to: CGPoint(x: cx - 90, y: cy - 52))
        ctx.addLine(to: CGPoint(x: cx + 70, y: cy - 52))
        ctx.strokePath()

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, handL, 14, false),
            (shoulder, handR, 14, false),
            (hip, kneeL, 22, true),   // hamstrings highlighted
            (hip, kneeR, 22, true),
            (kneeL, footL, 18, false),
            (kneeR, footR, 18, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .legPress:
        // Seated/reclined, legs pressing platform away
        let hip = CGPoint(x: cx + 30, y: cy - 20)
        let shoulder = CGPoint(x: cx + 60, y: cy + 70)
        let head = CGPoint(x: cx + 70, y: cy + 140)
        let kneeL = CGPoint(x: cx - 40, y: cy + 10)
        let kneeR = CGPoint(x: cx - 30, y: cy - 40)
        let footL = CGPoint(x: cx - 110, y: cy + 40)
        let footR = CGPoint(x: cx - 100, y: cy - 10)
        let armL = CGPoint(x: cx + 10, y: cy + 60)

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, armL, 14, false),
            (hip, kneeL, 22, true),   // quads
            (hip, kneeR, 22, true),
            (kneeL, footL, 20, true),
            (kneeR, footR, 20, true),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .legExtension:
        // Seated, lower leg extending forward
        let hip = CGPoint(x: cx - 10, y: cy - 10)
        let shoulder = CGPoint(x: cx - 10, y: cy + 90)
        let head = CGPoint(x: cx - 10, y: cy + 160)
        let kneeL = CGPoint(x: cx - 60, y: cy - 20)
        let kneeR = CGPoint(x: cx + 40, y: cy - 20)
        let footL = CGPoint(x: cx - 130, y: cy - 20)  // extended
        let footR = CGPoint(x: cx + 40, y: cy - 90)   // hanging
        let armL = CGPoint(x: cx - 65, y: cy + 80)
        let armR = CGPoint(x: cx + 45, y: cy + 80)

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, armL, 14, false),
            (shoulder, armR, 14, false),
            (hip, kneeL, 22, false),
            (hip, kneeR, 22, false),
            (kneeL, footL, 20, true),   // quad (extended leg)
            (kneeR, footR, 18, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .legCurl:
        // Lying face down, curling lower leg up
        let hip = CGPoint(x: cx, y: cy + 20)
        let shoulder = CGPoint(x: cx + 70, y: cy + 20)
        let head = CGPoint(x: cx + 120, y: cy + 30)
        let kneeL = CGPoint(x: cx - 50, y: cy + 20)
        let kneeR = CGPoint(x: cx - 30, y: cy + 20)
        let footL = CGPoint(x: cx - 70, y: cy + 80)   // curled up
        let footR = CGPoint(x: cx - 90, y: cy + 20)   // straight
        let armL = CGPoint(x: cx + 50, y: cy + 70)
        let armR = CGPoint(x: cx + 50, y: cy - 30)

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, armL, 14, false),
            (shoulder, armR, 14, false),
            (hip, kneeL, 22, false),
            (hip, kneeR, 22, false),
            (kneeL, footL, 20, true),   // hamstring (curled)
            (kneeR, footR, 18, false),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)

    case .standingCalfRaise:
        // Standing, risen on toes
        let hip = CGPoint(x: cx, y: cy - 40)
        let shoulder = CGPoint(x: cx, y: cy + 70)
        let head = CGPoint(x: cx, y: cy + 140)
        let armL = CGPoint(x: cx - 40, y: cy + 50)
        let armR = CGPoint(x: cx + 40, y: cy + 50)
        let kneeL = CGPoint(x: cx - 18, y: cy - 130)
        let kneeR = CGPoint(x: cx + 18, y: cy - 130)
        let ankleLow_L = CGPoint(x: cx - 18, y: cy - 200)
        let ankleLow_R = CGPoint(x: cx + 18, y: cy - 200)
        let footL = CGPoint(x: cx - 10, y: cy - 240)  // raised toes
        let footR = CGPoint(x: cx + 10, y: cy - 240)

        let parts: [(CGPoint, CGPoint, CGFloat, Bool)] = [
            (shoulder, hip, 24, false),
            (shoulder, armL, 14, false),
            (shoulder, armR, 14, false),
            (hip, kneeL, 20, false),
            (hip, kneeR, 20, false),
            (kneeL, ankleLow_L, 18, false),
            (kneeR, ankleLow_R, 18, false),
            (ankleLow_L, footL, 16, true),   // calves
            (ankleLow_R, footR, 16, true),
        ]
        drawFigureParts(ctx, parts: parts, headCenter: head)
    }
}

// MARK: - Render single image

func renderImage(exercise: ExerciseInfo) -> NSImage? {
    guard let ctx = CGContext(
        data: nil,
        width: Int(WIDTH),
        height: Int(HEIGHT),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    // Flip coordinate system so (0,0) is bottom-left
    ctx.translateBy(x: 0, y: HEIGHT)
    ctx.scaleBy(x: 1, y: -1)

    // Draw background
    drawBackground(ctx)

    // Draw figure
    drawExercise(ctx, type: exercise.bodyDrawing)

    // Draw text labels
    // Flip back for text rendering
    ctx.translateBy(x: 0, y: HEIGHT)
    ctx.scaleBy(x: 1, y: -1)

    drawText(ctx, name: exercise.displayName, muscle: exercise.muscleGroup)

    guard let cgImage = ctx.makeImage() else { return nil }
    return NSImage(cgImage: cgImage, size: NSSize(width: WIDTH, height: HEIGHT))
}

// MARK: - Save to xcassets

func saveImageset(name: String, image: NSImage) -> Bool {
    let imagesetDir = "\(ASSETS_DIR)/\(name).imageset"

    // Create directory
    do {
        try FileManager.default.createDirectory(atPath: imagesetDir,
            withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("  Error creating dir: \(error)")
        return false
    }

    // Save PNG
    let pngPath = "\(imagesetDir)/\(name).png"
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("  Error creating PNG data")
        return false
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: pngPath))
    } catch {
        print("  Error writing PNG: \(error)")
        return false
    }

    // Save Contents.json
    let contentsJson = """
    {
      "images" : [
        {
          "filename" : "\(name).png",
          "idiom" : "universal",
          "scale" : "1x"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
    let jsonPath = "\(imagesetDir)/Contents.json"
    do {
        try contentsJson.write(toFile: jsonPath, atomically: true, encoding: .utf8)
    } catch {
        print("  Error writing Contents.json: \(error)")
        return false
    }

    return true
}

// MARK: - Main

print("GymBuddy Exercise Image Generator")
print("Generating \(exercises.count) images to \(ASSETS_DIR)\n")

var success = 0
var failed: [String] = []

for (i, exercise) in exercises.enumerated() {
    let idx = i + 1
    print("[\(String(format: "%02d", idx))/\(exercises.count)] \(exercise.assetName)")

    if let image = renderImage(exercise: exercise) {
        if saveImageset(name: exercise.assetName, image: image) {
            success += 1
            print("  ✓ Saved")
        } else {
            failed.append(exercise.assetName)
            print("  ✗ Save failed")
        }
    } else {
        failed.append(exercise.assetName)
        print("  ✗ Render failed")
    }
}

print("\n" + String(repeating: "=", count: 60))
print("Done: \(success)/\(exercises.count) images generated")
if !failed.isEmpty {
    print("Failed: \(failed.joined(separator: ", "))")
}
