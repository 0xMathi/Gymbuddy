import SwiftUI
import SwiftData

struct PlanListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Query(sort: \WorkoutPlan.createdAt, order: .reverse) private var plans: [WorkoutPlan]

    @State private var planToEdit: WorkoutPlan?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.bg.ignoresSafeArea()

                if plans.isEmpty {
                    emptyStateView
                } else {
                    planListView
                }
            }
            .navigationTitle("GymBuddy")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: createNewPlan) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Theme.Colors.accent)
                    }
                }
            }
            .sheet(item: $planToEdit) { plan in
                PlanEditView(plan: plan)
            }
        }
    }

    // MARK: - Views

    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.Colors.surfaceElevated)
                .padding(.bottom, Theme.Spacing.medium)

            VStack(spacing: Theme.Spacing.small) {
                Text("Start Your Journey")
                    .font(Theme.Fonts.h2)
                    .foregroundStyle(Theme.Colors.textPrimary)

                Text("Create your first workout plan to get started.")
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            PrimaryButton(title: "Create Plan", icon: "plus") {
                createNewPlan()
            }
            .padding(.top, Theme.Spacing.xl)
        }
        .padding(.horizontal, Theme.Spacing.xl)
    }

    private var planListView: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.medium) {
                ForEach(plans) { plan in
                    PlanCard(
                        plan: plan,
                        onStart: {
                            if !plan.exercises.isEmpty {
                                sessionManager.startWorkout(plan: plan)
                            } else {
                                planToEdit = plan
                            }
                        },
                        onEdit: {
                            planToEdit = plan
                        },
                        onDelete: {
                            deletePlan(plan)
                        }
                    )
                }
            }
            .padding(Theme.Spacing.large)
        }
    }

    // MARK: - Actions

    private func createNewPlan() {
        let newPlan = WorkoutPlan(name: "New Plan")
        modelContext.insert(newPlan)

        // Small delay to ensure the plan is inserted before opening the editor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            planToEdit = newPlan
        }
    }

    private func deletePlan(_ plan: WorkoutPlan) {
        modelContext.delete(plan)
        try? modelContext.save()
    }
}

// MARK: - Plan Card Component

struct PlanCard: View {
    let plan: WorkoutPlan
    let onStart: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onStart) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(Theme.Fonts.h3)
                        .foregroundStyle(Theme.Colors.textPrimary)

                    if plan.exercises.isEmpty {
                        Text("Tap to add exercises")
                            .font(Theme.Fonts.caption)
                            .foregroundStyle(Theme.Colors.accent)
                    } else {
                        Text("\(plan.exercises.count) exercises")
                            .font(Theme.Fonts.body)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
                Spacer()

                // Edit Button
                Button(action: {
                    HapticService.shared.light()
                    onEdit()
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(Theme.Colors.surfaceElevated)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                // Play Button (only if has exercises)
                if !plan.exercises.isEmpty {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.Colors.accent)
                        .frame(width: 36, height: 36)
                        .background(Theme.Colors.accentDim)
                        .cornerRadius(8)
                }
            }
            .padding(Theme.Spacing.large)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit Plan", systemImage: "pencil")
            }

            Button(action: onStart) {
                Label("Start Workout", systemImage: "play.fill")
            }
            .disabled(plan.exercises.isEmpty)

            Divider()

            Button(role: .destructive, action: onDelete) {
                Label("Delete Plan", systemImage: "trash")
            }
        }
    }
}

#Preview {
    PlanListView()
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
        .environment(WorkoutSessionManager())
        .environment(ExerciseManager())
}
