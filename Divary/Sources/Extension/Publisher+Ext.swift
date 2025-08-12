//
//  File.swift
//  Divary
//
//  Created by 김나영 on 8/6/25.
//

import Foundation
import Combine

extension Publisher {
    func sinkHandledCompletion(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        return self.sink(receiveCompletion: handleCompletion, receiveValue: receiveValue)
    }
    
    private func handleCompletion(completion: Subscribers.Completion<Self.Failure>) {
        switch completion {
        case .finished: break
        case .failure(let error):
            NSLog(error.localizedDescription)
        }
    }
    
    func manageThread() -> AnyPublisher<Output, Failure> {
        return self
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
