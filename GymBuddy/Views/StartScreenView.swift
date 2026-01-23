import SwiftUI
import SwiftData

/// Nike-inspired Start Screen with Hero Typography + Workout Plan Cards
struct StartScreenView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Query(sort: \WorkoutPlan.createdAt, order: .reverse) private var plans: [WorkoutPlan]

    @State private var isAnimating = false
    @State private var selectedPlan: WorkoutPlan?
    @State private var planToEdit: WorkoutPlan?

    // Map plan names to icons (fallback to dumbbell)
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

    // Map plan names to muscle descriptions
    private func musclesFor(_ plan: WorkoutPlan) -> String {
        let lowercased = plan.name.lowercased()
        if lowercased.contains("push") {
            return "Chest + Shoulders + Triceps"
        } else if lowercased.contains("pull") {
            return "Back + Biceps + Rear Delts"
        } else if lowercased.contains("leg") || lowercased.contains("bein") {
            return "Quads + Hamstrings + Glutes"
        }
        return "\(plan.exercises.count) exercises"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection

                    if plans.isEmpty {
                        emptyStateSection
                    } else {
                        cardsSection
                    }
                }
            }
            .background(Theme.Colors.bg)
            .ignoresSafeArea(edges: .top)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    isAnimating = true
                }
            }
            .sheet(item: $planToEdit) { plan in
                PlanEditView(plan: plan)
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 0) {
            // Top bar
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

                // Add plan button
                Button(action: createNewPlan) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.Colors.accent)
                        .frame(width: 36, height: 36)
                        .background(Theme.Colors.surface)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, 60)

            Spacer()
                .frame(height: Theme.Spacing.xxxl)

            // Giant Typography
            VStack(alignment: .leading, spacing: -8) {
                Text("START")
                    .font(.system(size: 72, weight: .black))
                    .tracking(-3)
                    .foregroundStyle(.white.opacity(0.15))
                    .offset(x: isAnimating ? 0 : -40)
                    .opacity(isAnimating ? 1 : 0)

                Text("YOUR")
                    .font(.system(size: 90, weight: .black))
                    .tracking(-4)
                    .foregroundStyle(.white)
                    .offset(x: isAnimating ? 0 : -60)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: isAnimating)

                Text("WORK")
                    .font(.system(size: 90, weight: .black))
                    .tracking(-4)
                    .foregroundStyle(Theme.Colors.accent)
                    .offset(x: isAnimating ? 0 : -80)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)

                Text("OUT")
                    .font(.system(size: 90, weight: .black))
                    .tracking(-4)
                    .foregroundStyle(.white)
                    .offset(x: isAnimating ? 0 : -100)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.large)

            Spacer()
                .frame(height: Theme.Spacing.xxl)

            // Scroll indicator (only if there are plans)
            if !plans.isEmpty {
                VStack(spacing: Theme.Spacing.small) {
                    Text("SELECT YOUR PLAN")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(Theme.Colors.textSecondary)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.Colors.accent)
                        .offset(y: isAnimating ? 5 : 0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                }
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: isAnimating)
            }

            Spacer()
                .frame(height: Theme.Spacing.xxl)
        }
        .frame(minHeight: UIScreen.main.bounds.height * 0.7)
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

                Text("Create your first workout plan")
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            Button(action: createNewPlan) {
                HStack(spacing: 12) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                    Text("CREATE PLAN")
                        .font(.system(size: 14, weight: .black))
                        .tracking(2)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Theme.Colors.accent)
            }
            .padding(.horizontal, Theme.Spacing.xl)
        }
        .padding(.vertical, Theme.Spacing.xxxl)
    }

    // MARK: - Cards Section

    private var cardsSection: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                Rectangle()
                    .fill(Theme.Colors.accent)
                    .frame(width: 40, height: 3)

                Text("YOUR PLANS")
                    .font(.system(size: 12, weight: .black))
                    .tracking(3)
                    .foregroundStyle(.white)

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.bottom, Theme.Spacing.large)

            // Plan Cards
            VStack(spacing: Theme.Spacing.medium) {
                ForEach(plans) { plan in
                    StartPlanCard(
                        plan: plan,
                        icon: iconFor(plan.name),
                        muscles: musclesFor(plan),
                        isSelected: selectedPlan?.id == plan.id,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedPlan = plan
                            }
                        },
                        onEdit: {
                            planToEdit = plan
                        }
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.xl)

            Spacer()
                .frame(height: Theme.Spacing.xl)

            // Start Button
            if let plan = selectedPlan, !plan.exercises.isEmpty {
                Button(action: {
                    HapticService.shared.heavy()
                    sessionManager.startWorkout(plan: plan)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("START")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(2)

                            Text(plan.name.uppercased())
                                .font(.system(size: 24, weight: .black))
                                .tracking(-1)
                        }

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.system(size: 24, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Theme.Colors.accent)
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if let plan = selectedPlan, plan.exercises.isEmpty {
                Button(action: { planToEdit = plan }) {
                    HStack {
                        Text("ADD EXERCISES TO START")
                            .font(.system(size: 14, weight: .black))
                            .tracking(2)

                        Spacer()

                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundStyle(Theme.Colors.accent)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Theme.Colors.surface)
                    .overlay(
                        Rectangle()
                            .stroke(Theme.Colors.accent, lineWidth: 2)
                    )
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
                .frame(height: Theme.Spacing.xxxl)
        }
        .padding(.top, Theme.Spacing.large)
        .background(
            LinearGradient(
                colors: [Theme.Colors.bg, Theme.Colors.surface.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Actions

    private func createNewPlan() {
        let newPlan = WorkoutPlan(name: "New Plan")
        modelContext.insert(newPlan)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            planToEdit = newPlan
        }
    }
}

// MARK: - Plan Card Component

private struct StartPlanCard: View {
    let plan: WorkoutPlan
    let icon: String
    let muscles: String
    let isSelected: Bool
    let onTap: () -> Void
    let onEdit: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Image placeholder
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    if isSelected {
                        Theme.Colors.accent.opacity(0.5)
                            .transition(.opacity)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
                }
                .frame(width: 100, height: 100)

                // Accent bar
                Rectangle()
                    .fill(isSelected ? Theme.Colors.accent : Theme.Colors.surfaceElevated)
                    .frame(width: isSelected ? 4 : 2)
                    .animation(.spring(response: 0.3), value: isSelected)

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.exercises.isEmpty ? "NO EXERCISES" : "\(plan.exercises.count) EXERCISES")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(plan.exercises.isEmpty ? Theme.Colors.accent : Theme.Colors.textSecondary)

                    Text(plan.name.uppercased())
                        .font(.system(size: 28, weight: .black))
                        .tracking(-1)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(muscles)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .lineLimit(1)
                }
                .padding(.leading, Theme.Spacing.medium)

                Spacer()

                // Edit button
                Button(action: {
                    HapticService.shared.light()
                    onEdit()
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Theme.Colors.surfaceElevated)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .padding(.trailing, Theme.Spacing.medium)
            }
            .background(Theme.Colors.surface)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StartScreenView()
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
        .environment(WorkoutSessionManager())
}
