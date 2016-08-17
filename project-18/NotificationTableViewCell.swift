//
//  NotificationTableViewCell.swift
//  project-18
//
//  Created by Isaac Wang on 8/8/16.
//  Copyright © 2016 stazo. All rights reserved.
//

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var notifImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
         // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}