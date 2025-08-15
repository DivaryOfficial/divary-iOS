//
//  OceanCreatureDetailView.swift
//  Divary
//
//  Created by 김나영 on 8/5/25.
//

import SwiftUI
import Kingfisher

struct OceanCreatureDetailView: View {
    @Environment(\.diContainer) private var di
    
    let creature: SeaCreatureDetail
    @State var selectedSection: SectionType = .appearance
    @State private var sectionAnchors: [SectionAnchor] = []
    @State private var currentIndex: Int = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    ZStack {
                        HStack {
                            Button(action: { di.router.pop() }) {
                                Image(.chevronLeft)
                                    .foregroundStyle(.black)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        }
                        
                        // 인덱스 중앙
                        Text("해양도감")
                            .font(.omyu.regular(size: 20))
                    }
                    imageSlider
                    titleBlock
                    sectionButtons(proxy: proxy, selectedSection: $selectedSection)
                    
                    appearanceSection
                    divider
                    personalitySection
                    divider
                    significantSection
                }
                .background(GeometryReader { _ in Color.clear })
                .onPreferenceChange(SectionPositionKey.self) { values in
                    sectionAnchors = values
                    
                    // 현재 화면에서 가장 위에 가까운 섹션 선택
                    if let closest = values.min(by: { abs($0.minY) < abs($1.minY) }) {
                        selectedSection = closest.section
                    }
                }
            }
            .coordinateSpace(name: "scroll")
//            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
//            .navigationTitle("해양도감")
//            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - 이미지 슬라이드
    private var imageSlider: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = width * 3/4
            
            TabView(selection: $currentIndex) {
                ForEach(Array(creature.imageUrls.enumerated()), id: \.offset) { index, url in
                    KFImage(url)
                        .placeholder { ProgressView() }
                        .retry(maxCount: 2, interval: .seconds(1))
                        .resizable()
                        .scaledToFill()
                        .id(url)
                        .tag(index)
                        .frame(width: width, height: height)
                        .clipped()
                }
            }
            .frame(width: width, height: height)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .overlay(
                Text("\(currentIndex + 1)｜\(creature.imageUrls.count)")
                    .font(.NanumSquareNeo.NanumSquareNeoBold(size: 10))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.black)
                    .cornerRadius(10)
                    .padding(8),
                alignment: .bottomTrailing
            )
        }
        .frame(height: UIScreen.main.bounds.width * 3/4)
    }
    
    // MARK: - 상단 블록
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(creature.name)")
                .font(.omyu.regular(size: 24))
            Text(creature.type)
                .font(.NanumSquareNeo.NanumSquareNeoBold(size: 14))
                .foregroundColor(.grayscale_g600)
                .padding(.bottom)

            VStack {
                DetailInfoBlock(title: "크기", value: creature.size)
                    .padding(.horizontal)
                    .padding(.top)
                DetailInfoBlock(title: "출몰시기", value: creature.appearPeriod)
                    .padding(.horizontal)
                DetailInfoBlock(title: "서식", value: creature.place)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .background(Color(.grayscaleG100))
            .cornerRadius(8)
        }
        .padding()
    }
    
    // MARK: - 섹션버튼
    private func sectionButtons(proxy: ScrollViewProxy, selectedSection: Binding<SectionType>) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ForEach(SectionType.allCases, id: \.self) { section in
                    let isSelected = selectedSection.wrappedValue == section

                    Button(action: {
                        withAnimation {
                            selectedSection.wrappedValue = section
                            proxy.scrollTo(section, anchor: .top)
                        }
                    }) {
                        Text(section.rawValue)
                            .font(.omyu.regular(size: 20))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(isSelected ? Color(.white) : Color(.grayscaleG400))
                            .background(
                                RoundedCorners(tl: 12, tr: 12, bl: 0, br: 0)
                                    .fill(isSelected ? Color(.primarySeaBlue) : Color(.grayscaleG100))
                            )
                            .animation(nil, value: isSelected)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            
            divider
        }
    }
    
    // MARK: - 외모
    private var appearanceSection: some View {
        Group {
            SectionPositionReporter(section: .appearance)
                .frame(height: 0)
            
            SectionHeader(title: "외모", icon: Image(.appearance))
            DetailLine("몸 형태", creature.appearance.body)
            DetailLine("색상", creature.appearance.color, colorCodes: creature.appearance.colorCodes)
            DetailLine("무늬", creature.appearance.pattern)
            DetailLine("기타", creature.appearance.etc)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .id(SectionType.appearance)
    }
    
    // MARK: - 성격
    private var personalitySection: some View {
        Group {
            SectionPositionReporter(section: .personality)
                .frame(height: 0)
            
            SectionHeader(title: "성격", icon: Image(.personality))
            DetailLine("활동성", creature.personality.activity)
            DetailLine("사회성", creature.personality.socialSkill)
            DetailLine("행동 특성", creature.personality.behavior)
            DetailLine("반응성", creature.personality.reactivity)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .id(SectionType.personality)
    }
    
    // MARK: - 특이사항
    private var significantSection: some View {
        Group {
            SectionPositionReporter(section: .significant)
                .frame(height: 0)
            
            SectionHeader(title: "특이사항", icon: Image(.significant))
            DetailLine("독성 여부", creature.significant.toxicity)
            DetailLine("생존 전략", creature.significant.strategy)
            DetailLine("관찰 팁", creature.significant.observeTip)
            DetailLine("기타 특징", creature.significant.otherFeature)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .id(SectionType.significant)
    }

    
    private var divider: some View {
        Divider().frame(height: 3).frame(maxWidth: .infinity).background(Color(.grayscaleG200))
    }
}

enum SectionType: String, CaseIterable {
    case appearance = "외모"
    case personality = "성격"
    case significant = "특이사항"
}

struct DetailInfoBlock: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title).font(.NanumSquareNeo.NanumSquareNeoBold(size: 12)).foregroundColor(Color(.grayscaleG600))
                .frame(width: 60, alignment: .leading)
            Text(value).font(.NanumSquareNeo.NanumSquareNeoBold(size: 12)).foregroundColor(Color(.grayscaleG800))
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: Image

    var body: some View {
        HStack {
            icon
            Text(title)
                .font(.omyu.regular(size: 24))
        }
    }
}

func DetailLine(_ title: String, _ value: String, colorCodes: [String] = []) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title)
            .font(.omyu.regular(size: 20))
            .padding(.bottom, 4)
        
        // 색상 원이 있을 때만 표시
        if title == "색상" && !colorCodes.isEmpty {
            HStack(spacing: 8) {
                ForEach(colorCodes, id: \.self) { hex in
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(hex: hex))
                        .overlay(
                            Circle().stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                        )
                }
            }
            .padding(.bottom, 4)
        }
        Text(value).font(.NanumSquareNeo.NanumSquareNeoBold(size: 14)).foregroundColor(Color(.grayscaleG700))
    }
}


struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height

        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)

        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()

        return path
    }
}

#Preview {
    let sampleSeaCreatureDetail = SeaCreatureDetail(
        id: 2,
        name: "갯민숭달팽이",
        type: "연체동물",
        size: "약 1.5~6cm",
        appearPeriod: "봄, 가을에 주로 관찰",
        place: "따뜻한 연안, 바위 틈",
        imageUrls: [
            URL(string: "https://commons.wikimedia.org/wiki/File:Lampetra_fluviatilis.jpg")!,
            URL(string: "https://commons.wikimedia.org/wiki/File:Lampetra_fluviatilis.jpg")!,
            URL(string: "https://commons.wikimedia.org/wiki/File:Lampetra_fluviatilis.jpg")!
        ],
        appearance: Appearance(
            body: "부드럽고 납작한 몸체",
            colorCodes: ["#FFFFFF", "#FFD700", "#000000"],
            color: "흰색, 노란색, 검정색 점",
            pattern: "누디브랜치",
            etc: "촉수가 눈처럼 보임"
        ),
        personality: Personality(
            activity: "느림",
            socialSkill: "혼자 다님",
            behavior: "서식지 주변을 기어다님",
            reactivity: "자극에 민감"
        ),
        significant: Significant(
            toxicity: "무독성",
            strategy: "위장",
            observeTip: "작고 조용히 숨어 있으니 자세히 봐야 함",
            otherFeature: "바다 속 꽃처럼 생김"
        )
    )
    
    OceanCreatureDetailView(creature: sampleSeaCreatureDetail, selectedSection: .appearance)
}
