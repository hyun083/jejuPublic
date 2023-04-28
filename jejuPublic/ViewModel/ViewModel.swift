//
//  ViewModel.swift
//  jejuPublic
//
//  Created by Hyun on 2022/07/04.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

class ViewModel{
    
    let wifiModel = Observable.range(start: 1, count: 29)
        .retry(3)
        .flatMap{APIManager().getWifiModels(number: $0, baseDate: "20230419")}
    
    let apGroupNameText = BehaviorSubject(value: NSLocalizedString("AP_name", comment: ""))
    let addressDetailText = BehaviorSubject(value: NSLocalizedString("address_detail", comment: ""))
    let addressDongText = BehaviorSubject(value: NSLocalizedString("address_admin", comment: ""))
    
    func setUserAddress(to location:CLLocation){
        let findLocation = location
        let locale = Locale(identifier: "ko_KR")
        let geocoder = CLGeocoder()
        var userAddress: String = ""
        
        //지오코더 사용 국가체계에 맞는 주소정보를 반환해준다.
        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: {(placemarks, error) -> Void in
            if let address: [CLPlacemark] = placemarks {
                //행정구역 ex)경기도,경상도,강원도...
                if let adminArea: String = address.last?.administrativeArea{
                    userAddress += adminArea
                }
                //도시 ex)제주시, 서귀포시...
                if let area: String = address.last?.locality{
                    userAddress += " " + area
                }
                //읍면동
                if let subArea: String = address.last?.subLocality{
                    userAddress += " " + subArea
                }
                print("[viewModel]: 사용자 현재위치 주소 \(userAddress)")
                
                self.apGroupNameText.on(.next(NSLocalizedString("user_location", comment: "")))
                self.addressDetailText.on(.next(userAddress))
                self.addressDongText.on(.next(""))
            }
        })
    }
}
