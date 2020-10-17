//
//  ProductTableViewCell.swift
//  Gropare
//
//  Created by Danish Munir on 15/10/2020.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var kg: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var cancelPrice: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var subBtn: UIButton!
    @IBOutlet weak var countBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.shadowRadius = 10
        backView.layer.shadowColor = UIColor.red.cgColor
        backView.layer.cornerRadius = 5
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
}
