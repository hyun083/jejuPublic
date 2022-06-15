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
import RxSwift
import RxCocoa
import RxAlamofire

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FloatingPanelControllerDelegate{

    @IBOutlet var mapView: MKMapView!
    var fpc: FloatingPanelController!
    let userLoc = CLLocationManager()
    var disposebag = DisposeBag()
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        //사용자 맞춤 광고 권한 요청
        requestPermission()
        
        //제주 데이터 허브 api 요청. 매개변수로 갱신날짜를 입력한다.
        urlrequest(baseDate: 20200525)
        
        //맵뷰의 권한을 해당 뷰컨트롤러로 위임
        mapView.delegate = self
        addMapTrackingButton()
        
        //선택한 와이파이의 정보를 표시하기위한 FloatingPanel 생성
        fpc = FloatingPanelController(delegate: self)
        let contentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ContentVC")
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: self)
        
        //FlotingPanel의 스크롤이 넘어가면 하단공백이 생기는것 방지
        fpc.contentMode = .fitToBounds
        floatingPanelDesign()
        fpc.layout = CustomFloatingPanelLayout()
        
        //광고화면 배너 추가
        bannerView.rootViewController = self
        fpc.surfaceView.addSubview(bannerView)
        
        //사용자 위치 정보 표시
        showUserLocation()
        //FlotingPanel 표시
        fpc.show()
    }
    
    //MARK: - googleAdmob
    //get IDFA
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
                print("Denied")
            case .notDetermined:
                // Tracking authorization dialog has not been shown
                print("Not Determined")
            case .restricted: print("Restricted")
            @unknown default: print("Unknown")
            }
        }
    }
    
    //create banner Admob
    private let bannerView: GADBannerView = {
        let banner = GADBannerView()
        //testID: ca-app-pub-3940256099942544/6300978111
        banner.adUnitID = "ca-app-pub-8323432995434914/9299069359"
        banner.load(GADRequest())
        banner.backgroundColor = .secondarySystemBackground
        return banner
    }()
    
    //set banner location, size..
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bannerView.frame = CGRect(x: 0, y: 175, width: view.frame.size.width, height: 50).integral
    }
    
    // MARK: - FloatingPanel custom
    
    //floatingPanel design
    func floatingPanelDesign(){
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
    
    //set floatingPanel scroll bound
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if fpc.isAttracting == false{
            let loc = fpc.surfaceLocation
            let minY = fpc.surfaceLocation(for: .half).y - 3.0
            let maxY = fpc.surfaceLocation(for: .tip).y + 3.0
            fpc.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, minY),maxY))
        }
    }
    
    // MARK: - mapView custom
    //맵 핀 생성
    func makePin(_ location:CLLocationCoordinate2D, _ apName:String, _ installLocation:String, _ addressDong:String, _ addressDetail:String){
        //표시할 핀 생성
        let pin = CustomAnnotation()
        
        //핀에 정보 기입
        pin.title = apName
        pin.subtitle = installLocation
        pin.addressDong = addressDong
        pin.addressDetail = addressDetail
        pin.coordinate = location
        
        //지도에 핀 그리기
        mapView.addAnnotation(pin)
    }
    
    //핀 클릭 이벤트 처리
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        if let CustomAnnotation = view.annotation as? CustomAnnotation{
            print("\(CustomAnnotation.title)핀이 눌렸습니다.")
            //핀을 눌렀을 때 FloatingPanel에 추가정보 표시를 위해 updateView함수 호출
            if let contentVC = fpc.contentViewController as? ContentVC{
                contentVC.updateView(CustomAnnotation.title!, "행정구역\n" + CustomAnnotation.addressDong, CustomAnnotation.addressDetail)
            }
        }
    }
    
    //핀 로고 변경
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //MKMarkerAnnotationView 생성
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        } else {
            annotationView?.annotation = annotation
        }
        //사용자 위치 핀은 변경하지 않는다.
        if annotation.isEqual(mapView.userLocation) {
            return nil
        } else{
            //색상은 주황색 적용, 따로 첨부한 와이파이 로고를 glyphImage로 변환하여 적용
            annotationView?.markerTintColor = #colorLiteral(red: 1, green: 0.5096537812, blue: 0, alpha: 1)
            annotationView?.glyphImage = UIImage(named: "wifi_logo")
//            annotationView?.clusteringIdentifier = "APAnnotation"
        }
        return annotationView
    }
    
    // MARK: - user location
    //사용자의 현재위치 수신
    func showUserLocation() {
        //사용자의 위치권한정보 저장
        let status = CLLocationManager.authorizationStatus()
        //사용자가 위치사용권한에 동의했을 시
        if status == CLAuthorizationStatus.authorizedWhenInUse{
            print("권한정보",status.rawValue)
            //아이폰으로부터 위치정보를 위임받는다.
            userLoc.delegate = self

            //위치정보사용 승인요청보내기 앱실행 최초 한번만 뜬다.
            userLoc.requestWhenInUseAuthorization()

            //gps신호받기 시작.
            userLoc.startUpdatingLocation()

            //지도에서 내위치 보이기
            mapView.showsUserLocation = true
            
            //사용자의 위치 갱신. locationManager()함수를 호출한다.
            userLoc.startUpdatingLocation()
        } else{
            print("권한정보 없음",status.rawValue)
        }
    }
    
    //사용자의 현재위치를 지도에 표시
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!.coordinate
        print("내위치 갱신 완료: \(loc.latitude), \(loc.longitude)")

        //배율 설정
        let pZoom = MKCoordinateSpan(latitudeDelta:0.008, longitudeDelta: 0.008)
        //지역 설정
        let pRegion = MKCoordinateRegion(center: loc, span: pZoom)
        
        //사용자의 위치를 지도의 가운데로 이동
        mapView.setRegion(pRegion, animated: true)
        
        //위치갱신후 멈춰주어야 바로 동작한다.
        userLoc.stopUpdatingLocation()
    }
    // MARK: - user tracking
    //유저 트래킹 버튼 생성
    func addMapTrackingButton(){
        //버튼객체 생성
        let buttonItem = MKUserTrackingButton(mapView: mapView)
        
        //버튼의 위치, 사이즈 색상, 곡률 설정
        buttonItem.frame = CGRect(origin: CGPoint(x:10, y:mapView.frame.size.height*0.05 ), size: CGSize(width: 45, height: 45))
        buttonItem.backgroundColor = .systemFill
        buttonItem.layer.cornerRadius = 7
        buttonItem.layer.masksToBounds = true
        
        //지도에 버튼 추가
        mapView.addSubview(buttonItem)
    }
    
    //위치정보 권한에 따른 트래킹버튼 이벤트 처리
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        //사용자의 위치권한 정보를 저장
        let status = CLLocationManager.authorizationStatus()
        //만약 사용자가 '앱 사용중 동의'를 선택했다면
        if status == CLAuthorizationStatus.authorizedWhenInUse{
            print("권한정보",status.rawValue)
            //트래킹모드 상태에 따른 정보 표시
            switch mode.rawValue{
            //트래킹 모드 중지
            case 0:
                //FloatingPanel 초기값으로 변경
                if let contentVC = fpc.contentViewController as? ContentVC{
                    contentVC.updateView("공공와이파이", "행정구역", "상세주소")
                }
            //현재위치 모드
            case 1:
                //사용자의 위도 경도를 매개변수로 주소표시함수 호출
                findAddr(userLoc.location!)
            //나침반 모드
            case 2:
                //사용자의 위도 경도를 매개변수로 주소표시함수 호출
                findAddr(userLoc.location!)
            default:
                print("default")
            }
        //만약 사용자가 위치권한 사용 거부를 선택한 상태라면
        } else{
            print("권한정보없음",status.rawValue)
            //알림 생성
            let alertController = UIAlertController(title: "위치권한 설정이 필요합니다.", message: "앱 설정 화면으로 이동하시겠습니까? \n 위치 - 앱을 사용하는 동안", preferredStyle: .alert)
            
            //네버튼 생성, 사용자가 누를 시 설정앱 - 위치권한 메뉴로 진입
            alertController.addAction(UIAlertAction(title: "네", style: .default, handler: {(action) -> Void in if let appSettings = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)}
            }))
    
            //아니요 버튼 생성
            alertController.addAction(UIAlertAction(title: "아니요", style: .destructive, handler: nil))
            //알림 띄우기
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //사용자의 현재위치 주소 표시
    func findAddr(_ location:CLLocation){
        let findLocation = location
        let locale = Locale(identifier: "Ko-kr")
        let geocoder = CLGeocoder()
        
        //지오코더 사용 국가체계에 맞는 주소정보를 반환해준다.
        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: {(placemarks, error) -> Void in
            if let address: [CLPlacemark] = placemarks {
                var myAdd: String = ""
                //행정구역 ex)경기도,경상도,강원도...
                if let prov: String = address.last?.administrativeArea{
                    myAdd += prov
                    print("prov:",prov)
                }
                //도시 ex)제주시, 서귀포시...
                if let area: String = address.last?.locality{
                    myAdd += " " + area
                    print("area:",area)
                }
                //읍면동
                if let subArea: String = address.last?.subLocality{
                    myAdd += " " + subArea
                    print("subArea:",subArea)
                }
                //FloatingPanel에 표시
                if let contentVC = self.fpc.contentViewController as? ContentVC{
                    contentVC.updateView("현재위치", "", myAdd)
                }
            }
        })
    }
    
    // MARK: - urlrequest. API

    func urlrequest(baseDate: Int) {
        let JEJU_URL = "https://open.jejudatahub.net/api/proxy/Dtb18ta1btbD1Da1a81aaDttab6tDabb/b5eo8oep8e5_t58_15b81tc8tc2t_5jj"
        for number in 1...22{
            RxAlamofire
                .request(.get, URL(string: JEJU_URL)!,parameters: ["number":number,"limit":100,"baseDate":baseDate])
                .validate(statusCode: 200..<300)
                .responseJSON()
                .map{ try JSONSerialization.jsonObject(with:$0.data!, options: []) as! [String:Any] }
                .map{ $0["data"]!}
                .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { json in
                    for data in json as! [[String:Any]]{
                        let latitude = (data["latitude"] as! NSString).doubleValue
                        let logtitude = (data["longitude"] as! NSString).doubleValue
                        let apName = data["apGroupName"] as! String
                        let installLocation = data["installLocationDetail"] as! String
                        let addressDong = data["addressDong"] as! String
                        let addressDetail = data["addressDetail"] as! String
                        self.makePin(CLLocationCoordinate2D(latitude: latitude, longitude: logtitude), apName, installLocation, addressDong, addressDetail)
                    }
                })
                .disposed(by: disposebag)
        }
    }
}

