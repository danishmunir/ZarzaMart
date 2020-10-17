//
//  LandingPopularMenuTableViewCell.swift
//  Gropare
//
//  Created by Danish Munir on 10/10/2020.
//

import UIKit
import SDWebImage

protocol LandingPopularMenuTableViewCellDelegate {
    func addButtonTapped(tag : Int)
    func subtractButtonTapped(tag : Int)
    func countButtonTapped(tag : Int)
    
}

class LandingPopularMenuTableViewCell: UITableViewCell {
    
    //MARK: - Closures
    var tapBlock : (()-> Void)? = nil
    var addNumber: (()-> Void)? = nil
    var decreaseNumber: (() -> Void)? = nil
    
    @IBOutlet weak var imgBackView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var countButton: UIButton!
    @IBOutlet weak var subtractButton: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var discriptionLbl: UILabel!
    @IBOutlet weak var quatityLbl: UILabel!
    @IBOutlet weak var kgLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var cancelPriceLbl: UILabel!
    
    var number = Int()
    var countTap: Int = 1
    var  delegate : LandingPopularMenuTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        imgBackView.layer.cornerRadius = 5
        mainView.layer.cornerRadius = 5
        addButton.layer.cornerRadius = 3
        countButton.layer.cornerRadius = 3
        subtractButton.layer.cornerRadius = 3
    }
    
    func configureCell(products: Products_Data)  {
        
        productNameLbl.text = products.productName
        discriptionLbl.text = products.datumDescription
        quatityLbl.text = "\(products.quantity ?? 0)"
        kgLbl.text = products.unit
        cancelPriceLbl.text = "\(products.mrp ?? 0)"
        let imageUrl = URL(string : Endpoints.ImgBaseUrl +  UnwarppingValue(value: products.productImage))
        imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
        
        
    }
    
    func Search_VarientConfigureCell(products: Search_Varient)  {
        
        productNameLbl.text = products.varientDescription
        discriptionLbl.text = products.varientDescription
        quatityLbl.text = "\(products.quantity ?? 0)"
        kgLbl.text = products.unit?.rawValue
        cancelPriceLbl.text = "\(products.mrp ?? 0)"
        let imageUrl = URL(string : Endpoints.ImgBaseUrl +  UnwarppingValue(value: products.varientImage))
        imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
        
        
    }
    
    
    
    func varientconfigureCell(products: productVarients_Data)  {
        
        productNameLbl.text = products.datumDescription
        discriptionLbl.text = products.datumDescription
        quatityLbl.text = "\(products.quantity ?? 0)"
        kgLbl.text = products.unit
        cancelPriceLbl.text = "\(products.mrp ?? 0)"
        let imageUrl = URL(string : Endpoints.ImgBaseUrl +  UnwarppingValue(value: products.varientImage))
        imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
        
        
    }
    
    func configureCellByCatagoryProducts(products: CatagoryProducts_Datum)  {
        
        productNameLbl.text = products.productName
        discriptionLbl.text = products.datumDescription
        quatityLbl.text = "\(products.quantity ?? 0)"
        kgLbl.text = products.unit.rawValue
        priceLbl.text = "\(products.price ?? 0)"
        cancelPriceLbl.text = "\(products.mrp ?? 0)"
        let imageUrl = URL(string : Endpoints.ImgBaseUrl +  UnwarppingValue(value: products.productImage))
        imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
        
        
    }
    func configureCellByCart(products: CartItems_Datum)  {
        
        productNameLbl.text = products.productName
        discriptionLbl.text = ""
        quatityLbl.text = "\(products.quantity ?? 0)"
        kgLbl.text = products.unit
        priceLbl.text = "\(products.price ?? 0)"
        cancelPriceLbl.text = ""
        let imageUrl = URL(string : Endpoints.ImgBaseUrl +  UnwarppingValue(value: products.varientImage))
        imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
        addButton.isHidden = true
        subtractButton.isHidden = true
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addButtontapped(_ sender: UIButton) {
        addNumber?()
    }
    @IBAction func countButtonTapped(_ sender: UIButton) {
        tapBlock?()
        
    }
    @IBAction func subtractButtonTapped(_ sender: UIButton) {
       decreaseNumber?()
    }
    
    
}
