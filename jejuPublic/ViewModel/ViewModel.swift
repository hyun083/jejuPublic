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
    let wifiModel = Observable.range(start: 1, count: 22)
        .flatMap{APIManager().getWifiModels(number: $0, baseDate: 20200525)}
    
    let apGroupNameText = BehaviorSubject(value: "공공와이파이")
    let addressDetailText = BehaviorSubject(value: "상세주소")
    let addressDongText = BehaviorSubject(value: "행정구역")
    
    func setUserAddress(to location:CLLocation){
        let findLocation = location
        let locale = Locale(identifier: "ko-kr")
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
                
                self.apGroupNameText.on(.next("현재위치"))
                self.addressDetailText.on(.next(userAddress))
                self.addressDongText.on(.next(""))
            }
        })
    }
}
