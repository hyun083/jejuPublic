//
//  APIManager.swift
//  jejuPublic
//
//  Created by Hyun on 2022/07/05.
//

import Foundation
import RxAlamofire
import RxSwift
import RxCocoa
import MapKit

class APIManager{
    let JEJU_URL = URL(string: "https://open.jejudatahub.net/api/proxy/Dtb18ta1btbD1Da1a81aaDttab6tDabb/b5eo8oep8e5_t58_15b81tc8tc2t_5jj")
    
    func getWifiModels(number: Int,baseDate: Int) -> Observable<[JejuWifiAnnotation]> {
        RxAlamofire
            .request(.get, JEJU_URL!,parameters: ["number":number,"limit":100,"baseDate":baseDate])
            .validate(statusCode: 200..<300)
            .responseJSON()
            .map{ try JSONSerialization.jsonObject(with:$0.data!, options: []) as! [String:Any] }
            .map{ $0["data"]!}
            .map{json in
                var annotations = [JejuWifiAnnotation]()
                for data in json as! [[String:Any]]{
                    let annotation = JejuWifiAnnotation()
                    
                    let latitude = (data["latitude"] as! NSString).doubleValue
                    let longitude = (data["longitude"] as! NSString).doubleValue
                    
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    annotation.title = data["apGroupName"] as? String
                    annotation.subtitle = data["installLocationDetail"] as? String
                    annotation.addressDong = data["addressDong"] as? String
                    annotation.addressDetail = data["addressDetail"] as? String
                    
                    annotations.append(annotation)
                }
                print("[APIManager]:",number,"requested")
                return annotations
            }
    }
}
