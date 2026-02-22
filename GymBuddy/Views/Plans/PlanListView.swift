import SwiftUI
import SwiftData

struct PlanListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Query(sort: \WorkoutPlan.orderIndex, order: .forward) private var plans: [WorkoutPlan]

    @State private var planToEdit: WorkoutPlan?
    @State private var isEditMode: Bool = false

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
                ToolbarItem(placement: .topBarLeading) {
                    if !plans.isEmpty {
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                isEditMode.toggle()
                            }
                            HapticService.shared.light()
                        }) {
                            Text(isEditMode ? "Fertig" : "Sortieren")
                                .font(Theme.Fonts.body)
                                .foregroundStyle(Theme.Colors.accent)
                        }
                    }
                }
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
        List {
            ForEach(plans) { plan in
                PlanCard(
                    plan: plan,
                    isEditMode: isEditMode,
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
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onMove(perform: movePlans)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
    }

    // MARK: - Reorder

    private func movePlans(from source: IndexSet, to destination: Int) {
        // Create mutable copy
        var reorderedPlans = Array(plans)
        reorderedPlans.move(fromOffsets: source, toOffset: destination)

        // Update orderIndex for all plans in SwiftData
        for (index, plan) in reorderedPlans.enumerated() {
            plan.orderIndex = index
        }

        // Haptic feedback
        HapticService.shared.medium()

        do {
            try modelContext.save()
            print("Reordered plans saved successfully")
        } catch {
            print("Failed to save reordered plans: \(error)")
        }
    }

    // MARK: - Actions

    private func createNewPlan() {
        // New plans get the highest orderIndex (appear at the end)
        let maxOrderIndex = plans.map { $0.orderIndex }.max() ?? -1
        let newPlan = WorkoutPlan(name: "New Plan", orderIndex: maxOrderIndex + 1)
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
    var isEditMode: Bool = false
    let onStart: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Drag handle (visible in edit mode)
            if isEditMode {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .frame(width: 24)
            }

            // Main card content
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

                if !isEditMode {
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
                        Button(action: {
                            HapticService.shared.light()
                            onStart()
                        }) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.Colors.accent)
                                .frame(width: 36, height: 36)
                                .background(Theme.Colors.accentDim)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Theme.Spacing.large)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditMode {
                onStart()
            }
        }
        .contextMenu {
            if !isEditMode {
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
}

#Preview {
    PlanListView()
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
        .environment(WorkoutSessionManager())
        .environment(ExerciseManager())
}
