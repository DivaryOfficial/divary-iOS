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

final class ImageService {
    private let provider = MoyaProvider<ImageAPI>()

    private func currentAccessToken() -> String {
        KeyChainManager.shared.read(forKey: KeyChainKey.accessToken) ?? ""
    }

    func uploadTemp(files: [Data], token: String, mimeType: String = "image/jpeg")
    -> AnyPublisher<[UploadedImageDTO], Error> {
        provider.requestPublisherWithAutoRefresh(
            makeTarget: { .uploadTemp(files: files, token: self.currentAccessToken(), mimeType: mimeType) }
        )
        .handleEvents(receiveOutput: { response in
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
