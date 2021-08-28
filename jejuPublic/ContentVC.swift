//
//  SearchVC.swift
//  jejuPublic
//
//  Created by Hyun on 2021/08/11.
//
import GoogleMobileAds
import Foundation
import UIKit

class ContentVC: UIViewController{
    @IBOutlet var apGroupName: UILabel!
    @IBOutlet var addressDetail: UILabel!
    @IBOutlet var addressDong: UILabel!
    @IBOutlet var macAddress: UILabel!
    
    var apGroupNameText = "공공와이파이"
    var addressDetailText = "상세주소"
    var addressDongText = "행정구역"
    var macAddressText = ""
    
//    private let bannerView: GADBannerView = {
//        let banner = GADBannerView()
//        banner.adUnitID = "ca-app-pub-8323432995434914/9299069359"
//        banner.load(GADRequest())
//        banner.backgroundColor = .secondarySystemBackground
//        return banner
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("start viewDidLoad()")
        
        self.apGroupName.text = apGroupNameText
        self.addressDong.text = addressDongText
        self.addressDetail.text = addressDetailText
        self.macAddress.text = macAddressText
        
//        bannerView.rootViewController = self
//        view.addSubview(bannerView)
    }
    
    func updateView(_ text1:String, _ text2:String, _ text3:String, _ text4:String) {
        self.apGroupName.text = text1
        self.addressDong.text = text2
        self.addressDetail.text = text3
        self.macAddress.text = text4
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        bannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-50, width: view.frame.size.width, height: 50).integral
//    }
    
}
