import Foundation

/// Weight unit for display & input. Storage is always kg (single source of truth);
/// these helpers convert to/from the user's chosen unit only at the UI boundary.
enum WeightUnit: String, CaseIterable, Identifiable {
    case kg
    case lb

    var id: String { rawValue }
    var label: String { self == .kg ? "kg" : "lb" }
    var labelUpper: String { label.uppercased() }

    static let kgPerLb = 0.45359237

    /// Stored kg → value in this unit.
    func value(fromKg kg: Double) -> Double { self == .kg ? kg : kg / Self.kgPerLb }
    /// Value in this unit → stored kg.
    func kg(fromValue v: Double) -> Double { self == .kg ? v : v * Self.kgPerLb }

    /// Increment for quick-adjust buttons (2.5 kg / 5 lb) — big, fast jumps.
    var step: Double { self == .kg ? 2.5 : 5 }
    /// Fine increment for weight wheels (1.25 kg / 2.5 lb) — micro-progression
    /// with fractional plates and cable stacks is gym reality.
    var pickerStep: Double { self == .kg ? 1.25 : 2.5 }
    var pickerMax: Double { self == .kg ? 300 : 660 }

    /// Wheel values in this unit on the fine grid, plus the current value when
    /// it sits off-grid (e.g. typed via keyboard) so the wheel can show it
    /// instead of silently snapping the stored weight.
    func wheelOptions(including currentKg: Double = 0) -> [Double] {
        var options = Array(stride(from: pickerStep, through: pickerMax, by: pickerStep))
        let current = value(fromKg: currentKg)
        if current > 0, !options.contains(where: { abs($0 - current) < 0.001 }) {
            options.append(current)
            options.sort()
        }
        return options
    }

    /// Default for new installs: imperial regions get lb.
    static var regionDefault: WeightUnit {
        let region = Locale.current.region?.identifier ?? ""
        return ["US", "LR", "MM", "GB"].contains(region) ? .lb : .kg
    }
}

/// Formats a stored-kg value in the active unit. Single place that decides rounding & label.
enum WeightDisplay {
    /// Numeric part only (no unit), rounded to the nearest 0.25 so fine wheel
    /// steps (31.25 kg) display exactly. Empty string for 0.
    static func number(kg: Double, unit: WeightUnit = AppSettings.shared.weightUnit) -> String {
        guard kg > 0 else { return "" }
        return trim(unit.value(fromKg: kg))
    }

    /// Formats a value that is already in the display unit: nearest 0.25,
    /// shortest form ("80", "32.5", "31.25"). Used for wheel option labels too.
    static func trim(_ value: Double) -> String {
        let rounded = (value * 4).rounded() / 4
        if rounded.truncatingRemainder(dividingBy: 1) == 0 { return String(Int(rounded)) }
        if (rounded * 10).truncatingRemainder(dividingBy: 1) == 0 { return String(format: "%.1f", rounded) }
        return String(format: "%.2f", rounded)
    }

    /// Full value with unit, e.g. "35 kg" / "75 LB". Returns "—" for 0.
    static func string(kg: Double, unit: WeightUnit = AppSettings.shared.weightUnit, uppercase: Bool = false) -> String {
        guard kg > 0 else { return "—" }
        let label = uppercase ? unit.labelUpper : unit.label
        return "\(number(kg: kg, unit: unit)) \(label)"
    }
}
