//
//  MyLicenseViewModel.swift
//  Divary
//
//  Created by 김나영 on 11/14/25.
//

import SwiftUI
import Combine
import UIKit

final class MyLicenseViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 뷰에 표시될 최종 라이센스 이미지
    @Published var licenseImage: UIImage?
    
    /// 로딩 스피너 (데이터 로드, 업로드)
    @Published var isLoading: Bool = false
    
    /// 앨범/카메라 선택 메뉴 표시 여부
    @Published var showSourceMenu: Bool = false
    
    // MARK: - Private Properties
    private let memberService: MemberService
    private var cancellables = Set<AnyCancellable>()
    
    /// 이미지 다운로드 작업을 저장 (취소 가능하도록)
    private var imageDownloadCancellable: Cancellable?

    // MARK: - Init
    
    init(memberService: MemberService) {
        self.memberService = memberService
    }
    
    // MARK: - Public API Methods
    
    /// 1. 뷰가 나타날 때, 기존에 등록된 라이센스를 불러옵니다.
    func fetchLicense(showLoading: Bool = true) {
        DebugLogger.info("fetchLicense 호출")
        if showLoading {
            isLoading = true
            licenseImage = nil // 로드 시작 시, 이전 이미지를 초기화
        }
        
        // 이전 다운로드 작업이 있다면 취소
        imageDownloadCancellable?.cancel()
        
        memberService.getLicense()
            .flatMap { [weak self] response -> AnyPublisher<UIImage?, Error> in
                // .getLicense는 성공. 이제 URL에서 이미지를 다운로드합니다.
                DebugLogger.success("getLicense 성공: \(response.url)")
                return self?.downloadImagePublisher(from: response.url)
                    // 만약 self가 nil이면, 빈 Publisher를 반환하여 체인을 중단시킵니다.
                    ?? Empty<UIImage?, Error>(completeImmediately: true).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if showLoading { self?.isLoading = false }
                if case .failure(let error) = completion {
                    DebugLogger.error("fetchLicense (또는 download) 에러: \(error.localizedDescription)")
                    // 404 등 에러 -> 등록된 이미지 없음.
                    self?.licenseImage = nil
                    self?.showSourceMenu = false // "+" 버튼 표시
                }
            }, receiveValue: { [weak self] image in
                if showLoading { self?.isLoading = false }
                self?.licenseImage = image
                self?.showSourceMenu = false // 이미지 로드 완료, 메뉴 닫기
            })
            .store(in: &cancellables)
    }
    
    /// 2. 앨범/카메라에서 선택된 새 이미지를 업로드합니다.
    func uploadLicense(image: UIImage) {
        // 이미지를 고화질 JPEG 데이터로 압축
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            DebugLogger.error("이미지 JPEG 데이터 변환 실패")
            return
        }
        
        // 고유한 파일 이름 생성
        let fileName = "license_\(UUID().uuidString).jpg"
        let mimeType = "image/jpeg"
        
        DebugLogger.info("uploadLicense 호출: \(fileName)")
        isLoading = true
        
        memberService.uploadLicense(image: imageData, fileName: fileName, mimeType: mimeType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DebugLogger.error("uploadLicense 에러: \(error.localizedDescription)")
                    self?.isLoading = false // 실패 시 즉시 로딩 끔
                    self?.fetchLicense(showLoading: false) // 로딩 없이 조용히 롤백
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                DebugLogger.success("uploadLicense 성공: \(response.url)")
                // 업로드 성공. 뷰의 이미지를 방금 업로드한 것으로 확정.
                // (이미 UI는 업데이트 되었으므로) 메뉴만 닫음.
                self.licenseImage = image // 방금 업로드한 이미지로 확정
                self.showSourceMenu = false
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Private Helper
    
    /// 3. 이미지 URL 문자열을 UIImage로 변환하는 헬퍼 Publisher
    private func downloadImagePublisher(from urlString: String) -> AnyPublisher<UIImage?, Error> {
        guard let url = URL(string: urlString) else {
            DebugLogger.error("잘못된 이미지 URL: \(urlString)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        DebugLogger.log("이미지 다운로드 시작: \(url)")
        let weakSelf = self
        
        // URLSession의 dataTaskPublisher 사용
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) } // Data -> UIImage
            .mapError { $0 as Error } // URL Error -> Error
            .handleEvents(receiveSubscription: { subscription in
                // ‼️ (이것이 핵심)
                // 이 Publisher가 구독(subscribe)될 때,
                // 그 구독권(subscription)을 'imageDownloadCancellable' 프로퍼티에 저장합니다.
                // (데이터 경쟁 방지를 위해 메인 스레드에서 할당)
                DispatchQueue.main.async {
                    weakSelf.imageDownloadCancellable = subscription
                }
            })
            .eraseToAnyPublisher()
    }
}
