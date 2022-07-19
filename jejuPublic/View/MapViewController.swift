//
//  ViewController.swift
//  jejuPublic
//
//  Created by Hyun on 2021/07/22.
//
import UIKit
import MapKit
import FloatingPanel
import RxSwift
import RxCocoa

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FloatingPanelControllerDelegate{

    @IBOutlet weak var jejuMapView: JejuMapView!
    var fpc: FloatingPanelController!
    var disposebag = DisposeBag()
    var viewModel = ViewModel()
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[ViewController]: viewDidLoad()")
        
        //맵뷰의 권한을 해당 뷰컨트롤러로 위임
        jejuMapView.delegate = self

        //viewModel의 APIManager를 통한 annotation 생성
        viewModel.wifiModel.subscribe(onNext: { annotations in
            for annotation in annotations{
                self.jejuMapView.addAnnotation(annotation)
            }
        }).disposed(by: disposebag)
        
        //사용자 위치 정보 표시, 트래킹 버튼 활성화
        jejuMapView.showUserLocation()
        jejuMapView.addMapTrackingButton()
        
        //선택한 와이파이의 정보를 표시하기위한 FloatingPanel 생성
        fpc = FloatingPanelController(delegate: self)
        let informationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "InformationView")
        fpc.set(contentViewController: informationVC)
        fpc.addPanel(toParent: self)
        
        //FlotingPanel 외형 및 레이아웃 설정
        fpc.contentMode = .fitToBounds
        fpc.surfaceView.appearance = floatingPanelAppearance()
        fpc.layout = CustomFloatingPanelLayout()

        //FlotingPanel 표시
        fpc.show()
    }
    
    // MARK: - FloatingPanel
    
    //FloatingPanel 외형
    func floatingPanelAppearance() -> SurfaceAppearance{
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 15.0
        appearance.backgroundColor = .clear
        appearance.shadows = [shadow]
        
        return appearance
    }
    
    //FloatingPanel 스크롤 반경 설정
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if !fpc.isAttracting{
            let loc = fpc.surfaceLocation
            let minY = fpc.surfaceLocation(for: .half).y - 3.0
            let maxY = fpc.surfaceLocation(for: .tip).y + 3.0
            fpc.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, minY),maxY))
        }
    }
    
    // MARK: - mapView
    
    //annotation 이벤트 처리
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        if let annotation = view.annotation as? JejuWifiAnnotation{
            print("[ViewController]: \(annotation.title ?? "이름없는") 핀이 눌렸습니다.")
            if let informationVC = fpc.contentViewController as? InformationViewController{
                informationVC.viewModel.apGroupNameText.on(.next(annotation.title!))
                informationVC.viewModel.addressDongText.on(.next(annotation.addressDong!))
                informationVC.viewModel.addressDetailText.on(.next(annotation.addressDetail!))
            }
        }
    }
    
    //annotation 로고 변경
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is JejuWifiAnnotation{ //제주와이파이 핀
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "jejuWifiAnnotationView")
            annotationView.annotation = annotation
            //색상은 주황색 적용, 따로 첨부한 와이파이 로고를 glyphImage로 변환하여 적용
            annotationView.markerTintColor = #colorLiteral(red: 1, green: 0.5096537812, blue: 0, alpha: 1)
            annotationView.glyphImage = UIImage(named: "wifi_logo")
            annotationView.clusteringIdentifier = "wifi_annotation"
            return annotationView
        }else if annotation is MKClusterAnnotation{ //클러스터 핀
            let clusterAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "jejuWifiClusterAnnotationView")
            clusterAnnotationView.annotation = annotation
            clusterAnnotationView.markerTintColor = #colorLiteral(red: 1, green: 0.5096537812, blue: 0, alpha: 1)
            return clusterAnnotationView
        }else{ //이외의 핀(사용자 위치 핀)은 변경하지 않는다.
            return nil
        }
    }

    //clusterAnnotation 이름 수정
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        let clusterAnnotation = MKClusterAnnotation(memberAnnotations: memberAnnotations)
        clusterAnnotation.title = nil
        clusterAnnotation.subtitle = nil
        return clusterAnnotation
    }
    
    // MARK: - user tracking
    
    //트래킹버튼 이벤트 처리
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        //사용자의 위치권한 정보
        let status = CLLocationManager.authorizationStatus()
        //만약 사용자가 '앱 사용중 동의'를 선택했다면
        if status == CLAuthorizationStatus.authorizedWhenInUse{
            print("[viewController]: 사용자 위치 권한정보",status.rawValue)
            //트래킹모드 상태에 따른 정보 표시
            switch mode.rawValue{
            case 0:
                //트래킹 모드 중지, FloatingPanel 초기값으로 변경
                print("[trackingMode]:\(mode.rawValue)")
                if let informationVC = self.fpc.contentViewController as? InformationViewController{
                    informationVC.viewModel.apGroupNameText.on(.next("공공와이파이"))
                    informationVC.viewModel.addressDetailText.on(.next("상세주소"))
                    informationVC.viewModel.addressDongText.on(.next("행정구역"))
                }
            default:
                //1 현재위치, 2 나침반모드
                print("[trackingMode]:\(mode.rawValue)")
                if let informationVC = self.fpc.contentViewController as? InformationViewController{
                    informationVC.viewModel.setUserAddress(to: jejuMapView.userLoc.location!)
                }
            }
        //만약 사용자가 위치권한 사용 거부를 선택한 상태라면
        } else{
            print("[viewController]: 사용자 위치 권한없음",status.rawValue)
            //알림 생성
            let alertController = UIAlertController(title: "위치권한 설정이 필요합니다.", message: "앱 설정 화면으로 이동하시겠습니까? \n 위치 - 앱을 사용하는 동안", preferredStyle: .alert)
            
            //"네"버튼 생성, 사용자가 누를 시 위치권한 메뉴로 진입
            alertController.addAction(UIAlertAction(title: "네", style: .default, handler: {(action) -> Void in if let appSettings = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)}
            }))
    
            //"아니요" 버튼 생성
            alertController.addAction(UIAlertAction(title: "아니요", style: .destructive, handler: nil))
            
            //알림 띄우기
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

