//
//  ConnectionTableViewCell.swift
//  Givnite
//
//  Created by Danny Tan on 7/28/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

//
//  ConnectionTableViewCell.swift
//  Givnite
//
//  Created by Danny Tan on 7/27/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit

class ConnectionTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userSchool: UILabel!
    
    @IBOutlet weak var connectButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

