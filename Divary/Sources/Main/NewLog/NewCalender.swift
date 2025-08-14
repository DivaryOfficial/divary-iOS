//
//  NewCalender.swift
//  Divary
//
//  Created by chohaeun on 8/5/25.
//

import SwiftUI

// MARK: - 메인 캘린더 뷰
struct NewCalenderView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    @State var startMonth: Date
    @State var endMonth: Date
    
    // 년월 선택 피커 관련 상태
    @State private var showDatePicker = false
    @State private var selectedYear: Int
    @State private var selectedMonthIndex: Int
    
    // 로그 데이터 관련 상태
    @State private var existingLogDates: Set<String> = []
    @State private var isLoadingLogs = false
    
    // 사용 가능한 년도와 월 범위
    private var availableYears: [Int] {
        let startYear = Calendar.current.component(.year, from: startMonth)
        let endYear = Calendar.current.component(.year, from: endMonth)
        return Array(startYear...endYear)
    }
    
    private let months = ["1월", "2월", "3월", "4월", "5월", "6월",
                         "7월", "8월", "9월", "10월", "11월", "12월"]

    init(currentMonth: Binding<Date>, selectedDate: Binding<Date>, startMonth: Date, endMonth: Date) {
        self._currentMonth = currentMonth
        self._selectedDate = selectedDate
        self._startMonth = State(initialValue: startMonth)
        self._endMonth = State(initialValue: endMonth)
        
        // 현재 월의 년도와 월로 초기화
        let calendar = Calendar.current
        self._selectedYear = State(initialValue: calendar.component(.year, from: currentMonth.wrappedValue))
        self._selectedMonthIndex = State(initialValue: calendar.component(.month, from: currentMonth.wrappedValue) - 1)
    }

    var body: some View {
        VStack {
            headerView
            Spacer().frame(height: 10)
            weekdayHeader
            calendarGrid
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            // 드롭다운 피커 오버레이
            Group {
                if showDatePicker {
                    datePickerOverlay
                }
            }
        )
        .opacity(isLoadingLogs ? 0.6 : 1.0)
        .overlay(
            Group {
                if isLoadingLogs {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.8))
                }
            }
        )
        .onAppear {
            loadExistingLogs()
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: { changeMonth(by: -1) }) {
                Image("chevron.left")
                    .frame(width: 24)
                    .foregroundStyle(Color.bw_black)
            }

            Spacer()

            HStack(spacing: 4) {
                Text(currentMonth, formatter: Self.dateFormatter)
                    .font(Font.omyu.regular(size: 20))

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDatePicker.toggle()
                    }
                }) {
                    Image("chevron.down")
                        .frame(width: 20)
                        .foregroundStyle(Color.bw_black)
                        .padding(.horizontal, 6)
                        .rotationEffect(.degrees(showDatePicker ? 180 : 0))
                }
            }

            Spacer()

            Button(action: { changeMonth(by: 1) }) {
                Image("chevron.right")
                    .foregroundStyle(Color.bw_black)
            }
        }
    }
    
    private var datePickerOverlay: some View {
        VStack(spacing: 0) {
            // 상단 여백 (헤더 아래에 위치하도록)
            Spacer().frame(height: 60)
            
            // 피커 컨테이너
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    // 년도 피커
                    VStack(spacing: 8) {
                        Text("년도")
                            .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                            .foregroundColor(.gray)
                        
                        Picker("년도", selection: $selectedYear) {
                            ForEach(availableYears, id: \.self) { year in
                                Text("\(String(year))년")
                                    .font(Font.omyu.regular(size: 16))
                                    .tag(year)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100, height: 120)
                        .clipped()
                    }
                    
                    // 월 피커
                    VStack(spacing: 8) {
                        Text("월")
                            .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                            .foregroundColor(.gray)
                        
                        Picker("월", selection: $selectedMonthIndex) {
                            ForEach(0..<12, id: \.self) { index in
                                Text(months[index])
                                    .font(Font.omyu.regular(size: 16))
                                    .tag(index)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80, height: 120)
                        .clipped()
                    }
                }
                
                // 확인/취소 버튼
                HStack(spacing: 12) {
                    Button("취소") {
                        // 원래 값으로 복원
                        let calendar = Calendar.current
                        selectedYear = calendar.component(.year, from: currentMonth)
                        selectedMonthIndex = calendar.component(.month, from: currentMonth) - 1
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showDatePicker = false
                        }
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                    )
                    
                    Button("확인") {
                        applyDateSelection()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showDatePicker = false
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                    )
                }
                .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .background(
            Color.black.opacity(0.3)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDatePicker = false
                    }
                }
        )
        .transition(.opacity)
    }
    
    private func applyDateSelection() {
        let calendar = Calendar.current
        let components = DateComponents(year: selectedYear, month: selectedMonthIndex + 1, day: 1)
        
        if let newDate = calendar.date(from: components),
           newDate >= startMonth && newDate <= endMonth {
            withAnimation {
                currentMonth = newDate
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 12))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 26)
                    .padding(8)
            }
        }
    }

    private var calendarGrid: some View {
        let daysInMonth = numberOfDays(in: currentMonth)
        let firstWeekday = firstWeekdayOfMonth(in: currentMonth) - 1

        return LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
            ForEach(0..<daysInMonth + firstWeekday, id: \.self) { index in
                Group {
                    if index < firstWeekday {
                        let rawDate = Calendar.current.date(byAdding: .day, value: index - firstWeekday, to: startOfMonth())!
                        CellView(
                            day: Calendar.current.component(.day, from: rawDate),
                            isToday: false,
                            isSelected: false,
                            isWithinMonth: false,
                            isDisabled: true,
                            hasLog: false
                        )
                    } else {
                        let rawDate = getDate(for: index - firstWeekday)
                        let day = Calendar.current.component(.day, from: rawDate)

                        let isToday = Calendar.current.isDateInToday(rawDate)
                        let isWithinMonth = Calendar.current.isDate(rawDate, equalTo: currentMonth, toGranularity: .month)
                        let isFuture = rawDate > Date()
                        let isSelected = Calendar.current.isDate(rawDate, inSameDayAs: selectedDate)
                        let hasLog = existingLogDates.contains(dateString(from: rawDate))
                        let isDisabled = !isWithinMonth || isFuture || hasLog

                        CellView(
                            day: day,
                            isToday: isToday,
                            isSelected: isSelected,
                            isWithinMonth: isWithinMonth,
                            isDisabled: isDisabled,
                            hasLog: hasLog
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard !isDisabled else { return }
                            selectedDate = rawDate
                        }
                    }
                }
            }
        }
    }

    func getDate(for day: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: day, to: startOfMonth())!
    }

    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth))!
    }

    func numberOfDays(in date: Date) -> Int {
        Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
    }

    func firstWeekdayOfMonth(in date: Date) -> Int {
        let firstDay = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
        return Calendar.current.component(.weekday, from: firstDay)
    }

    func changeMonth(by value: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth),
              newMonth >= startMonth, newMonth <= endMonth else { return }
        withAnimation {
            currentMonth = newMonth
            // 선택된 년월도 업데이트
            selectedYear = Calendar.current.component(.year, from: newMonth)
            selectedMonthIndex = Calendar.current.component(.month, from: newMonth) - 1
        }
    }
    
    // 기존 로그 데이터 로드
    private func loadExistingLogs() {
        guard !isLoadingLogs else { return }
        
        isLoadingLogs = true
        LogBookService.shared.getAllLogs { result in
            DispatchQueue.main.async {
                self.isLoadingLogs = false
                switch result {
                case .success(let logs):
                    self.existingLogDates = Set(logs.map { $0.date })
                    print("📅 로드된 로그 날짜들: \(self.existingLogDates)")
                case .failure(let error):
                    print("❌ 로그 로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 날짜를 문자열로 변환 (서버 형식에 맞춤)
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy년 M월"
        return f
    }()

    static let weekdaySymbols = ["월", "화", "수", "목", "금", "토", "일"]
}

// MARK: - 셀 뷰
private struct CellView: View {
    let day: Int
    let isToday: Bool
    let isSelected: Bool
    let isWithinMonth: Bool
    let isDisabled: Bool
    let hasLog: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if isSelected && !isDisabled {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                }

                Text("\(day)")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                    .foregroundStyle(
                        isDisabled ? Color.grayscale_g300 :
                        (isSelected ? .white : Color.grayscale_g600)
                    )
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 11)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
            }

            if isToday && !isDisabled {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 4, height: 4)
                    .padding(.top, 2)
            } else {
                Color.clear.frame(height: 6)
            }
        }
        .frame(height: 44)
    }
}

// MARK: - 프리뷰
#Preview {
    NewCalenderView(
        currentMonth: .constant(Date()),                      // 현재 월
        selectedDate: .constant(Date()),                      // 선택된 날짜
        startMonth: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,  // 시작 범위
        endMonth: Calendar.current.date(byAdding: .month, value: 3, to: Date())!    // 끝 범위
    )
}
