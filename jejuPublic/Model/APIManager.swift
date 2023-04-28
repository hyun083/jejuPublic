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
    // MARK: - apiModel
    struct APIModel: Codable {
        let totCnt: Int
        let hasMore: Bool
        let data: [Datum]
    }
    
    // MARK: - Datum
    struct Datum: Codable {
        let baseDate: String
    }
    
    let JEJU_URL = URL(string: "https://open.jejudatahub.net/api/proxy/Dtb18ta1btbD1Da1a81aaDttab6tDabb/b5eo8oep8e5_t58_15b81tc8tc2t_5jj")
    
    func getWifiModels(number: Int, baseDate: String) -> Observable<[JejuWifiAnnotation]> {
        RxAlamofire
            .request(.get, JEJU_URL!,parameters: ["number":number,"limit":100,"baseDate": baseDate])
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
                    annotation.title = self.makeSimple(from: (data["apGroupName"] as? String))
                    annotation.subtitle = data["installLocationDetail"] as? String
                    annotation.addressDong = data["addressDong"] as? String
                    annotation.addressDetail = data["addressDetail"] as? String
                    
                    annotations.append(annotation)
                }
                print("[APIManager]:","##",baseDate,"##",number,"requested","\(annotations.count) returned")
                return annotations
            }
    }
    
    func makeSimple(from str:String?) -> String{
        var tmp = [String]()
        
        if let str = str{
            tmp = str.split(separator: "[").map{String($0)}
            tmp = tmp[0].split(separator: "_").map{String($0)}
        }else{
            tmp.append("정보없음")
        }
        
        return tmp.joined(separator: " ")
    }
    
    func getBaseDate() -> String{
        var result = "initial"
        var run = true
        
        if let url = JEJU_URL{
            let session = URLSession(configuration: .default)
            var requestURL = URLRequest(url: url)
            requestURL.addValue("1", forHTTPHeaderField: "limit")
            requestURL.addValue("1", forHTTPHeaderField: "number")
            
            let dataTask = session.dataTask(with: requestURL) {(data, response, error) in
                if let resultData = data{
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(APIModel.self, from: resultData)
                        let data = response.data
                        for d in data{
                            result = d.baseDate
                            print(d.baseDate,"@@@@")
                        }
                    } catch let error {
                        print("--> error: \(error.localizedDescription)")
                    }
                }
                run = false
            }
            
            dataTask.resume()
            
            while run {
                
            }
        }
        return result
    }
    
    func getTotCnt(from baseDate:Int) -> Int{
        var totCnt = 0
        RxAlamofire
            .request(.get, JEJU_URL!,parameters: ["limit":1,"baseDate":baseDate])
            .validate(statusCode: 200..<300)
            .responseJSON()
            .map{ try JSONSerialization.jsonObject(with:$0.data!, options: []) as! [String:Any] }
            .map{ totCnt = ($0["totCnt"] as! NSString).integerValue}
        return totCnt
    }
}


