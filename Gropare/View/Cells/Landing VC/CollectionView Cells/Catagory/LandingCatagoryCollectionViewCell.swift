//
//  LandingCatagoryCollectionViewCell.swift
//  Gropare
//
//  Created by Danish Munir on 09/10/2020.
//

import UIKit
import SDWebImage


class LandingCatagoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgViw: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgViw.layer.cornerRadius = 5
    }
    
    func configureCell(catagory: TopCategory_Data)  {
        productLabel.text = catagory.title
        let imageUrl = URL(string : Endpoints.ImgBaseUrl +  UnwarppingValue(value: catagory.image))
        imgViw.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgViw.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
        
        
    }

}
