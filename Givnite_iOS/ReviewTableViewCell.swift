//
//  ReviewTableViewCell.swift
//  Givnite
//
//  Created by Danny Tan on 8/1/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewerImageView: UIImageView!
    @IBOutlet weak var reviewerNameLabel: UILabel!
    @IBOutlet weak var reviewerSchoolLabel: UILabel!
    @IBOutlet weak var reviewerDateLabel: UILabel!
    @IBOutlet weak var reviewerReviewTextView: UITextView!
    
    var reviewer: Reviewer? {
        didSet {
            reviewerNameLabel.text = reviewer?.name
            reviewerSchoolLabel.text = reviewer?.school
            reviewerDateLabel.text = reviewer?.reviewDate
            reviewerReviewTextView.text = reviewer?.review
            
            setUserImage()
            
        }
    }
    


    func setUserImage() {
        var imageUrlString: String?
        if let imageUrl = reviewer?.picture {
            imageUrlString = imageUrl
            let url = NSURL(string: imageUrl)
            self.reviewerImageView.image = nil
            if let imageFromCache = NSCache.sharedInstance.objectForKey(imageUrl) as? UIImage {
                self.reviewerImageView.image = imageFromCache
                return
            }
            
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error)
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    let imageToCache = UIImage(data: data!)
                    
                    if (imageUrlString == imageUrl) {
                        self.reviewerImageView.image = imageToCache
                    }
                    NSCache.sharedInstance.setObject(imageToCache!, forKey: imageUrl)
                })
            }).resume()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.reviewerImageView.layer.cornerRadius = self.reviewerImageView.frame.size.width/2
        self.reviewerImageView.clipsToBounds = true
        
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
