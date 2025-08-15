//
//  NotificationView.swift
//  Divary
//
//  Created by chohaeun on 8/5/25.
//

import SwiftUI


struct NotificationItem: Identifiable {
    let id = UUID()
    let icon: String
    let category: String
    let title: String
    let description: String
    let timeAgo: String
    var isExpanded: Bool = false
    var isRead: Bool = false  // 추가
}

@Observable
class NotificationManager {
    var notifications: [NotificationItem] = [
        NotificationItem(
            icon: "mysea",
            category: "나의 바다",
            title: "버디가 바다에서 기다리고 있어요!",
            description: "7일간 접속하지 않았어요. 버디가 바다에서 기다리고 있어요.",
            timeAgo: "1시간 전",
            isRead: false
        ),
        NotificationItem(
            icon: "update",
            category: "업데이트 알림",
            title: "새로운 기능이 업데이트 됐어요!",
            description: "새로운 기능이 업데이트 됐어요!",
            timeAgo: "어제",
            isRead: false
        )
    ]
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    static let shared = NotificationManager()
    private init() {}
}

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var manager = NotificationManager.shared

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 상단 네비게이션 바
                navigationBar
                
                // 알림 리스트
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(manager.notifications.indices, id: \.self) { index in
                            NotificationRow(
                                notification: $manager.notifications[index]
                            )
                            
                            // 마지막 아이템이 아닌 경우 구분선 추가
                            if index < manager.notifications.count - 1 {
                                                         Divider()
                                                             .background(Color.gray.opacity(0.3))
                                                             .padding(.horizontal, 16)
                                                     }
                            
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .background(Color.white)
        }
//        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.black)
            }
            
            Spacer()
            
            Text("알림")
                .font(Font.omyu.regular(size: 20))
                .foregroundStyle(.black)
            
            Spacer()
            
            // 오른쪽 공간 균형을 위한 투명 버튼
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.clear)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

struct NotificationRow: View {
    @Binding var notification: NotificationItem
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // 아이콘
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 46, height: 46)
                    
                    // 실제 아이콘 이미지가 있다면 Image(notification.icon) 사용
                    Image(notification.icon)
                    .frame(width: 46, height: 46)
                    
                }
                
                // 제목과 시간, 분류
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(notification.category)
                        .font(Font.omyu.regular(size: 14))
                        .foregroundStyle(Color.grayscale_g400)
                        .padding(.bottom, 4)
                    
                    Text(notification.title)
                        .font(Font.omyu.regular(size: 20))
                        .foregroundStyle(notification.isRead ? Color.grayscale_g400 : Color.bw_black)
                    
                    
                    // 상세 내용 (확장될 때만 표시)
                    if notification.isExpanded {
                                Text(notification.description)
                                    .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 10))
                                    .foregroundStyle(Color.grayscale_g400)
                                
                        }
                    }
                
                Spacer()
                
                VStack(alignment: .trailing){
                    
                    Spacer()
                    
                    // 확장/축소 버튼
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            notification.isExpanded.toggle()
                            
                            // 확장할 때 읽음 처리
                                   if notification.isExpanded && !notification.isRead {
                                       notification.isRead = true
                                   }
                        }
                    }) {
                        Image(systemName: notification.isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    Text(notification.timeAgo)
                        .font(Font.NanumSquareNeo.NanumSquareNeoRegular(size: 10))
                        .foregroundStyle(Color.grayscale_g300)
                }
             
            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 16)
            
        
        }
        .animation(.easeInOut(duration: 0.3), value: notification.isExpanded)
    }
}

#Preview {
    NotificationView()
}
