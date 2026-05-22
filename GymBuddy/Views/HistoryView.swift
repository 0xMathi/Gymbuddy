import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutHistoryEntry.startTime, order: .reverse) private var historyEntries: [WorkoutHistoryEntry]
    
    @State private var selectedEntry: WorkoutHistoryEntry?
    @State private var showingStats = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.bg.ignoresSafeArea()
                
                if historyEntries.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .navigationTitle("Historie")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingStats.toggle() }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Theme.Colors.accent)
                    }
                }
            }
            .sheet(item: $selectedEntry) { entry in
                HistoryDetailView(entry: entry)
            }
            .sheet(isPresented: $showingStats) {
                StatisticsView()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 64))
                .foregroundStyle(Theme.Colors.surfaceElevated)
                .padding(.bottom, Theme.Spacing.medium)
            
            VStack(spacing: Theme.Spacing.small) {
                Text("Noch keine Workouts")
                    .font(Theme.Fonts.h2)
                    .foregroundStyle(Theme.Colors.textPrimary)
                
                Text("Absolviere dein erstes Training und es wird hier angezeigt.")
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            PrimaryButton(title: "Training starten", icon: "play.fill") {
                // Navigate to start screen - handled by parent
            }
            .padding(.top, Theme.Spacing.xl)
        }
        .padding(.horizontal, Theme.Spacing.xl)
    }
    
    // MARK: - History List
    
    private var historyListView: some View {
        List {
            ForEach(historyEntries) { entry in
                HistoryRowView(entry: entry)
                    .onTapGesture {
                        selectedEntry = entry
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - History Row

struct HistoryRowView: View {
    let entry: WorkoutHistoryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.planName)
                        .font(Theme.Fonts.h3)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    
                    Text(entry.dateFormatted)
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(entry.durationFormatted)
                        .font(Theme.Fonts.bodyBold)
                        .foregroundStyle(Theme.Colors.accent)
                    
                    Text(entry.totalVolumeFormatted)
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }
            
            HStack(spacing: Theme.Spacing.medium) {
                Label("\(entry.totalSets) Sätze", systemImage: "checkmark.circle")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
                
                Label("\(entry.exercisesCompleted) Übungen", systemImage: "dumbbell")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .padding(Theme.Spacing.large)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
    }
}

// MARK: - History Detail View

struct HistoryDetailView: View {
    let entry: WorkoutHistoryEntry
    @Environment(\.dismiss) private var dismiss
    
    var exercises: [ExerciseSnapshot] {
        guard let data = entry.exerciseSnapshots else { return [] }
        return (try? JSONDecoder().decode([ExerciseSnapshot].self, from: data)) ?? []
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.bg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.large) {
                        // Summary Cards
                        summaryCardsSection
                        
                        // Exercise List
                        if !exercises.isEmpty {
                            exercisesSection
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.vertical, Theme.Spacing.medium)
                }
            }
            .navigationTitle(entry.planName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.Colors.accent)
                }
            }
        }
    }
    
    // MARK: - Summary Cards
    
    private var summaryCardsSection: some View {
        VStack(spacing: Theme.Spacing.medium) {
            HStack(spacing: Theme.Spacing.medium) {
                SummaryCard(
                    title: "Dauer",
                    value: entry.durationFormatted,
                    icon: "timer",
                    color: Theme.Colors.accent
                )
                
                SummaryCard(
                    title: "Volumen",
                    value: entry.totalVolumeFormatted,
                    icon: "scalemass",
                    color: Theme.Colors.accent
                )
            }
            
            HStack(spacing: Theme.Spacing.medium) {
                SummaryCard(
                    title: "Sätze",
                    value: "\(entry.totalSets)",
                    icon: "checkmark.circle",
                    color: Theme.Colors.accent
                )
                
                SummaryCard(
                    title: "Übungen",
                    value: "\(entry.exercisesCompleted)",
                    icon: "dumbbell",
                    color: Theme.Colors.accent
                )
            }
        }
    }
    
    // MARK: - Exercises Section
    
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text("ÜBUNGEN")
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
                .tracking(1)
            
            ForEach(exercises.indices, id: \.self) { index in
                let exercise = exercises[index]
                ExerciseHistoryRow(exercise: exercise, index: index + 1)
            }
        }
    }
}

// MARK: - Summary Card

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                Text(title)
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            
            Text(value)
                .font(Theme.Fonts.h2)
                .foregroundStyle(Theme.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.medium)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
    }
}

// MARK: - Exercise History Row

struct ExerciseHistoryRow: View {
    let exercise: ExerciseSnapshot
    let index: Int
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Text("\(index)")
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(Theme.Fonts.bodyBold)
                    .foregroundStyle(Theme.Colors.textPrimary)
                
                Text("\(exercise.sets) × \(exercise.reps) @ \(exercise.weightFormatted)")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            Text(exercise.muscleGroup)
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.accent)
                .padding(.horizontal, Theme.Spacing.small)
                .padding(.vertical, Theme.Spacing.xs)
                .background(Theme.Colors.accentDim)
                .cornerRadius(Theme.Layout.cornerRadiusSmall)
        }
        .padding(Theme.Spacing.medium)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
    }
}

// MARK: - Statistics View

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \WorkoutHistoryEntry.startTime, order: .reverse) private var historyEntries: [WorkoutHistoryEntry]
    
    var totalWorkouts: Int {
        historyEntries.count
    }
    
    var totalDuration: TimeInterval {
        historyEntries.reduce(0) { $0 + $1.duration }
    }
    
    var totalVolume: Double {
        historyEntries.reduce(0) { $0 + $1.totalVolume }
    }
    
    var averageDuration: TimeInterval {
        guard totalWorkouts > 0 else { return 0 }
        return totalDuration / Double(totalWorkouts)
    }
    
    var bestWorkout: WorkoutHistoryEntry? {
        historyEntries.max(by: { $0.totalVolume < $1.totalVolume })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.bg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.large) {
                        // Overview Stats
                        overviewStatsSection
                        
                        // Achievements
                        achievementsSection
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.vertical, Theme.Spacing.medium)
                }
            }
            .navigationTitle("Statistiken")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.Colors.accent)
                }
            }
        }
    }
    
    private var overviewStatsSection: some View {
        VStack(spacing: Theme.Spacing.medium) {
            StatBigCard(
                title: "Gesamte Workouts",
                value: "\(totalWorkouts)",
                subtitle: totalWorkouts > 0 ? "Weiter so! 🔥" : "Starte dein erstes Training"
            )
            
            HStack(spacing: Theme.Spacing.medium) {
                SummaryCard(
                    title: "Gesamtzeit",
                    value: formatTotalTime(totalDuration),
                    icon: "clock",
                    color: Theme.Colors.accent
                )
                
                SummaryCard(
                    title: "Ø Dauer",
                    value: formatTime(averageDuration),
                    icon: "timer",
                    color: Theme.Colors.accent
                )
            }
            
            SummaryCard(
                title: "Gesamtvolumen",
                value: totalVolumeFormatted,
                icon: "scalemass",
                color: Theme.Colors.accent
            )
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text("REKORDE")
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
                .tracking(1)
            
            if let best = bestWorkout {
                RecordCard(
                    title: "Höchstes Volumen",
                    value: best.totalVolumeFormatted,
                    planName: best.planName,
                    date: best.dateFormatted,
                    icon: "trophy.fill"
                )
            }
            
            if let longest = historyEntries.max(by: { $0.duration < $1.duration }) {
                RecordCard(
                    title: "Längstes Training",
                    value: longest.durationFormatted,
                    planName: longest.planName,
                    date: longest.dateFormatted,
                    icon: "timer"
                )
            }
        }
    }
    
    private var totalVolumeFormatted: String {
        let formatted = NumberFormatter.localizedString(from: NSNumber(value: totalVolume), number: .decimal)
        return "\(formatted) KG"
    }
    
    private func formatTotalTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        return "\(minutes)m"
    }
}

// MARK: - Stat Big Card

struct StatBigCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.small) {
            Text(title)
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
            
            Text(value)
                .font(.system(size: 48, weight: .black))
                .foregroundStyle(Theme.Colors.accent)
            
            Text(subtitle)
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xl)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
    }
}

// MARK: - Record Card

struct RecordCard: View {
    let title: String
    let value: String
    let planName: String
    let date: String
    let icon: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(Theme.Colors.accent)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
                
                Text(value)
                    .font(Theme.Fonts.h2)
                    .foregroundStyle(Theme.Colors.textPrimary)
                
                Text("\(planName) • \(date)")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.medium)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: WorkoutHistoryEntry.self, inMemory: true)
}
