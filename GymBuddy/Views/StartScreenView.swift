import SwiftUI
import SwiftData

/// Compact editorial start screen: small hero, plans above the fold (Design Lab V1)
struct StartScreenView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Query(sort: \WorkoutPlan.orderIndex, order: .forward) private var plans: [WorkoutPlan]

    @State private var isAnimating = false
    @State private var planToEdit: WorkoutPlan?
    @State private var showSettings = false
    @State private var isEditMode = false

    // Map plan names to icons (fallback when no image asset exists)
    private func iconFor(_ name: String) -> String {
        let lowercased = name.lowercased()
        if lowercased.contains("push") || lowercased.contains("chest") || lowercased.contains("brust") {
            return "flame.fill"
        } else if lowercased.contains("pull") || lowercased.contains("back") || lowercased.contains("rücken") {
            return "arrow.down.to.line"
        } else if lowercased.contains("leg") || lowercased.contains("bein") {
            return "figure.run"
        } else if lowercased.contains("arm") {
            return "figure.arms.open"
        } else if lowercased.contains("shoulder") || lowercased.contains("schulter") {
            return "figure.boxing"
        }
        return "dumbbell.fill"
    }

    // Map plan names to image asset names (generated plan motifs, Phase 5)
    private func imageNameFor(_ name: String) -> String {
        let lowercased = name.lowercased()
        if lowercased.contains("push") { return "plan_push" }
        if lowercased.contains("pull") { return "plan_pull" }
        if lowercased.contains("leg") || lowercased.contains("bein") { return "plan_legs" }
        return "plan_default"
    }

    // Map plan names to muscle descriptions
    private func musclesFor(_ plan: WorkoutPlan) -> String {
        let lowercased = plan.name.lowercased()
        if lowercased.contains("push") {
            return "Brust · Schultern · Trizeps"
        } else if lowercased.contains("pull") {
            return "Rücken · Bizeps · Hintere Schulter"
        } else if lowercased.contains("leg") || lowercased.contains("bein") {
            return "Quads · Beinbizeps · Gesäß"
        }
        return "\(plan.exercises.count) Übungen"
    }

    var body: some View {
        NavigationStack {
            List {
                Group {
                    topBar
                    heroSection

                    if plans.isEmpty {
                        emptyStateSection
                    } else {
                        plansHeader

                        ForEach(plans) { plan in
                            planRow(plan)
                        }
                        .onMove(perform: movePlans)

                        addPlanRow
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .background(Theme.Colors.bg)
            .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    isAnimating = true
                }
            }
            .sheet(item: $planToEdit) { plan in
                PlanEditView(plan: plan)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Text("GYM")
                .font(.system(size: 11, weight: .black))
                .tracking(4)
                .foregroundStyle(Theme.Colors.accent)
            +
            Text("BUDDY")
                .font(.system(size: 11, weight: .black))
                .tracking(4)
                .foregroundStyle(.white)

            Spacer()

            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Theme.Colors.surface)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)

            Button(action: createNewPlan) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.Colors.accent)
                    .frame(width: 36, height: 36)
                    .background(Theme.Colors.surface)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .listRowInsets(EdgeInsets(top: Theme.Spacing.medium, leading: Theme.Spacing.large, bottom: 0, trailing: Theme.Spacing.large))
    }

    // MARK: - Compact Hero

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: -2) {
            Text("TIME TO")
                .font(Theme.Fonts.heroLine1)
                .tracking(-2)
                .foregroundStyle(.white.opacity(0.16))
                .offset(x: isAnimating ? 0 : -40)
                .opacity(isAnimating ? 1 : 0)

            Text("WORK.")
                .font(Theme.Fonts.heroLine2)
                .tracking(-2.5)
                .foregroundStyle(Theme.Colors.accent)
                .offset(x: isAnimating ? 0 : -60)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.1), value: isAnimating)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets(top: 72, leading: Theme.Spacing.large, bottom: 0, trailing: Theme.Spacing.large))
    }

    // MARK: - Plans Header

    private var plansHeader: some View {
        HStack(spacing: Theme.Spacing.small) {
            Rectangle()
                .fill(Theme.Colors.accent)
                .frame(width: 34, height: 3)

            Text("DEINE PLÄNE")
                .font(Theme.Fonts.kicker)
                .tracking(3)
                .foregroundStyle(.white)

            Spacer()

            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isEditMode.toggle()
                }
                HapticService.shared.light()
            }) {
                Text(isEditMode ? "FERTIG" : "SORTIEREN")
                    .font(Theme.Fonts.kicker)
                    .tracking(2)
                    .foregroundStyle(Theme.Colors.accent)
            }
            .buttonStyle(.plain)
        }
        .listRowInsets(EdgeInsets(top: 64, leading: Theme.Spacing.large, bottom: Theme.Spacing.medium, trailing: Theme.Spacing.large))
    }

    // MARK: - Plan Row

    private func planRow(_ plan: WorkoutPlan) -> some View {
        StartPlanCard(
            plan: plan,
            imageName: imageNameFor(plan.name),
            fallbackImageName: plan.exercises
                .sorted { $0.orderIndex < $1.orderIndex }
                .first(where: { UIImage(named: $0.imageName) != nil })?.imageName,
            icon: iconFor(plan.name),
            muscles: musclesFor(plan),
            onTap: {
                if !isEditMode {
                    if plan.exercises.isEmpty {
                        planToEdit = plan
                    } else {
                        HapticService.shared.heavy()
                        sessionManager.startWorkout(plan: plan)
                    }
                }
            }
        )
        .listRowInsets(EdgeInsets(top: Theme.Spacing.small, leading: Theme.Spacing.large, bottom: Theme.Spacing.small, trailing: Theme.Spacing.large))
        .swipeActions(edge: .trailing, allowsFullSwipe: !isEditMode) {
            if !isEditMode {
                Button(role: .destructive) {
                    deletePlan(plan)
                } label: {
                    Label("Löschen", systemImage: "trash.fill")
                }
            }
        }
        .contextMenu {
            Button {
                planToEdit = plan
            } label: {
                Label("Bearbeiten", systemImage: "pencil")
            }
            Button(role: .destructive) {
                deletePlan(plan)
            } label: {
                Label("Löschen", systemImage: "trash.fill")
            }
        }
    }

    // MARK: - Add Plan Row

    private var addPlanRow: some View {
        Button(action: createNewPlan) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.Colors.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                        .foregroundStyle(Theme.Colors.surfaceElevated)
                )
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: Theme.Spacing.xs, leading: Theme.Spacing.large, bottom: Theme.Spacing.xxl, trailing: Theme.Spacing.large))
    }

    // MARK: - Empty State

    private var emptyStateSection: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.Colors.surfaceElevated)

            VStack(spacing: Theme.Spacing.small) {
                Text("NO PLANS YET")
                    .font(.system(size: 24, weight: .black))
                    .tracking(2)
                    .foregroundStyle(.white)

                Text("Erstelle deinen ersten Trainingsplan")
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            Button(action: createNewPlan) {
                HStack(spacing: 12) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                    Text("PLAN ERSTELLEN")
                        .font(Theme.Fonts.label)
                        .tracking(2)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Layout.buttonHeight)
                .background(Theme.Colors.accent)
                .cornerRadius(Theme.Layout.buttonHeight / 2)
            }
            .buttonStyle(.plain)
        }
        .listRowInsets(EdgeInsets(top: Theme.Spacing.xxxl, leading: Theme.Spacing.xl, bottom: Theme.Spacing.xxxl, trailing: Theme.Spacing.xl))
    }

    // MARK: - Actions

    private func createNewPlan() {
        let maxOrderIndex = plans.map { $0.orderIndex }.max() ?? -1
        let newPlan = WorkoutPlan(name: "Neuer Plan", orderIndex: maxOrderIndex + 1)
        modelContext.insert(newPlan)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            planToEdit = newPlan
        }
    }

    private func deletePlan(_ plan: WorkoutPlan) {
        HapticService.shared.medium()
        withAnimation {
            modelContext.delete(plan)
        }
    }

    private func movePlans(from source: IndexSet, to destination: Int) {
        var reorderedPlans = Array(plans)
        reorderedPlans.move(fromOffsets: source, toOffset: destination)

        for (index, plan) in reorderedPlans.enumerated() {
            plan.orderIndex = index
        }

        HapticService.shared.medium()

        do {
            try modelContext.save()
        } catch {
            print("Failed to save reordered plans: \(error)")
        }
    }
}

// MARK: - Plan Card Component

private struct StartPlanCard: View {
    let plan: WorkoutPlan
    let imageName: String
    var fallbackImageName: String? = nil
    let icon: String
    let muscles: String
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticService.shared.medium()
            onTap()
        }) {
            HStack(spacing: Theme.Spacing.medium) {
                // Image thumbnail with SF Symbol fallback
                ZStack {
                    Rectangle()
                        .fill(Theme.Colors.surfaceElevated)

                    if let image = UIImage(named: imageName) ?? fallbackImageName.flatMap(UIImage.init(named:)) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .frame(width: 76, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusSmall))

                VStack(alignment: .leading, spacing: 5) {
                    Text(plan.name.uppercased())
                        .font(.system(size: 24, weight: .black))
                        .tracking(0.5)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.leading)

                    if !muscles.isEmpty {
                        Text(muscles.uppercased())
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(1.5)
                            .foregroundStyle(Theme.Colors.accent)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }

                    if let lastUsed = plan.lastUsedAt {
                        Text(relativeLabel(for: lastUsed))
                            .font(Theme.Fonts.ghostLabel)
                            .tracking(1)
                            .foregroundStyle(Theme.Colors.textSecondary.opacity(0.7))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .padding(.trailing, 6)
            }
            .padding(Theme.Spacing.medium)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(SquishableButtonStyle(isPressed: $isPressed))
    }

    private func relativeLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "ZULETZT · HEUTE"
        } else if calendar.isDateInYesterday(date) {
            return "ZULETZT · GESTERN"
        } else {
            let components = calendar.dateComponents([.day], from: date, to: Date())
            if let days = components.day, days > 0 {
                return days == 1 ? "ZULETZT · VOR 1 TAG" : "ZULETZT · VOR \(days) TAGEN"
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            return "ZULETZT · \(formatter.string(from: date))"
        }
    }
}

// Custom button style to capture the press state for scaling
struct SquishableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                isPressed = newValue
            }
    }
}

#Preview {
    StartScreenView()
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
        .environment(WorkoutSessionManager())
}
