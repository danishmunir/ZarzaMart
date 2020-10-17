//
//  ViewAllCatagoryViewController.swift
//  Gropare
//
//  Created by Danish Munir on 12/10/2020.
//

import UIKit
import SDWebImage

class ViewAllCatagoryViewController: UIViewController {

    var arrCatagoryExpand = [ExpendCategory_Data]()
    @IBOutlet weak var collectionView: UICollectionView!
    let http = HTTPService()
    override func viewDidLoad() {
        super.viewDidLoad()
        catagoryGetData()
        collectionView.register(UINib(nibName: "LandingCatagoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LandingCatagoryCollectionViewCell")
    }


}


extension ViewAllCatagoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCatagoryExpand.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LandingCatagoryCollectionViewCell", for: indexPath) as! LandingCatagoryCollectionViewCell
        cell.productLabel.text = arrCatagoryExpand[indexPath.row].title
        let imageUrl = URL(string : Endpoints.ImgBaseUrl +  UnwarppingValue(value: arrCatagoryExpand[indexPath.row].image))
        cell.imgViw.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgViw.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let noOfCellsInRow = 3

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "SubCatagoriesViewController") as! SubCatagoriesViewController
        vc.arrSubCatagory = arrCatagoryExpand[indexPath.row].subcategory!
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}


extension ViewAllCatagoryViewController {
    func catagoryGetData() {
        http.getRequest(urlString: Endpoints.expandCatagory) { (response) in
            let jsonData = response?.toJSONString2().data(using: .utf8)
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(ExpendCategory.self, from: jsonData!)
            if obj.status == "1" {
                if let arrayofBanner = obj.data{
                    _ = arrayofBanner.map{
                        self.arrCatagoryExpand.append($0)
                    }
                }
                dump(obj)
                self.collectionView.reloadData()
            }
            else{
                print(obj.message)
            }
        }
    }
}
