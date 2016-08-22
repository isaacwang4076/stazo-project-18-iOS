//
//  UserTableViewCell.swift
//  project-18
//
//  Created by Isaac Wang on 8/21/16.
//  Copyright © 2016 stazo. All rights reserved.
//

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}