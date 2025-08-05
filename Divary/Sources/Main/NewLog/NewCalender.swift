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

    var body: some View {
        VStack {
            headerView
            Spacer().frame(height: 10)
            weekdayHeader
            calendarGrid
        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
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

                Image("chevron.down")
                    .frame(width: 20)
                    .foregroundStyle(Color.bw_black)
                    .padding(.horizontal, 6)
            }

            Spacer()

            Button(action: { changeMonth(by: 1) }) {
                Image("chevron.right")
                    .foregroundStyle(Color.bw_black)
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
                            isDisabled: true
                        )
                    } else {
                        let rawDate = getDate(for: index - firstWeekday)
                        let day = Calendar.current.component(.day, from: rawDate)

                        let isToday = Calendar.current.isDateInToday(rawDate)
                        let isWithinMonth = Calendar.current.isDate(rawDate, equalTo: currentMonth, toGranularity: .month)
                        let isFuture = rawDate > Date()
                        let isSelected = Calendar.current.isDate(rawDate, inSameDayAs: selectedDate)
                        let isDisabled = !isWithinMonth || isFuture

                        CellView(
                            day: day,
                            isToday: isToday,
                            isSelected: isSelected,
                            isWithinMonth: isWithinMonth,
                            isDisabled: isDisabled
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
        }
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

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                }

                Text("\(day)")
                    .font(Font.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                    .foregroundStyle(
                        isDisabled ? Color.grayscale_g300 : (isSelected ? .white : Color.grayscale_g600)
                    )
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 11)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
            }

            if isToday {
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
