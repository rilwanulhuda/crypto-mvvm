//
//  HomeViewModel.swift
//  Crypto
//
//  Created by Rilwanul Huda on 22/07/21.
//

import Foundation
import Starscream

protocol HomeViewModelDelegate {
    func didSuccessGetTopList()
    func didFailGetTopList(errorMsg: String)
    func didSuccessLoadMoreTopList()
    func didFailLoadMoreTopList(errorMsg: String)
    func refreshCoin(at indexPath: IndexPath)
}

class HomeViewModel {
    let manager: IHomeManager
    var delegate: HomeViewModelDelegate?
    var wsService: IWSService?
    var page: Int = 1
    var coinsCount: Int = 0
    var currentCoinsCount: Int = 0
    var subscriptions: [String] = []
    var isWsConnected: Bool = false
    var topListCoins: [TopListModel] = []
    var indexPaths: [IndexPath] = []

    init(manager: IHomeManager, wsService: IWSService?) {
        self.manager = manager
        self.wsService = wsService
        self.wsService?.delegate = self
    }

    func getTopList() {
        sendSubscription(action: .unsubscribe)

        page = 1
        coinsCount = 0
        currentCoinsCount = 0
        let model = TopListRequestModel(page: page)

        manager.getTopList(model: model, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let successReponse):
                if let data = successReponse.data, data.count > 0 {
                    self.topListCoins = data.compactMap { TopListModel(data: $0) }
                    self.coinsCount = successReponse.metadata?.count ?? 0
                    self.subscriptions = []

                    for coin in self.topListCoins {
                        let sub = "2~Coinbase~\(coin.symbol)~USD"
                        self.subscriptions.append(sub)
                    }

                    self.delegate?.didSuccessGetTopList()
                } else {
                    self.delegate?.didFailGetTopList(errorMsg: Messages.noCoinsFound)
                }
            case .failure(let errorMsg):
                self.delegate?.didFailGetTopList(errorMsg: errorMsg)
            }
        })
    }

    func couldLoadMore() -> Bool {
        return currentCoinsCount < coinsCount
    }

    func loadMoreTopList() {
        page += 1
        let model = TopListRequestModel(page: page)

        manager.getTopList(model: model, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let successResponse):
                if let data = successResponse.data, data.count > 0 {
                    let newsCoins = data.compactMap { TopListModel(data: $0) }
                    self.indexPaths = []

                    for x in 0 ..< newsCoins.count {
                        let indexPath: IndexPath = [0, self.topListCoins.count + x]
                        self.indexPaths.append(indexPath)
                    }

                    for coin in newsCoins {
                        let sub = "2~Coinbase~\(coin.symbol)~USD"
                        self.subscriptions.append(sub)
                    }

                    self.topListCoins += newsCoins
                    self.delegate?.didSuccessLoadMoreTopList()
                }
            case .failure(let errorMsg):
                self.delegate?.didFailLoadMoreTopList(errorMsg: errorMsg)
            }
        })
    }

    func sendSubscription(action: SubActionType) {
        wsService?.sendSubscription(action: action, subscriptions: subscriptions)
    }
}

extension HomeViewModel: WSServiceDelegate {
    func didUpdateConnectionStatus(isConnected: Bool) {
        sendSubscription(action: .subscribe)
    }

    func didReceiveTickerResponse(response: TickerResponseModel) {
        for i in 0 ..< topListCoins.count {
            let coin = topListCoins[i]
            if coin.symbol == response.symbol {
                let indexPath: IndexPath = [0, i]
                let updatedCoin = TopListModel(id: coin.id,
                                               symbol: coin.symbol,
                                               fullname: coin.fullname,
                                               price: response.price,
                                               openPrice: coin.openPrice)
                topListCoins[i] = updatedCoin
                delegate?.refreshCoin(at: indexPath)

                print("\(String(describing: coin.openPrice))\n\(response)\n\(updatedCoin)\n")
                break
            }
        }
    }
}
