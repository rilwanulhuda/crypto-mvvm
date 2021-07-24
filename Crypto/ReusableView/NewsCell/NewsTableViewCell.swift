//
//  NewsTableViewCell.swift
//  Crypto
//
//  Created by Rilwanul Huda on 22/07/21.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    var handleUpdateCell: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBodyLabel))
        bodyLabel.addGestureRecognizer(tap)
        bodyLabel.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupView(news: NewsModel) {
        sourceLabel.text = news.source
        titleLabel.text = news.title
        bodyLabel.text = news.body
    }
    
    @objc func didTapBodyLabel() {
        let numberOfLines = bodyLabel.numberOfLines
        bodyLabel.numberOfLines = numberOfLines == 0 ? 5 : 0
        
        handleUpdateCell?()
    }
}
