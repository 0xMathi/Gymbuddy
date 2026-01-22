import SwiftUI
import SwiftData

struct PlanListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutPlan.createdAt, order: .reverse) private var plans: [WorkoutPlan]
    
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
                    PlanCard(plan: plan)
                }
            }
            .padding(Theme.Spacing.large)
        }
    }
    
    // MARK: - Actions
    
    private func createNewPlan() {
        let newPlan = WorkoutPlan(name: "New Plan")
        modelContext.insert(newPlan)
    }
}

// MARK: - Components

struct PlanCard: View {
    let plan: WorkoutPlan
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.name)
                    .font(Theme.Fonts.h3)
                    .foregroundStyle(Theme.Colors.textPrimary)
                
                if plan.exercises.isEmpty {
                    Text("No exercises")
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                } else {
                    Text("\(plan.exercises.count) exercises")
                        .font(Theme.Fonts.body)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.large)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
    }
}

#Preview {
    PlanListView()
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
}
