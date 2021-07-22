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
    var webSocket: WebSocket?
    var page: Int = 1
    var coinsCount: Int = 0
    var currentCoinsCount: Int = 0
    var subscriptions: [String] = []
    var isWsConnected: Bool = false
    var topListCoins: [TopListModel] = []
    var indexPaths: [IndexPath] = []

    init(manager: IHomeManager) {
        self.manager = manager
        setupWebSocket()
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

    func setupWebSocket() {
        var request = URLRequest(url: URL(string: APIConstant.wsUrlString)!)
        request.timeoutInterval = 5
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }

    func sendSubscription(action: SubActionType) {
        guard !subscriptions.isEmpty, isWsConnected else { return }
        let model = SubscriptionModel(action: action, subscription: subscriptions)
        let json = model.parameters()?.toJSON
        webSocket?.write(string: json!)
    }

    func handleTickerResponse(response: TickerResponseModel) {
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

extension HomeViewModel: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isWsConnected = true
            sendSubscription(action: .subscribe)
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isWsConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")

        case .text(let string):
            guard let dict = string.toDictionary(),
                  let type = dict["TYPE"] as? String, type == "2",
                  let flags = dict["FLAGS"] as? Int, flags == 2 else { return }

            if let symbol = dict["FROMSYMBOL"] as? String, let price = dict["PRICE"] as? Double {
                let tickerResponse = TickerResponseModel(symbol: symbol, price: price)
                handleTickerResponse(response: tickerResponse)
            }

        case .binary(let data):
            print("Receive data: \(data.count)")

        case .pong:
            print("pong")

        case .ping:
            print("ping")

        case .error(let error):
            isWsConnected = false
            print(error?.localizedDescription ?? Messages.generalError)

        case .viabilityChanged:
            print("viabilityChanged")

        case .reconnectSuggested:
            isWsConnected = false
            print("reconnectedSuggested")

        case .cancelled:
            isWsConnected = false
            print("connection cancelled")
        }
    }
}
