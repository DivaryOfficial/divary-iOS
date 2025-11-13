//
//  MemberService.swift
//  Divary
//
//  Created by 김나영 on 11/13/25.
//

import Foundation
import Moya
import Combine
import CombineMoya

final class MemberService {
    
    // MemberAPI를 사용하는 Moya Provider
    private let provider = MoyaProvider<MemberAPI>()

    /// 1. 프로필 조회
    /// - API: `.getProfile`
    /// - 반환: `DefaultResponse<MemberProfileResponse>`의 `data`
    func getProfile() -> AnyPublisher<MemberProfileResponse, Error> {
        return provider.requestPublisherWithAutoRefresh(
            makeTarget: { .getProfile }
        )
        // .extractData가 DefaultResponse<T>를 디코딩하고 T(data)를 반환한다고 가정합니다.
        .extractData(MemberProfileResponse.self)
        .manageThread() // .receive(on: DispatchQueue.main) 등 처리로 가정
    }
    
    /// 2. 다이빙 레벨 수정
    /// - API: `.updateLevel`
    /// - 반환: `DefaultResponse<EmptyData>` (성공 여부만 중요)
    func updateLevel(level: String) -> AnyPublisher<Void, Error> {
        return provider.requestPublisherWithAutoRefresh(
            makeTarget: { .updateLevel(level: level) }
        )
        // data가 없는 응답이므로 EmptyData.self로 디코딩
        .extractData(EmptyData.self)
        // Call-Site에서 다루기 쉽도록 Void로 변환
        .map { _ in () }
        .manageThread()
    }
    
    /// 3. 다이빙 단체 수정
    /// - API: `.updateGroup`
    /// - 반환: `DefaultResponse<EmptyData>` (성공 여부만 중요)
    func updateGroup(group: String) -> AnyPublisher<Void, Error> {
        return provider.requestPublisherWithAutoRefresh(
            makeTarget: { .updateGroup(group: group) }
        )
        .extractData(EmptyData.self)
        .map { _ in () }
        .manageThread()
    }
    
    /// 4. 자격증 이미지 업로드
    /// - API: `.uploadLicense`
    /// - 반환: `DefaultResponse<LicenseResponse>`의 `data`
    func uploadLicense(image: Data, fileName: String, mimeType: String) -> AnyPublisher<LicenseResponse, Error> {
        return provider.requestPublisherWithAutoRefresh(
            makeTarget: { .uploadLicense(image: image, fileName: fileName, mimeType: mimeType) }
        )
        .extractData(LicenseResponse.self)
        .manageThread()
    }
    
    /// 5. 자격증 이미지 조회
    /// - API: `.getLicense`
    /// - 반환: `DefaultResponse<LicenseResponse>`의 `data`
    func getLicense() -> AnyPublisher<LicenseResponse, Error> {
        return provider.requestPublisherWithAutoRefresh(
            makeTarget: { .getLicense }
        )
        .extractData(LicenseResponse.self)
        .manageThread()
    }
}
