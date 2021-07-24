//
//  NewsViewController.swift
//  Crypto
//
//  Created by Rilwanul Huda on 22/07/21.
//

//
//  NewsViewController.swift
//  Cryptocurrencys
//
//  Created by Rilwanul Huda on 13/07/21.
//

import UIKit

class NewsViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var newsTableView: UITableView!
    
    var viewModel: NewsViewModel
    var router: INewsRouter?
    var loadingView: LoadingView!
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        return rc
    }()
    
    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponent()
        getNews()
    }
    
    private func setupComponent() {
        newsTableView.refreshControl = refreshControl
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissView))
        newsTableView.registerCellType(NewsTableViewCell.self)
        
        let symbol = viewModel.symbol
        title = symbol != nil ? "\(symbol!) News" : "Crypto News"
        
        loadingView = LoadingView()
        loadingView.setup(in: contentView)
        loadingView.reloadButton.touchUpInside(self, action: #selector(getNews))
    }
    
    @objc private func getNews() {
        loadingView.start { [weak self] in
            guard let self = self else { return }
            self.viewModel.getNews()
        }
    }
    
    @objc func refreshNews() {
        viewModel.getNews()
    }
    
    @objc func dismissView() {
        dismiss()
    }
}
    
extension NewsViewController: NewsViewModelDelegate {
    func didSuccessGetNews() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        newsTableView.reloadData()
        loadingView.stop()
    }
    
    func didFailGetNews(errorMsg message: String) {
        if refreshControl.isRefreshing {
            Toast.share.show(message: message) { [weak self] in
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
            }
        } else {
            loadingView.stop(isFailed: true, message: message)
        }
    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(NewsTableViewCell.self, for: indexPath)
        let news = viewModel.news[indexPath.row]
        cell.setupView(news: news)
        
        cell.handleUpdateCell = {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = viewModel.news[indexPath.row]
        print(news)
    }
}
