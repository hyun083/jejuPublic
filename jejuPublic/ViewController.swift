//
//  ViewController.swift
//  jejuPublic
//
//  Created by Hyun on 2021/07/22.
//
import GoogleMobileAds
import AdSupport
import AppTrackingTransparency
import UIKit
import MapKit
import SwiftUI
import FloatingPanel

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FloatingPanelControllerDelegate{

    @IBOutlet var mapView: MKMapView!
    var fpc: FloatingPanelController!
    let userLoc = CLLocationManager()
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermission()
        urlrequest(count: 1)
        mapView.delegate = self
        addMapTrackingButton()
        
        fpc = FloatingPanelController(delegate: self)
        let contentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ContentVC")
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: self)
        
        //스크롤이 넘어가면 하단공백이 생기는것 방지
        fpc.contentMode = .fitToBounds

        floatingPaneldesign()
        fpc.layout = CustomFloatingPanelLayout()
        fpc.show()
        
        bannerView.rootViewController = self
        fpc.surfaceView.addSubview(bannerView)
        showUserLocation()

    }
    
    //MARK: - googleAdmob
    //IDFA 가져오기
    func requestPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                // Tracking authorization dialog was shown
                // and we are authorized
                print("Authorized")
                // Now that we are authorized we can get the IDFA
                print(ASIdentifierManager.shared().advertisingIdentifier)
            case .denied:
                // Tracking authorization dialog was
                // shown and permission is denied
                print("Denied") case .notDetermined:
                // Tracking authorization dialog has not been shown
                print("Not Determined")
            case .restricted: print("Restricted")
            @unknown default: print("Unknown")
            }
        }
    }
    
    //배너광고 생성
    private let bannerView: GADBannerView = {
        let banner = GADBannerView()
        //testID: ca-app-pub-3940256099942544/6300978111
        banner.adUnitID = "ca-app-pub-8323432995434914/9299069359"
        banner.load(GADRequest())
        banner.backgroundColor = .secondarySystemBackground
        return banner
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bannerView.frame = CGRect(x: 0, y: 175, width: view.frame.size.width, height: 50).integral
    }
    
    // MARK: - FloatingPanel custom
    
    //floatingPanel 디자인
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
    
    //floatingPanel 스크롤 범위 설정
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if fpc.isAttracting == false{
            let loc = fpc.surfaceLocation
            let minY = fpc.surfaceLocation(for: .half).y - 3.0
            let maxY = fpc.surfaceLocation(for: .tip).y + 3.0
            fpc.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, minY),maxY))
        }
    }
    
    // MARK: - mapView custom

    //핀생성 함수
    func makePin(_ lat:CLLocationDegrees, _ long:CLLocationDegrees, _ apName:String, _ installLocation:String, _ addressDong:String, _ addressDetail:String, _ categoryDetail:String){
        
        //좌표 설정
        let pLoc = CLLocationCoordinate2DMake(lat, long)
        
        //표시할 핀 생성
        let pin = CustomAnnotation()
        
        //핀 정보 기입
        pin.title = apName
        pin.subtitle = installLocation
        pin.addressDong = addressDong
        pin.addressDetail = addressDetail
        pin.macAddress = categoryDetail
        
        //핀에 좌표넣기
        pin.coordinate = pLoc
        
        //지도에 핀 그리기
        mapView.addAnnotation(pin)
    }
    
    //현재위치 표시
    func showUserLocation() {
        //아이폰으로부터 위치정보를 위임받는다.
        userLoc.delegate = self

        //위치정보사용 승인요청보내기 앱실행 최초 한번만 뜬다.
        userLoc.requestWhenInUseAuthorization()

        //gps신호받기 시작.
        userLoc.startUpdatingLocation()

        //지도에서 내위치 보이기
        mapView.showsUserLocation = true
        
        userLoc.startUpdatingLocation()
    }
    
    //유저트래킹 버튼 생성
    func addMapTrackingButton(){
        let buttonItem = MKUserTrackingButton(mapView: mapView)
        
        buttonItem.frame = CGRect(origin: CGPoint(x:10, y:mapView.frame.size.height*0.05 ), size: CGSize(width: 45, height: 45))
        buttonItem.backgroundColor = .systemFill
        buttonItem.layer.cornerRadius = 7
        buttonItem.layer.masksToBounds = true
        
        mapView.addSubview(buttonItem)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!.coordinate
        print("내위치 갱신 완료: \(loc.latitude), \(loc.longitude)")

        //배율 설정
        let pZoom = MKCoordinateSpan(latitudeDelta:0.01, longitudeDelta: 0.01)
        //지역 설정
        let pRegion = MKCoordinateRegion(center: loc, span: pZoom)
        
        mapView.setRegion(pRegion, animated: true)
        
        //위치갱신후 멈춰주어야 바로 동작한다.
        userLoc.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        switch mode.rawValue{
        case 0:
            if let contentVC = fpc.contentViewController as? ContentVC{
                contentVC.updateView("공공와이파이", "행정구역", "상세주소", "")
            }
        case 1:
            let lat = userLoc.location?.coordinate.latitude
            let long = userLoc.location?.coordinate.longitude
            if let contentVC = fpc.contentViewController as? ContentVC{
                contentVC.updateView("현재위치", "", findAddr(lat: lat!, long: long!), "")
            }
            print("findAddr(lat: lat!, long: long!):",findAddr(lat: lat!, long: long!))
        case 2:
            let lat = userLoc.location?.coordinate.latitude
            let long = userLoc.location?.coordinate.latitude
            if let contentVC = fpc.contentViewController as? ContentVC{
                contentVC.updateView("현재위치", "", findAddr(lat: lat!, long: long!), "")
            }
        default:
            print("default")
        }
    }
    
    //annotation event
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        if let CustomAnnotation = view.annotation as? CustomAnnotation{
            print("\(CustomAnnotation.title)핀이 눌렸습니다.")
            if let contentVC = fpc.contentViewController as? ContentVC{
                contentVC.updateView(CustomAnnotation.title!, "행정구역\n" + CustomAnnotation.addressDong, CustomAnnotation.addressDetail, "")
            }
        }
    }
    
    //annotationView custom
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        } else {
            annotationView?.annotation = annotation
        }
        if annotation.isEqual(mapView.userLocation) {
//            annotationView?.glyphText = "내위치"
//            annotationView?.markerTintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
//            annotationView?.titleVisibility = MKFeatureVisibility(rawValue: 1)!
            return nil
            
        } else{
            annotationView?.markerTintColor = #colorLiteral(red: 1, green: 0.5096537812, blue: 0, alpha: 1)
            annotationView?.glyphImage = UIImage(named: "wifi_logo")
        }
        
//        annotationView?.clusteringIdentifier = "identifier"
        return annotationView
    }
    
    // MARK: - 위도, 경도에 따른 주소 찾기
    func findAddr(lat: CLLocationDegrees, long: CLLocationDegrees) -> String{
        let findLocation = CLLocation(latitude: lat, longitude: long)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr")
        var result = "초기값"
        
        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: {(placemarks, error) -> Void in
            if let address: [CLPlacemark] = placemarks {
                var myAdd: String = ""
                if let area: String = address.last?.locality{
                    myAdd += area
                    print(myAdd)
                }
                if let name: String = address.last?.name {
                    myAdd += " "
                    myAdd += name
                    print(myAdd)
                }
                
            }
        })
        print(result,"type:",type(of: result))
        return result
    }
    
    // MARK: - urlrequest

    func urlrequest(count: Int) {
        for i in count...22{
            //api 주소
            let url = URL(string: "https://open.jejudatahub.net/api/proxy/Dtb18ta1btbD1Da1a81aaDttab6tDabb/b5eo8oep8e5_t58_15b81tc8tc2t_5jj?number="+String(i)+"&limit=100&baseDate=20200525")!
            
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
                                    let categoryDetail = data["categoryDetail"] as! String
                                    
                                    //iu변경은 메인스레드에서 작업!
                                    DispatchQueue.main.async {
                                        self.makePin(location.latitude, location.longitude, apName, installlocation,data["addressDong"] as! String, data["addressDetail"] as! String, categoryDetail)
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

