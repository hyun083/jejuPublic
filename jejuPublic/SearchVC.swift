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
    var addressDongText = "관할구역"
    var addressDetailText = "상세주소"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("start viewDidLoad()")
        
        self.APGroupName.text = apGroupNameText
        self.addressDong.text = addressDongText
        self.addressDetail.text = addressDetailText
    }
    
    func updateView(_ text1:String, _ text2:String, _ text3:String) {
        self.APGroupName.text = text1
        self.addressDong.text = text2
        self.addressDetail.text = text3
    }
    
    
}
