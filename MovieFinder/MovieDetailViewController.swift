//
//  MovieDetailViewController.swift
//  MovieFinder
//
//  Created by Razvan Julian on 30/04/2018.
//  Copyright © 2018 Razvan Julian. All rights reserved.
//

import UIKit
import SnapKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var overViewLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var averageVoteLabel: UILabel!
    @IBOutlet var releaseYearLabel: UILabel!
    
    
    enum UIUserInterfaceIdiom : Int {
        case unspecified
        case phone          // iPhone
        case pad            // iPad
    }
    
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = movie.title
        
        backdropImageView.translatesAutoresizingMaskIntoConstraints = false
        backdropImageView.contentMode = .scaleAspectFill
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = "Overview:"
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: contentView.frame.origin.y + contentView.frame.height)
        
        
        averageVoteLabel.translatesAutoresizingMaskIntoConstraints = false
        averageVoteLabel.text = String(format: "%.1f", movie.averageVote ?? 0)
        averageVoteLabel.textAlignment = NSTextAlignment.center
        averageVoteLabel.clipsToBounds = true
        averageVoteLabel.layer.cornerRadius = 10
        
        releaseYearLabel.translatesAutoresizingMaskIntoConstraints = false
        releaseYearLabel.text = movie.releaseYear!
        releaseYearLabel.textAlignment = NSTextAlignment.center
        releaseYearLabel.clipsToBounds = true
        
        overViewLabel.translatesAutoresizingMaskIntoConstraints = false
        overViewLabel.text = movie.overview
        overViewLabel.numberOfLines = 0
        overViewLabel.textAlignment = .center
        overViewLabel.sizeToFit()
        
        if let smallImageURL = movie.backdropImageURLLow, let largeImageURL = movie.backdropImageURLHigh {
            setImage(with: smallImageURL, largeImageURL: largeImageURL)
        } else {
            backdropImageView.image = UIImage(named: "placeholder")
        }
        
        setupConstraints()
    }
    
    
    func setImage(with smallImageURL: URL, largeImageURL: URL) {
        let smallImageRequest = URLRequest(url: smallImageURL)
        self.backdropImageView?.setImageWith(smallImageRequest, placeholderImage: UIImage(named: "placeholder"),
            success: { (_, _, smallImage) in
                self.backdropImageView.alpha = 0.0
                self.backdropImageView.image = smallImage
                UIView.animate(
                    withDuration: 0.3,
                    animations: {self.backdropImageView.alpha = 1.0})
                { _ in self.backdropImageView.setImageWith(largeImageURL) }
        }, failure: { (_, _, error) in
                print(error) })
        
    }
    

    func setupConstraints() {
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(backdropImageView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(overViewLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(averageVoteLabel)
        contentView.addSubview(releaseYearLabel)
        
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        backdropImageView.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView)
            make.left.right.equalTo(view)
            make.height.equalTo(backdropImageView.snp.width).multipliedBy(0.9)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(backdropImageView.snp.bottom)
            make.left.right.equalTo(view)
            make.height.equalTo(contentView.snp.width).multipliedBy(1)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(25)
            make.left.equalTo(backdropImageView.frame.size.width).offset(backdropImageView.frame.size.width * 0.05)
        }
        
        releaseYearLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(UIScreen.main.bounds.size.width / 2)
            make.top.equalTo(titleLabel)
            
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                releaseYearLabel.text = "Release Year: " + releaseYearLabel.text!
            }
            
        }

        averageVoteLabel.snp.makeConstraints { (make) in
            
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                averageVoteLabel.text = "Average Vote: " + averageVoteLabel.text!
            }
            
            let averageVoteLabelWidth = averageVoteLabel.intrinsicContentSize.width
            let newAverageVoteLabelWidth = averageVoteLabelWidth + 0.2 * averageVoteLabelWidth
            
            make.top.equalTo(releaseYearLabel)
            make.height.equalTo(releaseYearLabel)
            make.right.equalTo(backdropImageView.frame.size.width).inset(backdropImageView.frame.size.width * 0.125)
            make.width.equalTo(newAverageVoteLabelWidth)

        }
        
        overViewLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(10)
            make.right.equalTo(contentView).inset(10)
            make.top.equalTo(titleLabel).offset(40)
        }
        
    }

}
