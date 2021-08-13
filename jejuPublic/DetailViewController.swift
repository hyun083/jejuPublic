//
//  DetailViewController.swift
//  jejuPublic
//
//  Created by Hyun on 2021/07/29.
//

import Foundation
import UIKit
import PanModal

class DetailViewController: UIViewController{
    @IBOutlet var label1: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
extension DetailViewController: PanModalPresentable{
    var panScrollable: UIScrollView? {
        return nil
    }
    
    //접힌상태
    var shortFormHeight: PanModalHeight {
        return .contentHeight(100)
    }

    //완전히 펼친 상태
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(500)
    }
    
    var anchorModalToLongForm: Bool{
        //true 최상단까지 스크롤 안함
        //false 최상단까지 스크롤
        return true
    }
}

