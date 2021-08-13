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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(apGroupNameText)
        print(addressDongText)
        print(addressDetailText)
        APGroupName.text = apGroupNameText
    }
}
