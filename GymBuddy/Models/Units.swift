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

    /// Increment for pickers and quick-adjust buttons (2.5 kg / 5 lb).
    var step: Double { self == .kg ? 2.5 : 5 }
    var pickerMax: Double { self == .kg ? 300 : 660 }

    /// Default for new installs: imperial regions get lb.
    static var regionDefault: WeightUnit {
        let region = Locale.current.region?.identifier ?? ""
        return ["US", "LR", "MM", "GB"].contains(region) ? .lb : .kg
    }
}

/// Formats a stored-kg value in the active unit. Single place that decides rounding & label.
enum WeightDisplay {
    /// Numeric part only (no unit), rounded to the nearest 0.5. Empty string for 0.
    static func number(kg: Double, unit: WeightUnit = AppSettings.shared.weightUnit) -> String {
        guard kg > 0 else { return "" }
        let raw = unit.value(fromKg: kg)
        let rounded = (raw * 2).rounded() / 2
        return rounded.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(rounded))
            : String(format: "%.1f", rounded)
    }

    /// Full value with unit, e.g. "35 kg" / "75 LB". Returns "—" for 0.
    static func string(kg: Double, unit: WeightUnit = AppSettings.shared.weightUnit, uppercase: Bool = false) -> String {
        guard kg > 0 else { return "—" }
        let label = uppercase ? unit.labelUpper : unit.label
        return "\(number(kg: kg, unit: unit)) \(label)"
    }
}
