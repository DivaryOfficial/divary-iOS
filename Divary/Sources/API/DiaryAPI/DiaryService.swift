//
//  DiaryService.swift
//  Divary
//
//  Created by 김나영 on 8/12/25.
//

import Foundation
import Moya
import Combine
import CombineMoya

protocol LogDiaryServicing {
    func getDiary(logId: Int, token: String) -> AnyPublisher<DiaryResponseDTO, Error>
    func updateDiary(logId: Int, body: DiaryRequestDTO, token: String) -> AnyPublisher<DiaryResponseDTO, Error>
    func createDiary(logId: Int, body: DiaryRequestDTO, token: String) -> AnyPublisher<DiaryResponseDTO, Error>
}

final class LogDiaryService: LogDiaryServicing {
    private let provider: MoyaProvider<LogDiaryAPI>

    init(stub: Bool = false) {
        if stub {
            provider = MoyaProvider<LogDiaryAPI>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            provider = MoyaProvider<LogDiaryAPI>(plugins: [
                NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
            ])
        }
    }

    func getDiary(logId: Int, token: String) -> AnyPublisher<DiaryResponseDTO, Error> {
        provider.requestPublisher(.getDiary(logId: logId, token: token))
            .handleEvents(receiveOutput: { res in
                if let t = String(data: res.data, encoding: .utf8) {
                    print("📒 GET diary response:", t)
                }
            })
            .eraseToAnyPublisher()
            .extractData(DiaryResponseDTO.self) // DefaultResponse<T> -> T
            .manageThread()
    }

    func updateDiary(logId: Int, body: DiaryRequestDTO, token: String) -> AnyPublisher<DiaryResponseDTO, Error> {
        provider.requestPublisher(.updateDiary(logId: logId, body: body, token: token))
            .handleEvents(receiveOutput: { res in
                if let t = String(data: res.data, encoding: .utf8) {
                    print("✏️ PUT diary response:", t)
                }
            })
            .eraseToAnyPublisher()
            .extractData(DiaryResponseDTO.self)
            .manageThread()
    }

    func createDiary(logId: Int, body: DiaryRequestDTO, token: String) -> AnyPublisher<DiaryResponseDTO, Error> {
        provider.requestPublisher(.createDiary(logId: logId, body: body, token: token))
            .handleEvents(receiveOutput: { res in
                if let t = String(data: res.data, encoding: .utf8) {
                    print("🆕 POST diary response:", t)
                }
            })
            .eraseToAnyPublisher()
            .extractData(DiaryResponseDTO.self)
            .manageThread()
    }
}
