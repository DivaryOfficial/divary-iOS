//
//  ImageService.swift
//  Divary
//
//  Created by 김나영 on 8/12/25.
//

import Foundation
import Moya
import Combine
import CombineMoya

final class ImageUploadService {
    private let provider = MoyaProvider<ImageAPI>()

    // OceanCatalogService 패턴: requestPublisher + extractData + manageThread
    func uploadTemp(files: [Data], token: String, mimeType: String = "image/jpeg")
    -> AnyPublisher<[UploadedImageDTO], Error> {
        provider.requestPublisher(.uploadTemp(files: files, token: token, mimeType: mimeType))
            .handleEvents(receiveOutput: { response in
                // 로그 확인용
                if let text = String(data: response.data, encoding: .utf8) {
                    print("📦 uploadTemp response: \(text)")
                }
            })
            .eraseToAnyPublisher()
            .extractData(UploadTempImagesDataDTO.self)
            .map(\.images)
            .manageThread()
    }
}
