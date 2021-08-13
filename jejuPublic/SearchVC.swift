//
//  SearchVC.swift
//  jejuPublic
//
//  Created by Hyun on 2021/08/11.
//

import Foundation
import UIKit

class SearchVC: UIViewController{
    @IBOutlet var APGroupName: UILabel!
    @IBOutlet var addressDong: UILabel!
    @IBOutlet var addressDetail: UILabel!
    
    var apGroupNameText = "선택된 핀"
    var addressDongText = "행정구역"
    var addressDetailText = "상세주소"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.APGroupName.text = apGroupNameText
        self.addressDong.text = addressDongText
        self.addressDetail.text = addressDetailText
    }
}
