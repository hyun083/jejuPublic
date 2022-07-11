//
//  SearchVC.swift
//  jejuPublic
//
//  Created by Hyun on 2021/08/11.
//
import GoogleMobileAds
import Foundation
import UIKit
import RxCocoa
import RxSwift
import GoogleMobileAds
import AdSupport
import AppTrackingTransparency

class InformationViewController: UIViewController{
    @IBOutlet var apGroupName: UILabel!
    @IBOutlet var addressDetail: UILabel!
    @IBOutlet var addressDong: UILabel!
    
    var viewModel = ViewModel()
    var disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[InformationViewController]: viewDidLoad()")
        
        //사용자 맞춤 광고 권한 요청
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2){
            self.requestPermission()
        }
        
        //구글 애드몹생성
        bannerView.rootViewController = self
        view.addSubview(bannerView)
        
        //UI바인딩
        bindUI()
    }
    
    func bindUI(){
        viewModel.apGroupNameText
            .bind(to: apGroupName.rx.text)
            .disposed(by: disposebag)
        
        viewModel.addressDetailText
            .bind(to: addressDetail.rx.text)
            .disposed(by: disposebag)
        
        viewModel.addressDongText
            .bind(to: addressDong.rx.text)
            .disposed(by: disposebag)
    }
    
    //MARK: - googleAdmob
    
    //IDFA 요청
    func requestPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                // Tracking authorization dialog was shown
                // and we are authorized
                print("[googleAdmob]: Authorized")
                // Now that we are authorized we can get the IDFA
                print(ASIdentifierManager.shared().advertisingIdentifier)
            case .denied:
                // Tracking authorization dialog was
                // shown and permission is denied
                print("[googleAdmob]: Denied")
            case .notDetermined:
                // Tracking authorization dialog has not been shown
                print("[googleAdmob]: Not Determined")
            case .restricted: print("[googleAdmob]: Restricted")
            @unknown default: print("[googleAdmob]: Unknown")
            }
        }
    }
    
    //배너형태의 admob 생성
    private let bannerView: GADBannerView = {
        let banner = GADBannerView()
        //testID: ca-app-pub-3940256099942544/6300978111
        banner.adUnitID = "ca-app-pub-8323432995434914/9299069359"
        banner.load(GADRequest())
        banner.backgroundColor = .secondarySystemBackground
        return banner
    }()
    
    //배너의 좌표와 크기 설정
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bannerView.frame = CGRect(x: 0, y: 175, width: view.frame.size.width, height: 50).integral
    }
}
