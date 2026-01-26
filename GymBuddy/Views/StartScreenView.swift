import SwiftUI
import SwiftData

/// Nike-inspired Start Screen with Hero Typography + Workout Plan Cards
struct StartScreenView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Query(sort: \WorkoutPlan.createdAt, order: .reverse) private var plans: [WorkoutPlan]

    @State private var isAnimating = false
    @State private var planToEdit: WorkoutPlan?
    @State private var showSettings = false

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
            .sheet(isPresented: $showSettings) {
                SettingsView()
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

                // Settings button
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(Theme.Colors.surface)
                        .cornerRadius(8)
                }

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

            // Plan Cards with Swipe-to-Delete
            List {
                ForEach(plans) { plan in
                    StartPlanCard(
                        plan: plan,
                        icon: iconFor(plan.name),
                        muscles: musclesFor(plan),
                        onTap: {
                            if plan.exercises.isEmpty {
                                // Open edit view for empty plans
                                planToEdit = plan
                            } else {
                                // Start workout directly
                                HapticService.shared.heavy()
                                sessionManager.startWorkout(plan: plan)
                            }
                        },
                        onEdit: {
                            planToEdit = plan
                        }
                    )
                    .listRowInsets(EdgeInsets(top: Theme.Spacing.small, leading: Theme.Spacing.xl, bottom: Theme.Spacing.small, trailing: Theme.Spacing.xl))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deletePlan(plan)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }

                // Large "+" Button for new plans
                Button(action: createNewPlan) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Theme.Colors.accent)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Theme.Colors.surfaceElevated.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                            )
                            .foregroundStyle(Theme.Colors.surfaceElevated)
                    )
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: Theme.Spacing.small, leading: Theme.Spacing.xl, bottom: Theme.Spacing.small, trailing: Theme.Spacing.xl))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
            .frame(minHeight: CGFloat(plans.count + 1) * 116)

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

    private func deletePlan(_ plan: WorkoutPlan) {
        HapticService.shared.medium()
        withAnimation {
            modelContext.delete(plan)
        }
    }
}

// MARK: - Plan Card Component

private struct StartPlanCard: View {
    let plan: WorkoutPlan
    let icon: String
    let muscles: String
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

                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(width: 100, height: 100)

                // Accent bar
                Rectangle()
                    .fill(Theme.Colors.surfaceElevated)
                    .frame(width: 2)

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
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StartScreenView()
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
        .environment(WorkoutSessionManager())
}
