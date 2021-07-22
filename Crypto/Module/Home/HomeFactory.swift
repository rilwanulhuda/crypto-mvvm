//
//  HomeFactory.swift
//  Crypto
//
//  Created by Rilwanul Huda on 22/07/21.
//

import Foundation

class HomeFactory {
    static func setup() -> HomeViewController {
        let manager = HomeManager(networkService: NetworkService.share)
        let viewModel = HomeViewModel(manager: manager)
        let controller = HomeViewController(viewModel: viewModel)
        let router = HomeRouter(view: controller)

        viewModel.delegate = controller
        controller.router = router
        return controller
    }
}
