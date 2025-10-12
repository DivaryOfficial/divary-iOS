//
//  MyProfileEditingView.swift
//  Divary
//
//  Created by 김나영 on 9/25/25.
//

import SwiftUI

struct MyProfileView: View {
    @Environment(\.diContainer) private var di

    // 임시 데이터(연결되면 ViewModel 바인딩으로 교체)
    @State private var userId: String = "user_id0123"
    @State private var organization: String = ""
    @State private var selectedLevel: DiveLevel = .openWater
    @State private var isLevelExpanded: Bool = false

    var onTapBell: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            MyPageTopBar(isMainView: false, title: "프로필 정보", onBell: onTapBell)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 20) {

                // 아이디 (읽기 전용)
                LabeledBlock(title: "아이디") {
                    ReadOnlyField(text: userId)
                }

                // 단체 (입력)
                LabeledBlock(title: "단체") {
                    EditableField(text: $organization,
                                  placeholder: "내용을 입력하세요")
                }

                // 레벨 (드롭다운)
                LabeledBlock(title: "레벨") {
                    LevelDropdown(
                        selected: $selectedLevel,
                        isExpanded: $isLevelExpanded
                    )
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - DiveLevel Enum

enum DiveLevel: String, CaseIterable, Identifiable {
    case openWater = "오픈워터 다이버"
    case advancedOW = "어드밴스드 오픈워터 다이버"
    case rescue = "레스큐 다이버"
    case diveMaster = "다이브마스터"
    case assistantInstructor = "어시스턴트 인스트럭터"
    case instructor = "인스트럭터"

    var id: String { rawValue }
}

// MARK: - Building Blocks

/// 섹션 타이틀 + 내용 박스
private struct LabeledBlock<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.omyu.regular(size: 18))
                .foregroundStyle(.primary)

            content
        }
    }
}

/// 회색 배경의 읽기 전용 필드
private struct ReadOnlyField: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.omyu.regular(size: 18))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.grayscaleG100))
            )
    }
}

/// placeholder 지원하는 텍스트 입력
private struct EditableField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.omyu.regular(size: 18))
                    .foregroundStyle(Color(.systemGray3))
            }
            TextField("", text: $text)
                .font(.omyu.regular(size: 18))
                .foregroundStyle(.primary)
                .tint(Color(.label))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.grayscaleG100))
        )
    }
}

/// 드롭다운: 접힘/펼침 + 옵션 리스트
private struct LevelDropdown: View {
    @Binding var selected: DiveLevel
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(spacing: 0) {
            // 헤더(선택 값 + 화살표)
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(selected.rawValue)
                        .font(.omyu.regular(size: 18))
                        .foregroundStyle(.black)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .contentShape(Rectangle())
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
            }

            // 옵션 리스트
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(DiveLevel.allCases) { level in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selected = level
                                isExpanded = false
                            }
                        } label: {
                            Text(level.rawValue)
                                .font(.omyu.regular(size: 16))
                                .foregroundStyle(level == selected ? .primary : Color(.systemGray))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.grayscaleG100))
        )
    }
}

#Preview {
    MyProfileView()
        .environment(\.colorScheme, .light)
}
