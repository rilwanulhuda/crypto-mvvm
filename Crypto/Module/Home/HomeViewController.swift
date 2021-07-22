//
//  HomeViewController.swift
//  Cryptocurrencys
//
//  Created by Rilwanul Huda on 13/07/21.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var homeTableView: UITableView!
    
    let viewModel: HomeViewModel
    var router: IHomeRouter?
    var loadingView: LoadingView!
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refreshTopList), for: .valueChanged)
        return rc
    }()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponent()
        getTopList()
    }
    
    private func setupComponent() {
        title = "Top List"
        homeTableView.refreshControl = refreshControl
        homeTableView.registerCellType(TopListTableViewCell.self)
        
        loadingView = LoadingView()
        loadingView.setup(in: contentView)
        loadingView.reloadButton.touchUpInside(self, action: #selector(getTopList))
    }
    
    @objc private func getTopList() {
        loadingView.start { [weak self] in
            guard let self = self else { return }
            self.viewModel.getTopList()
        }
    }
    
    @objc private func refreshTopList() {
        viewModel.getTopList()
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func didSuccessGetTopList() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }

        homeTableView.reloadData()
        loadingView.stop()
        
        viewModel.sendSubscription(action: .subscribe)
    }
    
    func didFailGetTopList(errorMsg: String) {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            Toast.share.show(message: errorMsg)
        } else {
            loadingView.stop(isFailed: true, message: errorMsg)
        }
    }
    
    func didSuccessLoadMoreTopList() {
        homeTableView.performBatchUpdates({
            self.homeTableView.insertRows(at: viewModel.indexPaths, with: .top)
        }, completion: nil)
        
        viewModel.sendSubscription(action: .subscribe)
    }
    
    func didFailLoadMoreTopList(errorMsg: String) {
        Toast.share.show(message: errorMsg)
    }

    func refreshCoin(at indexPath: IndexPath) {
        homeTableView.reloadRows(at: [indexPath], with: .fade)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.topListCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(TopListTableViewCell.self, for: indexPath)
        let coin = viewModel.topListCoins[indexPath.row]
        cell.setupView(coin: coin)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.topListCoins.count - 1 {
            if viewModel.couldLoadMore() {
                viewModel.loadMoreTopList()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let symbol = viewModel.topListCoins[indexPath.row].symbol
        router?.showNews(of: symbol)
    }
}
