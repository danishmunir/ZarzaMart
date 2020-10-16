//
//  LandingBannerCollectionViewCell.swift
//  Gropare
//
//  Created by Danish Munir on 09/10/2020.
//

import UIKit

class LandingBannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = 5
    }

}
