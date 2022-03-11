# Change Log

- v1.2.2(2022-03-10)
  + 진동, 효과음 등 퀴즈 기능을 연계할 수 있도록 개선하였습니다.
  + 상품 또는 공지사항을 사용자가 선택하였을 때 앱 내 PIP로 강제 전환되던 기능에 다음 동작을 선택할 수 있는 API를 추가하였습니다.
  + Endpoint를 설정할 수 있는 API를 추가하였습니다.
  + Shoplive Player에서 Analog Dialog 또는 다른 화면이 있을 때는 Swipe-down 동작을 하더라도 앱 내 PIP로 전환되지 않도록 적용하였습니다.

<br>

- v1.2.1(2022-01-13)
  + 시청자의 네트워크 환경에 따라 자동으로 화질이 변경되는 로직을 개선하고, 더 안정적으로 라이브 스트리밍을 시청할 수 있도록 개선하였습니다.
  + 고객사 Mobile App 내부에서 PIP 가 실행될 때 키보드의 높이에 따라 PIP의 노출 위치가 자동으로 변경되도록 개선하였습니다.

<br>

- v1.2.0(2021-12-15)
  + ShopLive.isSuccessCampaignJoin() 인터페이스 추가

<br>

- v1.1.4(2021-12-08)
  + ShopLive.sdkVersion 인터페이스 추가

<br>
  
- v1.1.3(2021-11-15)
  + handleReceivedCommand 콜백 추가

<br>

- v1.1.2(2021-11-11)
  + ShopLive.setLoadingAnimation(images:) 인터페이스 추가
  + handleCustomActionResult, handleCustomActionResult 콜백 optional로 변경

<br>

- v1.1.1(2021-11-08)
  + handleCustomActionResult, handleCustomActionResult 콜백 추가
  + onSetUserName 콜백 추가

<br>

- v1.0.18(2021-10-01)
  + ShopLive.user.add(params:) 인터페이스 추가

<br>

- v1.0.17(2021-09-16)
  + ShopLive.setKeepAspectOnTabletPortrait(_ keep:) 인터페이스 추가

<br>

- v1.0.16(2021-09-08)
  + 사운드 정책 중 통화종료 후 이어서 재생설정 API가 활성화 되었습니다. (CallKit 사용하지 않음)
  + 로딩 인디케이터가 영상 시작시에만 나오도록 수정되었습니다.
  + 라이브에서는 OS PIP 영상 정지/재생시 stream의 최신 위치로 seek하도록 적용되었습니다.

<br>

- v1.0.13(2021-09-06)
  + 로딩 인디케이터가 추가되었습니다. (Default: White)
  + 인앱 PIP가 키보드가 노출시 키보드 위에 위치하도록 조정되었습니다.

<br>

- v1.0.10(2021-09-01)
  + 플레이어 상태 변경 Command의 payload value 타입 (String 에서 Int로) 변경 
  + hookNavigation API 추가
  + 플레이어의 상태변경에 따른 이벤트를 handleCommand 전달하도록 적용되었습니다.
  + 상품을 선택시에 handleNavigation으로 진입시 기본적으로 pip로 전환.

<br>

- v1.0.6(2021-08-31)
  + 사운드 정책 중 통화종료 후 이어서 재생설정 API를 비활성 (일부 국가에서 CallKit이 비허용)
  + Preview 전환 처리에 대한 버그를 수정하였습니다.

<br>

- v1.0.4(2021-08-30)
  + 프리뷰로 현재 화면에서 PIP로 시작할 수 있는 Preview API 추가
  + ShopLive 방송화면의 ViewController를 사용할 수 있도록 property 추가

<br>

- v1.0.3(2021-08-22)
  + 영상 연결이 좋지 않은 경우 재연결 시도를 하도록 적용되었습니다.
  + 공유 API에서 scheme 파라미터가 필수값에서 옵셔널로 변경
  + close ( 플레이어 종료) API 추가
  + 방송 진입 시, 캠페인 정보 전달
  + 캠페인 상태 변경 시, 상태 값 전달
  + 오류 상황 발생 시, 코드/메시지 전달
  + 통화 종료 후 영상 복귀 시, 기본값을 '영상 멈춤'에서 '영상 자동 재생'으로 변경


<br>
- v1.0.2(2021-08-09)
  + 플레이어를 내렸을 때 인스턴스가 해제되지 않는 문제를 수정했습니다.

<br>

- v1.0.1(2021-08-05)
  + handleDownloadCoupon으로 이벤트가 전달되지 않는 문제를 수정했습니다.






