//
//  SearchVC.swift
//  jejuPublic
//
//  Created by Hyun on 2021/08/11.
//

import Foundation
import UIKit

class SearchVC: UIViewController{
    @IBOutlet weak var APGroupName: UILabel!
    @IBOutlet weak var addressDong: UILabel!
    @IBOutlet weak var addressDetail: UILabel!
    
    var apGroupNameText = "선택된 핀"
    var addressDongText = "행정구역"
    var addressDetailText = "상세주소"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.APGroupName.text = apGroupNameText
        self.addressDong.text = addressDongText
        self.addressDetail.text = addressDetailText
        
        print(apGroupNameText)
        print(addressDongText)
        print(addressDetailText)
    }
    
    @IBAction func updateButton(_ sender: UIButton) {
        self.APGroupName.text = "테스트1"
        self.addressDong.text = "테스트2"
        self.addressDetail.text = "테스트3"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(apGroupNameText)
        print(addressDongText)
        print(addressDetailText)
        
    }
    
    func updateView(_ text1:String, _ text2:String, _ text3:String) {
        self.APGroupName.text = text1 as String
        self.addressDong.text = text2 as String
        self.addressDetail.text = text3 as String
    }
    
    
}
