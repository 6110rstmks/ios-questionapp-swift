import SwiftUI

private let calendarDayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

private let calendarMonthLabelFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年 MM月"
    return formatter
}()

private let calendarMonthKeyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM"
    return formatter
}()

private func makeCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.firstWeekday = 1 // 日曜始まり
    return calendar
}

/// カテゴリ内の問題を、回答日のカレンダーから振り返って出題するビュー
struct SimpleDatePickerView: View {
    let category: Category
    @Environment(\.dismiss) private var dismiss
    @StateObject private var calendarService = CalendarService()

    @State private var currentDate = Date()
    @State private var questionCounts: [String: Int] = [:]
    @State private var isLoadingCounts = false
    @State private var selectedFilter: SolutionStatus? = .incorrect
    @State private var isMonthlyOpen = false

    @State private var practiceProblems: [Question] = []
    @State private var showPractice = false

    private let calendar = makeCalendar()

    private var filterValue: Int? {
        selectedFilter?.rawValue
    }

    // 表示している月のグリッド（前後月の余白日を含む）
    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else { return [] }
        let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: monthInterval.end) ?? monthInterval.start

        guard
            let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: lastDayOfMonth)
        else { return [] }

        var result: [Date] = []
        var date = firstWeek.start
        while date < lastWeek.end {
            result.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        return result
    }

    private var monthTotalCount: Int {
        days
            .filter { calendar.isDate($0, equalTo: currentDate, toGranularity: .month) }
            .reduce(0) { $0 + (questionCounts[calendarDayFormatter.string(from: $1)] ?? 0) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isMonthlyOpen {
                    CategoryMonthlyCountsPanel(category: category, calendarService: calendarService, selectedFilter: selectedFilter) { month in
                        currentDate = month
                        isMonthlyOpen = false
                    }
                } else {
                    calendarPanel
                }
            }
            .navigationTitle(calendarMonthLabelFormatter.string(from: currentDate))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            isMonthlyOpen.toggle()
                        }
                    } label: {
                        Image(systemName: isMonthlyOpen ? "calendar" : "chart.bar.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $showPractice) {
                if let first = practiceProblems.first {
                    QuestionPageView(
                        category: category,
                        subcategory: Subcategory(id: 0, name: "未設定", categoryId: category.id),
                        question: first,
                        allQuestions: practiceProblems
                    )
                }
            }
        }
        .task {
            await loadInitialMonth()
        }
        .onChange(of: currentDate) { _, _ in
            Task { await loadCounts() }
        }
        .onChange(of: selectedFilter) { _, _ in
            Task { await loadInitialMonth() }
        }
    }

    private var calendarPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // フィルター選択
                HStack(spacing: 12) {
                    FilterButton(title: "All", isSelected: selectedFilter == nil, color: .gray) {
                        selectedFilter = nil
                    }
                    FilterButton(title: "未正解", isSelected: selectedFilter == .incorrect, color: .red) {
                        selectedFilter = .incorrect
                    }
                    FilterButton(title: "保留", isSelected: selectedFilter == .temporary, color: .orange) {
                        selectedFilter = .temporary
                    }
                    FilterButton(title: "正解", isSelected: selectedFilter == .correct, color: .green) {
                        selectedFilter = .correct
                    }
                }

                // 今月の件数 + 出題ボタン
                HStack {
                    HStack(spacing: 0) {
                        Text("今月: ")
                            .foregroundStyle(.secondary)
                        Text("\(monthTotalCount)件")
                            .fontWeight(.bold)
                            .foregroundStyle(.indigo)
                    }
                    .font(.subheadline)

                    Spacer()

                    if isLoadingCounts {
                        ProgressView()
                    }
                }

                Button {
                    Task { await openPracticeForMonth() }
                } label: {
                    Text("今月を出題 (\(monthTotalCount)問)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(monthTotalCount > 0 ? Color.indigo : Color.gray.opacity(0.3))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(monthTotalCount == 0)

                // 月ナビゲーション
                HStack {
                    Button {
                        prevMonth()
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                    }

                    Spacer()

                    Text(calendarMonthLabelFormatter.string(from: currentDate))
                        .font(.headline)

                    Spacer()

                    Button {
                        nextMonth()
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title2)
                    }
                }

                // 曜日ヘッダー
                HStack(spacing: 4) {
                    ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { label in
                        Text(label)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                // 日付グリッド
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(days, id: \.self) { day in
                        dayCell(for: day)
                    }
                }
            }
            .padding()
        }
    }

    private func dayCell(for day: Date) -> some View {
        let dateStr = calendarDayFormatter.string(from: day)
        let count = questionCounts[dateStr] ?? 0
        let isCurrentMonth = calendar.isDate(day, equalTo: currentDate, toGranularity: .month)
        let isToday = calendar.isDateInToday(day)

        return Button {
            Task { await openPractice(forDay: day) }
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: day))")
                    .font(.caption)
                    .foregroundStyle(count > 0 ? .green : (isCurrentMonth ? .primary : .secondary))

                if count > 0 {
                    Text("\(count)件")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(isToday ? Color.blue : Color.clear)
            .foregroundStyle(isToday ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(count == 0)
    }

    private func prevMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }

    private func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }

    private func loadInitialMonth() async {
        if let latest = await calendarService.fetchLatestLastAnsweredDate(categoryId: category.id, isCorrect: filterValue),
           let date = calendarDayFormatter.date(from: latest) {
            currentDate = date
        }
        await loadCounts()
    }

    private func loadCounts() async {
        isLoadingCounts = true
        let daysArray = days.map { calendarDayFormatter.string(from: $0) }
        questionCounts = await calendarService.fetchQuestionCounts(categoryId: category.id, days: daysArray, isCorrect: filterValue)
        isLoadingCounts = false
    }

    private func openPractice(forDay day: Date) async {
        let dateStr = calendarDayFormatter.string(from: day)
        let problems = await calendarService.fetchProblems(categoryId: category.id, date: dateStr, isCorrect: filterValue)
        startPractice(with: problems)
    }

    private func openPracticeForMonth() async {
        let targetDays = days
            .filter { calendar.isDate($0, equalTo: currentDate, toGranularity: .month) }
            .filter { (questionCounts[calendarDayFormatter.string(from: $0)] ?? 0) > 0 }

        guard !targetDays.isEmpty else { return }

        let results = await withTaskGroup(of: [Question].self) { group in
            for day in targetDays {
                let dateStr = calendarDayFormatter.string(from: day)
                group.addTask {
                    await calendarService.fetchProblems(categoryId: category.id, date: dateStr, isCorrect: filterValue)
                }
            }
            var all: [Question] = []
            for await result in group {
                all.append(contentsOf: result)
            }
            return all
        }

        var seenIds = Set<Int>()
        let deduped = results.filter { seenIds.insert($0.id).inserted }
        startPractice(with: deduped)
    }

    private func startPractice(with problems: [Question]) {
        guard !problems.isEmpty else { return }
        practiceProblems = problems
        showPractice = true
    }
}

/// 月別の問題数を集計して一覧表示するパネル（最古の回答月〜今月）
private struct CategoryMonthlyCountsPanel: View {
    let category: Category
    @ObservedObject var calendarService: CalendarService
    let selectedFilter: SolutionStatus?
    let onSelectMonth: (Date) -> Void

    @State private var monthlyCounts: [MonthlyCount] = []
    @State private var isLoading = false

    private let calendar = makeCalendar()

    private var maxCount: Int {
        max(monthlyCounts.map(\.count).max() ?? 1, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.indigo)
                Text("月別 問題数")
                    .font(.headline)
                Text("(最古の回答月〜今月)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()

            Divider()

            if isLoading {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView("読み込み中...")
                    Spacer()
                }
                Spacer()
            } else if monthlyCounts.isEmpty {
                Spacer()
                Text("データがありません")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(monthlyCounts) { item in
                            Button {
                                onSelectMonth(item.month)
                            } label: {
                                HStack(spacing: 12) {
                                    Text(item.monthLabel)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 90, alignment: .leading)

                                    GeometryReader { geometry in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.2))
                                            .overlay(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.indigo)
                                                    .frame(width: geometry.size.width * CGFloat(item.count) / CGFloat(maxCount))
                                            }
                                    }
                                    .frame(height: 14)

                                    Text("\(item.count)件")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .frame(width: 44, alignment: .trailing)
                                }
                                .foregroundStyle(.primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .task(id: selectedFilter) {
            await load()
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        guard
            let oldestStr = await calendarService.fetchOldestLastAnsweredDate(categoryId: category.id, isCorrect: selectedFilter?.rawValue),
            let oldestDate = calendarDayFormatter.date(from: oldestStr),
            let startMonth = calendar.dateInterval(of: .month, for: oldestDate)?.start,
            let endMonth = calendar.dateInterval(of: .month, for: Date())?.start
        else {
            monthlyCounts = []
            return
        }

        var months: [Date] = []
        var cursor = startMonth
        while cursor <= endMonth {
            months.append(cursor)
            cursor = calendar.date(byAdding: .month, value: 1, to: cursor) ?? endMonth
        }

        let daysArray: [String] = months.flatMap { month -> [String] in
            guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
            let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? interval.start

            var result: [String] = []
            var day = interval.start
            while day <= lastDay {
                result.append(calendarDayFormatter.string(from: day))
                day = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            }
            return result
        }

        let dailyCounts = await calendarService.fetchQuestionCounts(
            categoryId: category.id,
            days: daysArray,
            isCorrect: selectedFilter?.rawValue
        )

        var monthTotals: [String: Int] = [:]
        for (dateStr, count) in dailyCounts {
            let monthKey = String(dateStr.prefix(7)) // "yyyy-MM"
            monthTotals[monthKey, default: 0] += count
        }

        monthlyCounts = months.reversed().map { month in
            let key = calendarMonthKeyFormatter.string(from: month)
            return MonthlyCount(
                month: month,
                monthLabel: calendarMonthLabelFormatter.string(from: month),
                count: monthTotals[key] ?? 0
            )
        }
    }
}

private struct MonthlyCount: Identifiable {
    let month: Date
    let monthLabel: String
    let count: Int

    var id: String { monthLabel }
}

#Preview {
    SimpleDatePickerView(
        category: Category(
            id: 1,
            name: "サンプルカテゴリ",
            userId: 1,
            isBlackListed: false,
            isPublic: true,
            questionCount: 10,
            incorrectedAnsweredQuestionCount: 3
        )
    )
}
