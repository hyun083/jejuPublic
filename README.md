![logo](https://user-images.githubusercontent.com/58415560/217452793-84337f43-8740-46d2-928b-36fc8b64a329.png)
# jejuPublicWifi
국가 사업으로 운영중인 제주도 내의 2000여개의 공공 와이파이의 위치를 제공하는 모바일 지도 서비스입니다.

제주도 여행객들의 통신비용 부담을 덜기위해 개발하였습니다.

## 동작 요약

제주데이터허브의 rest-api를 사용하여 제주도 공공와이파이의 정보를 받아옵니다. 이후 mapkit API를 사용하여 지도 위에 위치를 표시합니다.

사용자의 위치정보를 수신하여 사용자 주변에 위치한 공공와이파이를 표시합니다. 

추가적인 와이파이의 정보를 표시하기 위해 FloatingPanel 라이브러리를 사용했습니다.

## 앱 구조
![mvvm](https://user-images.githubusercontent.com/58415560/217043942-452fbf7c-962b-4ac1-9e10-08b64dfdf18c.png)
![file_hierarchy](https://user-images.githubusercontent.com/58415560/217040690-9cf0805a-c1b5-440a-82e3-08b3faf9fa7e.png)
![mvvmclass](https://user-images.githubusercontent.com/58415560/217045991-dd8b2ec8-113b-4414-8e3c-5a4c462beade.png)


## 앱 시작 및 이용 화면

|![img1](https://user-images.githubusercontent.com/58415560/216938095-28ac544b-765d-480b-9744-abf77ca61a28.png)|![img2](https://user-images.githubusercontent.com/58415560/216938106-f1ed00e2-bd39-4371-b292-cca47f80e94a.png)|
|:---:|:---:|
|앱 실행시, 사용자의 위치권한을 수신받아 현재위치를 보여줌으로서 주변의 공공와이파이에 대한 정보를 제공합니다.|AP명 Jeju Free WiFi로 되어있으며 비밀번호 없이 접근 가능합니다.|
|![img3](https://user-images.githubusercontent.com/58415560/216938115-d90c02f3-997b-40c2-95e1-ea37c44e3116.png)|![img4](https://user-images.githubusercontent.com/58415560/216938127-2483df58-7fc6-4a01-b2a3-f68bb219fbc0.png)
|3d지도 기능을 통해 자세한 위치를 확인가능합니다.|클러스터링 기능을 통해 지도를 축소하더라도 대략적인 위치파악이 가능합니다. 이외에도 표할 맵핀이 많아지면 줌 인아웃 및 지도탐색시 애니메이션이 끊기는 증상을 해소했습니다.|

## 인증화면

|![img5](https://user-images.githubusercontent.com/58415560/216938119-d410ae30-bfeb-4e23-8725-d70df6273889.png)|![img6](https://user-images.githubusercontent.com/58415560/216938124-84b4e5b1-9260-4653-9cbf-d504e5d4ec07.png)|
|:---:|:---:|
|간단한 인증을 통해 이용가능합니다.|인증이후 이용하기 버튼을 누르면 네트워크 접속가능합니다.|

## 서비스 품질

|<p align="center"><img src="https://user-images.githubusercontent.com/58415560/216938122-f90c0d1a-c2e5-4f93-a6be-4816badf83d4.png" width="30%"></p>|
|:---:|
|위치마다, 주변의 이용객에 따라 속도편차가 존재합니다.|

## 배운점

수많은 오류를 겪었습니다. 내가 겪었던 오류는 다른 개발자가 이미 한 번씩 겪었던 오류라는 점. 그리고 그에 대한 해답도 이미 공유가 되어있다는 것을 알았습니다.

오류를 많이 마주해보아야 성장한다는 것을 느꼈고, 이론적인 공부를 하는 것도 좋지만, 작은 규모의 서비스를 직접 개발해보는 것 또한 큰 성장을 일으킨다는 점을 알게 되었습니다.

첫 모바일 앱 서비스인 만큼 큰 애정이 담긴 프로젝트입니다. 새로운 서비스를 개발하는 것 만큼 완성된 서비스가 오랜기간 원활하게 운영될수있게 유지보수 및 성능개선 활동을 통해 개발자가 하는 일들이 어떤 일인지 알게된 프로젝트입니다.
