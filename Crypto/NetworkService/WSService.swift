//
//  WSService.swift
//  Crypto
//
//  Created by Rilwanul Huda on 23/07/21.
//

import Starscream

protocol IWSService: AnyObject {
    var delegate: WSServiceDelegate? { get set }

    func sendSubscription(action: SubActionType, subscriptions: [String])
}

protocol WSServiceDelegate {
    func didUpdateConnectionStatus(isConnected: Bool)
    func didReceiveTickerResponse(response: TickerResponseModel)
}

class WSService: IWSService {
    static let share = WSService()

    private var webSocket: WebSocket?
    var delegate: WSServiceDelegate?

    var isWsConnected: Bool = false {
        didSet {
            if !isWsConnected {
                webSocket?.connect()
            }
            delegate?.didUpdateConnectionStatus(isConnected: isWsConnected)
        }
    }

    init() {
        let urlString = APIConstant.wsUrlString
        var request = URLRequest(url: URL(string: urlString)!)
        request.timeoutInterval = 5
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }

    func sendSubscription(action: SubActionType, subscriptions: [String]) {
        guard !subscriptions.isEmpty, isWsConnected else { return }
        let model = SubscriptionModel(action: action, subscription: subscriptions)
        let json = model.parameters()?.toJSON
        webSocket?.write(string: json!)
    }
}

extension WSService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isWsConnected = true
            print("WSService | websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isWsConnected = false
            print("WSService | websocket is disconnected: \(reason) with code: \(code)")

        case .text(let string):
            guard let dict = string.toDictionary(),
                  let type = dict["TYPE"] as? String, type == "2",
                  let flags = dict["FLAGS"] as? Int, flags == 2 else { return }

            if let symbol = dict["FROMSYMBOL"] as? String, let price = dict["PRICE"] as? Double {
                let tickerResponse = TickerResponseModel(symbol: symbol, price: price)
                delegate?.didReceiveTickerResponse(response: tickerResponse)
            }

        case .binary(let data):
            print("WSService | receive data: \(data.count)")

        case .pong:
            print("WSService | pong")

        case .ping:
            print("WSService | ping")

        case .error(let error):
            isWsConnected = false
            print(error?.localizedDescription ?? Messages.generalError)

        case .viabilityChanged:
            print("WSService | viabilityChanged")

        case .reconnectSuggested:
            isWsConnected = false
            print("WSService | reconnectedSuggested")

        case .cancelled:
            isWsConnected = false
            print("WSService | connection cancelled")
        }
    }
}
