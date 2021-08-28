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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("start viewDidLoad()")
        
        self.apGroupName.text = apGroupNameText
        self.addressDong.text = addressDongText
        self.addressDetail.text = addressDetailText
        self.macAddress.text = macAddressText
        
    }
    
    func updateView(_ text1:String, _ text2:String, _ text3:String, _ text4:String) {
        self.apGroupName.text = text1
        self.addressDong.text = text2
        self.addressDetail.text = text3
        self.macAddress.text = text4
    }
    
}
