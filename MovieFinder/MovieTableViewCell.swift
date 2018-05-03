//
//  MovieTableViewCell.swift
//  MovieFinder
//
//  Created by Razvan Julian on 30/04/2018.
//  Copyright © 2018 Razvan Julian. All rights reserved.
//

import UIKit
import Foundation
import SnapKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var releaseYearLabel: UILabel!
    @IBOutlet var averageVoteLabel: UILabel!
    @IBOutlet var overViewLabel: UILabel!
    
    let rowHeight: CGFloat = 200
    let rowWidth = UIScreen.main.bounds.width

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.frame = CGRect(x: 0, y: 0, width: rowWidth, height: rowHeight)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.gray
        selectedBackgroundView = backgroundView
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.clipsToBounds = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.clipsToBounds = true
        
        releaseYearLabel.translatesAutoresizingMaskIntoConstraints = false
        releaseYearLabel.clipsToBounds = true
        
        averageVoteLabel.translatesAutoresizingMaskIntoConstraints = false
        averageVoteLabel.clipsToBounds = true
        averageVoteLabel.layer.cornerRadius = 10
        averageVoteLabel.textAlignment = NSTextAlignment.center
        
        
        overViewLabel.translatesAutoresizingMaskIntoConstraints = false
        overViewLabel.clipsToBounds = true
        overViewLabel.numberOfLines = 0
        overViewLabel.sizeToFit()
        
        setupConstraints()
    }
    
    
    func setupConstraints() {
        
        self.contentView.addSubview(posterImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(releaseYearLabel)
        self.contentView.addSubview(averageVoteLabel)
        self.contentView.addSubview(overViewLabel)
        
        
        posterImageView.snp.makeConstraints { (make) in
            make.top.bottom.left.equalTo(contentView).offset(10)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.topMargin).offset(10)
            make.left.equalTo(posterImageView.snp.rightMargin).offset(10)
        }

        releaseYearLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottomMargin).offset(15)
            make.left.equalTo(titleLabel)
        }

        averageVoteLabel.snp.makeConstraints { (make) in
            
            let averageVoteLabelWidth = averageVoteLabel.intrinsicContentSize.width
            let newAverageVoteLabelWidth = averageVoteLabelWidth + 0.2 * averageVoteLabelWidth
            
            make.top.equalTo(titleLabel.snp.bottomMargin).offset(15)
            make.left.equalTo(releaseYearLabel.snp.rightMargin).offset(30)
            make.width.equalTo(newAverageVoteLabelWidth)
        }

        overViewLabel.snp.makeConstraints { (make) in
            make.top.equalTo(averageVoteLabel.snp.bottomMargin).offset(15)
            make.left.equalTo(titleLabel)
            make.right.equalTo(contentView.snp.rightMargin).inset(5)
            make.bottom.equalTo(contentView.snp.bottomMargin).inset(10)
        }
    }
    
}
