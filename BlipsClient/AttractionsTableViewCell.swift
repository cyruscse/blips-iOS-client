//
//  AttractionsTableViewCell.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-10.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class AttractionsTableViewCell: UITableViewCell {
    @IBOutlet weak var attractionName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
