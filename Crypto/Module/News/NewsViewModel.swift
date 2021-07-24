//
//  NewsViewModel.swift
//  Crypto
//
//  Created by Rilwanul Huda on 22/07/21.
//

import Foundation

protocol NewsViewModelDelegate {
    func didSuccessGetNews()
    func didFailGetNews(errorMsg: String)
}

class NewsViewModel {
    let manager: INewsManager
    var delegate: NewsViewModelDelegate?
    var news: [NewsModel] = []
    var parameters: [String: Any]?

    init(manager: INewsManager) {
        self.manager = manager
    }

    var symbol: String? {
        return parameters?["symbol"] as? String
    }

    func getNews() {
        let model = NewsRequestModel(categories: symbol)

        manager.getNews(model: model, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let successResponse):
                if let data = successResponse.data, data.count > 0 {
                    self.news = data.compactMap { NewsModel(data: $0) }
                    self.delegate?.didSuccessGetNews()
                } else {
                    self.delegate?.didFailGetNews(errorMsg: Messages.noNewsFound)
                }

            case .failure(let errorMsg):
                self.delegate?.didFailGetNews(errorMsg: errorMsg)
            }
        })
    }
}
