//
//  NewsFactory.swift
//  Cryptocurrencys
//
//  Created by Rilwanul Huda on 13/07/21.
//

import Foundation

class NewsFactory {
    static func setup(parameters: [String: Any] = [:]) -> NewsViewController {
        let manager = NewsManager(networkService: NetworkService.share)
        let viewModel = NewsViewModel(manager: manager)
        let controller = NewsViewController(viewModel: viewModel)
        let router = NewsRouter(view: controller)

        viewModel.delegate = controller
        viewModel.parameters = parameters
        controller.router = router
        return controller
    }
}
