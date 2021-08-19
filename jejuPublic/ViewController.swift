//
//  ViewController.swift
//  jejuPublic
//
//  Created by Hyun on 2021/07/22.
//

import UIKit
import MapKit
import SwiftUI

import FloatingPanel

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FloatingPanelControllerDelegate{

    @IBOutlet var mapView: MKMapView!
    
    var fpc: FloatingPanelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlrequest(count: 1)
        
        mapView.delegate = self
//        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        fpc = FloatingPanelController()
        
        fpc.delegate = self
        
        let contentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ContentVC")
        fpc.set(contentViewController: contentVC)
        
        fpc.addPanel(toParent: self)
        floatingPaneldesign()
        
    }
    
    func floatingPaneldesign(){
        let appearance = SurfaceAppearance()
        
        appearance.cornerRadius = 15.0
        appearance.backgroundColor = .clear
        
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        appearance.shadows = [shadow]
        
        fpc.surfaceView.appearance = appearance
    }
    
    //위치이동 함수, 위도 경도의 자료형은 CLLocationDegrees이다.
    func makePin(_ lat:CLLocationDegrees, _ long:CLLocationDegrees, _ apName:String, _ installLocation:String, _ addressDong:String, _ addressDetail:String, _ macAddress:String){
        
        //좌표 설정
        let pLoc = CLLocationCoordinate2DMake(lat, long)
//        //배율 설정
//        let pZoom = MKCoordinateSpan(latitudeDelta:0.01, longitudeDelta: 0.01)
//        //지역 설정
//        let pRegion = MKCoordinateRegion(center: pLoc, span: pZoom)
//
//        //지도에 설정해놓은 지역 그리기
//        mapView.setRegion(pRegion, animated: false)
        
        //표시할 핀 생성
        let pin = EventAnnotation()
        
        //핀 이름 적기
        pin.title = apName
        pin.subtitle = installLocation
        pin.addressDong = addressDong
        pin.addressDetail = addressDetail
        pin.macAddress = macAddress
        
        //핀에 좌표넣기
        pin.coordinate = pLoc
        
        //지도에 핀 그리기
        mapView.addAnnotation(pin)
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        if let eventAnnotation = view.annotation as? EventAnnotation{
            print("\(eventAnnotation.title)핀이 눌렸습니다.")
            if let contentVC = fpc.contentViewController as? ContentVC{
                contentVC.updateView(eventAnnotation.title!, eventAnnotation.addressDong, eventAnnotation.addressDetail, eventAnnotation.macAddress)
            }
        }
    }
    
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard !(annotation is MKUserLocation) else{
//            return nil
//        }
//
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
//        if annotationView == nil{
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
//            annotationView?.canShowCallout = true
//
//        }else{
//            annotationView?.annotation = annotation
//        }
//        annotationView?.image = UIImage(named: "wifiPin")
//        return annotationView
//    }
    
    func urlrequest(count: Int) {
        for i in count...63{
            //api 주소
            let url = URL(string: "https://open.jejudatahub.net/api/proxy/Dtb18ta1btbD1Da1a81aaDttab6tDabb/b5eo8oep8e5_t58_15b81tc8tc2t_5jj?number="+String(i)+"&limit=100")!
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else {return}
                
                let response = response as? HTTPURLResponse
                
                //응답코드가 200(요청완료)일 경우
                if response?.statusCode == 200{
                    let jsonString = (String(data: data, encoding: .utf8)!)
                    
                    let jsonDataT:Data? = jsonString.data(using: .utf8)
                    
                    if let jsonData =  jsonDataT{
                        var jsonDicT:[String:Any]?
                        jsonDicT = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any]
                        
                        if let jsonDic = jsonDicT{
                            print(i, jsonDic["hasMore"]! as! Bool)
                            
                            if let dataArr = jsonDic["data"] as? [[String:Any]]{
                                for data in dataArr{
                                    let location = CLLocationCoordinate2DMake((data["latitude"] as! NSString).doubleValue,(data["longitude"] as! NSString).doubleValue)
                                    let apName = data["apGroupName"] as! String
                                    let installlocation = data["installLocationDetail"] as! String
                                    
                                    //iu변경은 메인스레드에서 작업!
                                    DispatchQueue.main.async {
                                        self.makePin(location.latitude, location.longitude, apName, installlocation,data["addressDong"] as! String, data["addressDetail"] as! String, data["macAddress"] as! String)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }
}

