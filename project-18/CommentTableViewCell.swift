//
//  CommentTableViewCell.swift
//  project-18
//
//  Created by Eric Zhang on 7/30/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet var commentImage: UIImageView!
    @IBOutlet var commentName: UILabel!
    @IBOutlet var commentText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
