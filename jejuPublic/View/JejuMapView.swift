//
//  JejuMapView.swift
//  jejuPublic
//
//  Created by Hyun on 2022/07/07.
//

import Foundation
import MapKit

class JejuMapView:MKMapView, CLLocationManagerDelegate{
    let userLoc = CLLocationManager()
    
    // MARK: - userTracking button
    
    //유저 트래킹 버튼 생성
    func addMapTrackingButton(){
        //버튼객체 생성
        let buttonItem = MKUserTrackingButton(mapView: self)
        
        //버튼의 위치, 사이즈 색상, 곡률 설정
        buttonItem.frame = CGRect(origin: CGPoint(x:10, y:self.frame.size.height*0.05 ), size: CGSize(width: 45, height: 45))
        buttonItem.backgroundColor = .systemFill
        buttonItem.layer.cornerRadius = 7
        buttonItem.layer.masksToBounds = true
        
        //지도에 버튼 추가
        self.addSubview(buttonItem)
    }
    
    // MARK: - user location
    
    //사용자의 현재위치 수신
    func showUserLocation() {
        //사용자의 위치권한정보 저장
        let status = CLLocationManager.authorizationStatus()
        //사용자가 위치사용권한에 동의했을 시
        if status == CLAuthorizationStatus.authorizedWhenInUse{
            print("[JejuMapView]: 사용자 위치 권한",status.rawValue)
            //아이폰으로부터 위치정보를 위임받는다.
            userLoc.delegate = self

            //위치정보사용 승인요청보내기 앱실행 최초 한번만 뜬다.
            userLoc.requestWhenInUseAuthorization()

            //gps신호받기 시작.
            userLoc.startUpdatingLocation()

            //지도에서 내위치 보이기
            self.showsUserLocation = true
            
            //사용자의 위치 갱신. locationManager()함수를 호출한다.
            userLoc.startUpdatingLocation()
        } else{
            print("[JejuMapView]: 사용자 위치 권한 없음",status.rawValue)
        }
    }
    
    //사용자의 현재위치를 지도에 표시
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!.coordinate
        print("[JejuMapView]: 내위치 갱신 완료 \(loc.latitude), \(loc.longitude)")

        //배율 설정
        let pZoom = MKCoordinateSpan(latitudeDelta:0.008, longitudeDelta: 0.008)
        //지역 설정
        let pRegion = MKCoordinateRegion(center: loc, span: pZoom)
        
        //사용자의 위치를 지도의 가운데로 이동
        self.setRegion(pRegion, animated: true)
        
        //위치갱신후 멈춰주어야 바로 동작한다.
        userLoc.stopUpdatingLocation()
    }
}
