//
//  NotificationTableViewCell.swift
//  Gropare
//
//  Created by Danish Munir on 13/10/2020.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var HeaderLAbel: UILabel!
    
    @IBOutlet weak var descriptionLAbel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
