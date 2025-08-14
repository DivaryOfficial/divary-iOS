//
//  LocationSearch.swift
//  Divary
//
//  Created by 바견규 on 8/14/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationSearchView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchText: String
    @State private var searchResults: [MKMapItem] = []
    @State private var searchTask: Task<Void, Never>?
    @State private var cachedResults: [String: [MKMapItem]] = [:]
    @State private var isLoadingNearbySpots = false
    @Environment(\.diContainer) var container
    
    let placeholder: String
    let onLocationSelected: (String) -> Void
    
    init(currentValue: String = "", placeholder: String = "다이빙 스팟 검색", onLocationSelected: @escaping (String) -> Void) {
        self._searchText = State(initialValue: currentValue)
        self.placeholder = placeholder
        self.onLocationSelected = onLocationSelected
    }
    
    var body: some View {
        VStack(spacing: 0) {
            LocationSearchNavBar()
            
            // 검색바
            SearchBar(text: $searchText, placeholder: placeholder, onTextChanged: handleSearch)
            
            // 결과 리스트
            List {
                // 검색어가 없을 때 주변 다이빙 스팟 섹션
                if searchText.isEmpty {
                    Section {
                        if isLoadingNearbySpots {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("주변 다이빙 스팟을 찾고 있습니다...")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14))
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        } else if searchResults.isEmpty {
                            Text("주변 다이빙 스팟을 찾을 수 없습니다")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(searchResults, id: \.self) { item in
                                LocationRowView(
                                    item: item,
                                    currentLocation: locationManager.location,
                                    onTap: {
                                        selectLocation(item)
                                    }
                                )
                                .listRowSeparator(.hidden)
                            }
                        }
                    } header: {
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundColor(.blue)
                            Text("주변 스쿠버 다이빙 스팟")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                } else {
                    // 검색 결과
                    if searchResults.isEmpty {
                        Text("검색 결과가 없습니다")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(searchResults, id: \.self) { item in
                            LocationRowView(
                                item: item,
                                currentLocation: locationManager.location,
                                onTap: {
                                    selectLocation(item)
                                }
                            )
                            .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationManager.requestPermission()
            if searchText.isEmpty {
                Task {
                    await loadNearbyDivingSpots()
                }
            }
        }
        .onChange(of: locationManager.location) { oldLocation, newLocation in
            // 위치가 처음 획득되었거나 크게 변경된 경우에만 새로고침
            let shouldRefresh: Bool
            if let old = oldLocation, let new = newLocation {
                let distance = old.distance(from: new)
                shouldRefresh = distance > 10000 // 10km 이상 변경시에만
            } else {
                shouldRefresh = newLocation != nil && oldLocation == nil
            }
            
            if shouldRefresh && searchText.isEmpty {
                Task {
                    await loadNearbyDivingSpots()
                }
            }
        }
    }
    
    // 위치 선택 처리 - 수정된 부분
    private func selectLocation(_ item: MKMapItem) {
        let selectedLocationName = item.name ?? ""
        
        // 선택된 위치를 부모 뷰에 전달
        onLocationSelected(selectedLocationName)
        
        // 이전 화면으로 돌아가기
        container.router.pop()
        
        print("선택된 위치: \(selectedLocationName)")
        print("좌표: \(item.placemark.coordinate)")
    }
    
    // 디바운싱된 검색 처리
    private func handleSearch(_ text: String) {
        searchTask?.cancel()
        
        // 캐시 확인
        if let cached = cachedResults[text] {
            searchResults = cached
            return
        }
        
        if text.isEmpty {
            Task {
                await loadNearbyDivingSpots()
            }
            return
        }
        
        // 너무 짧은 검색어는 무시
        if text.count < 2 {
            searchResults = []
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초
            guard !Task.isCancelled else { return }
            
            await performSmartDivingSearch(query: text)
        }
    }
    
    // 스마트 다이빙 검색
    private func performSmartDivingSearch(query: String) async {
        var allResults: [MKMapItem] = []
        
        // 1. 원본 쿼리 검색
        if let results = await searchMapKit(query: query) {
            allResults.append(contentsOf: results)
        }
        
        // 2. 결과가 적을 때 다이빙 키워드 추가
        if allResults.count < 3 {
            let enhancedQuery = containsKorean(query) ? "\(query) 다이빙" : "\(query) diving"
            if let additionalResults = await searchMapKit(query: enhancedQuery) {
                allResults.append(contentsOf: additionalResults)
            }
        }
        
        // 중복 제거 및 정렬
        let uniqueResults = removeDuplicateMapItems(from: allResults)
        let sortedResults = sortByRelevance(results: uniqueResults, query: query)
        
        await MainActor.run {
            self.searchResults = Array(sortedResults.prefix(20))
            self.cachedResults[query] = self.searchResults
        }
    }
    
    // 주변 다이빙 스팟 로드 (개선된 버전)
    private func loadNearbyDivingSpots() async {
        await MainActor.run {
            isLoadingNearbySpots = true
        }
        
        // 캐시 키 생성
        let cacheKey: String
        if let location = locationManager.location {
            cacheKey = "nearby_diving_\(Int(location.coordinate.latitude * 100))_\(Int(location.coordinate.longitude * 100))"
        } else {
            cacheKey = "default_diving_spots"
        }
        
        // 캐시된 결과 확인
        if let cached = cachedResults[cacheKey] {
            await MainActor.run {
                self.searchResults = cached
                self.isLoadingNearbySpots = false
            }
            return
        }
        
        var allResults: [MKMapItem] = []
        
        // 다양한 스쿠버 다이빙 관련 검색어로 검색
        let searchTerms = [
            "scuba diving",
            "dive center",
            "diving site",
            "underwater diving",
            "dive shop",
            "스쿠버 다이빙",
            "다이빙센터",
            "다이빙샵"
        ]
        
        // 병렬로 검색 수행 (성능 향상)
        await withTaskGroup(of: [MKMapItem]?.self) { group in
            for term in searchTerms.prefix(4) { // API 호출 제한을 위해 4개만
                group.addTask {
                    await searchMapKit(query: term)
                }
            }
            
            for await results in group {
                if let results = results {
                    allResults.append(contentsOf: results)
                }
            }
        }
        
        // 결과 처리
        let filteredResults = filterDivingSpots(from: allResults)
        let uniqueResults = removeDuplicateMapItems(from: filteredResults)
        let sortedResults = sortByDistanceAndRelevance(results: uniqueResults)
        
        let finalResults = Array(sortedResults.prefix(15))
        
        await MainActor.run {
            self.searchResults = finalResults
            self.cachedResults[cacheKey] = finalResults
            self.isLoadingNearbySpots = false
        }
    }
    
    // 다이빙 스팟 필터링 (더 정확한 필터링)
    private func filterDivingSpots(from items: [MKMapItem]) -> [MKMapItem] {
        return items.filter { item in
            let name = item.name?.lowercased() ?? ""
            let category = item.pointOfInterestCategory?.rawValue.lowercased() ?? ""
            
            // 다이빙 관련 키워드
            let divingKeywords = [
                "dive", "diving", "scuba", "underwater", "marine", "reef", "coral",
                "aquatic", "submarine", "snorkel", "deep sea", "wreck",
                "다이빙", "스쿠버", "잠수", "해저", "산호", "스노클링"
            ]
            
            // 해양/해변 관련 키워드
            let marineKeywords = [
                "ocean", "sea", "beach", "coast", "bay", "island", "harbor",
                "marina", "port", "pier", "wharf", "resort",
                "바다", "해변", "해안", "항구", "만", "섬", "포구"
            ]
            
            let allText = "\(name) \(category)"
            
            // 다이빙 키워드가 직접 포함되어 있거나
            let hasDivingKeyword = divingKeywords.contains { keyword in
                allText.contains(keyword)
            }
            
            // 해양 관련 장소면서 관광/레크리에이션 카테고리인 경우
            let isMarineLocation = marineKeywords.contains { keyword in
                allText.contains(keyword)
            } && (category.contains("tourism") || category.contains("recreation") || category.contains("resort"))
            
            return hasDivingKeyword || isMarineLocation
        }
    }
    
    // 거리와 관련성으로 정렬
    private func sortByDistanceAndRelevance(results: [MKMapItem]) -> [MKMapItem] {
        return results.sorted { item1, item2 in
            let name1 = item1.name?.lowercased() ?? ""
            let name2 = item2.name?.lowercased() ?? ""
            
            // 1. 다이빙 관련도 점수
            let relevanceScore1 = calculateDivingRelevanceScore(for: name1)
            let relevanceScore2 = calculateDivingRelevanceScore(for: name2)
            
            if relevanceScore1 != relevanceScore2 {
                return relevanceScore1 > relevanceScore2
            }
            
            // 2. 거리순 (현재 위치가 있을 때)
            if let userLocation = locationManager.location,
               let location1 = item1.placemark.location,
               let location2 = item2.placemark.location {
                let distance1 = userLocation.distance(from: location1)
                let distance2 = userLocation.distance(from: location2)
                return distance1 < distance2
            }
            
            // 3. 이름순
            return name1 < name2
        }
    }
    
    // 다이빙 관련도 점수 계산
    private func calculateDivingRelevanceScore(for name: String) -> Int {
        var score = 0
        
        let highPriorityKeywords = ["scuba", "diving", "dive center", "스쿠버", "다이빙센터"]
        let mediumPriorityKeywords = ["underwater", "marine", "reef", "coral", "다이빙", "해저"]
        let lowPriorityKeywords = ["ocean", "sea", "beach", "island", "바다", "해변", "섬"]
        
        for keyword in highPriorityKeywords {
            if name.contains(keyword) {
                score += 10
            }
        }
        
        for keyword in mediumPriorityKeywords {
            if name.contains(keyword) {
                score += 5
            }
        }
        
        for keyword in lowPriorityKeywords {
            if name.contains(keyword) {
                score += 1
            }
        }
        
        return score
    }
    
    // 한국어 포함 체크
    private func containsKorean(_ text: String) -> Bool {
        let koreanRange = text.range(of: "[가-힣]", options: .regularExpression)
        return koreanRange != nil
    }
    
    // MapKit 검색
    private func searchMapKit(query: String) async -> [MKMapItem]? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        // 현재 위치 중심으로 검색 범위 설정
        if let location = locationManager.location {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 50000, // 50km 반경
                longitudinalMeters: 50000
            )
        } else {
            // 위치 정보가 없으면 전세계 검색
            request.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                latitudinalMeters: 40000000,
                longitudinalMeters: 40000000
            )
        }
        
        request.resultTypes = [.pointOfInterest, .address]
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            return response.mapItems.filter { item in
                guard let name = item.name, !name.isEmpty else { return false }
                return true
            }
        } catch {
            if let mkError = error as? MKError {
                switch mkError.code {
                case .serverFailure:
                    print("MapKit 서버 오류 (\(query))")
                case .loadingThrottled:
                    print("MapKit API 제한 초과 (\(query)): 잠시 후 재시도하세요")
                case .placemarkNotFound:
                    print("검색 결과 없음 (\(query))")
                default:
                    print("MapKit 오류 (\(query)): \(mkError.localizedDescription)")
                }
            }
            return nil
        }
    }
    
    // 관련성으로 정렬
    private func sortByRelevance(results: [MKMapItem], query: String) -> [MKMapItem] {
        let lowercaseQuery = query.lowercased()
        
        return results.sorted { item1, item2 in
            let name1 = item1.name?.lowercased() ?? ""
            let name2 = item2.name?.lowercased() ?? ""
            
            // 1. 정확히 일치
            let exactMatch1 = name1 == lowercaseQuery
            let exactMatch2 = name2 == lowercaseQuery
            if exactMatch1 != exactMatch2 {
                return exactMatch1
            }
            
            // 2. 시작하는 것
            let startsWith1 = name1.hasPrefix(lowercaseQuery)
            let startsWith2 = name2.hasPrefix(lowercaseQuery)
            if startsWith1 != startsWith2 {
                return startsWith1
            }
            
            // 3. 포함하는 것
            let contains1 = name1.contains(lowercaseQuery)
            let contains2 = name2.contains(lowercaseQuery)
            if contains1 != contains2 {
                return contains1
            }
            
            // 4. 거리순
            if let userLocation = locationManager.location,
               let location1 = item1.placemark.location,
               let location2 = item2.placemark.location {
                let distance1 = userLocation.distance(from: location1)
                let distance2 = userLocation.distance(from: location2)
                return distance1 < distance2
            }
            
            return name1 < name2
        }
    }
    
    // 중복 제거
    private func removeDuplicateMapItems(from items: [MKMapItem]) -> [MKMapItem] {
        var seen = Set<String>()
        return items.filter { item in
            let key = (item.name ?? "").lowercased()
            return seen.insert(key).inserted
        }
    }
}

// MARK: - UI 컴포넌트
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onTextChanged: (String) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .onChange(of: text) { oldValue, newValue in
                    onTextChanged(newValue)
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onTextChanged("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct LocationRowView: View {
    let item: MKMapItem
    let currentLocation: CLLocation?
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 다이빙 관련 아이콘
            Image(systemName: isDivingRelated ? "figure.pool.swim" : "location.fill")
                .foregroundColor(isDivingRelated ? .blue : .gray)
                .font(.system(size: 16))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name ?? "위치")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                if let address = formattedAddress {
                    Text(address)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // 다이빙 관련 태그 표시
                if isDivingRelated {
                    HStack {
                        Text("🤿 다이빙 스팟")
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                        Spacer()
                    }
                }
            }
            
            Spacer()
            
            // 거리 표시
            if let distance = distanceText {
                Text(distance)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private var isDivingRelated: Bool {
        let name = item.name?.lowercased() ?? ""
        let locality = item.placemark.locality?.lowercased() ?? ""
        let subLocality = item.placemark.subLocality?.lowercased() ?? ""
        
        let allText = "\(name) \(locality) \(subLocality)"
        
        let divingKeywords = [
            "dive", "diving", "scuba", "underwater", "marine", "reef", "coral",
            "beach", "island", "bay", "coast", "ocean", "sea", "aquatic", "snorkel",
            "다이빙", "스쿠버", "바다", "해변", "섬", "해안", "스노클링"
        ]
        
        return divingKeywords.contains { keyword in
            allText.contains(keyword)
        }
    }
    
    private var formattedAddress: String? {
        let placemark = item.placemark
        
        var components: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        
        if let locality = placemark.locality {
            components.append(locality)
        } else if let subLocality = placemark.subLocality {
            components.append(subLocality)
        }
        
        if let country = placemark.country {
            components.append(country)
        }
        
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
    
    private var distanceText: String? {
        guard let currentLocation = currentLocation,
              let itemLocation = item.placemark.location else { return nil }
        
        let distance = currentLocation.distance(from: itemLocation)
        
        if distance < 1000 {
            return "\(Int(distance))m"
        } else if distance < 1000000 {
            return String(format: "%.1fkm", distance / 1000)
        } else {
            return String(format: "%.0fkm", distance / 1000)
        }
    }
}

// 위치 매니저
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 획득 실패: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("위치 권한이 거부되었습니다")
        default:
            break
        }
    }
}

// MARK: - Previews
#Preview {
    NavigationView {
        LocationSearchView(
            currentValue: "",
            placeholder: "다이빙 스팟 검색",
            onLocationSelected: { location in
                print("Selected: \(location)")
            }
        )
    }
}
