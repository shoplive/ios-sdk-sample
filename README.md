# IOS SDK

> `Shoplive iOS SDK` is a mobile SDK that allows users to quickly and easily provide livestreams to customers using the app. `Shoplive PIP(Picture-in-Picture)` and `native keyboard UI` enable seamless mobile experience on smartphones.

<br>

<image src="doc/_images/guide.gif" width="200" height="410" style="margin-left: auto; margin-right: auto; display: block;"></image>


## Requirements
These are the minimum requirements to use the Shoplive SDK for iOS. If you do not meet these requirements, you cannot use the Shoplive SDK for iOS.

- Xcode 14 and above
- iOS 11 and above
- iOS Deployment Target 11.0 and above
- Swift 4.2 and above

## Before getting started
To use the Shoplive SDK for iOS, please request for an admin account and password to a Shoplive representative.
- \[[Make a request](mailto:ask@Shoplive.cloud)]
- \[[Admin Guide - Creating Admin Account](https://en.shoplive.guide/docs/admin-account)]

Add campaigns in Shoplive admin and write down Campaign Key.
- \[[Admin Guide - Creating Campaign](https://en.shoplive.guide/docs/create-campaign)]

## Getting Started
### 1. Installation
Choose one of the following methods to install the Shoplive SDK for iOS.

> ❗️Do not duplicate installation.  
Shoplive SDK for iOS installation must be done using either ‘CocoaPods’ or ‘Swift Package Manager.'

- CocoaPods

Add the following line to the Podfile.

```Ruby
source 'https://github.com/CocoaPods/Specs.git'

# Set it as the same minimum supported version of the project.  
# Shoplive SDK for iOS supports iOS 11.0 and above. You cannot set it below iOS 11.0.
platform: ios, '11.0'
use_frameworks!

# Set Project Target for Shoplive SDK for iOS installation.
target 'PlayShopLive' do
#livePlayerSDK
pod 'ShopLive', '1.4.5'
#shortform SDK
pod 'ShopliveShortformSDK' , '1.4.5'
end
```
- Swift Package Manager

Once you have your Swift package set up, adding Shoplive SDK for iOS as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```Ruby
dependencies: [
.package(url: "https://github.com/shoplive/ios-sdk.git", .upToNextMajor(from: "1.4.5"))
.package(url: "https://github.com/shoplive/shortform-ios", .upToNextMajor(from: "1.4.5"))
]
```

### 2. How to run `Shoplive SDK for iOS` Player
- Initialize the Shoplive Android SDK using the prepared Access Key.

|Play the video using the campaign key.  |Starts a muted campaign as an in-app PIP.|
| :-: | :-: |
|<image src="doc/_images/play.gif" width="200" height="410" style="margin-left: auto; margin-right: auto; display: block;"/>|<image src="https://files.readme.io/a06d2ff-preview.gif" width="200" height="410" style="margin-left: auto; margin-right: auto; display: block;"/>|

```Swift
// MainViewController.swift
class MainViewController: UIViewController {
...
override func viewDidLoad() {
super.viewDidLoad()
// Initialize the Shoplive Android SDK using the prepared Access Key.
ShopLive.configure(with: "{AccessKey}")

// Play the video using the campaign key.
ShopLive.play(with: "{CampaignKey}")

// Starts a muted campaign as an in-app PIP.
ShopLive.preview(with: "{CampaignKey}", completion: nil)
}
...
}
```

### 3 How to run Pip(Picture-in-Picture) mode
When performing other tasks while watching a campaign, users can switch to picture-in-picture mode.

- <B>Switching in-app PIP(picture-in-picture) mode</B>  
The user can switch the campaign view being played into a small window within the app by selecting the picture-in-picture mode icon on the Shoplive Player, or by using the Swipe down gesture.
Unlike the preview function, even if the user switches to the in-app PIP mode, the campaign audio keeps to play.

- <B>Switching OS PIP(Picture-in-Picture) mode</B>  
During campaigns playing, even if the user navigates to the home screen or navigates to another app through the home button or home indicator, the playing campaigns can be switched to a small window within iOS.
Set the Project as follows.  
<image src="https://files.readme.io/518ed34-project_setting.png" width="545" height="410"/>

|Switching in-app PIP(picture-in-picture) mode|Switching OS PIP(Picture-in-Picture) mode|
| :-: | :-: |
|<image src="doc/_images/inapp_pip.gif" width="200" height="410" style="margin-left: auto; margin-right: auto; display: block;"/>|<image src="doc/_images/ospip.gif" width="200" height="410" style="margin-left: auto; margin-right: auto; display: block;"/>|

- <B>Switching in-app PIP(picture-in-picture) mode using API</B>  
```Swift
// MainViewController.swift
class MainViewController: UIViewController {
...
override func switchingPictureInPicture() {

// Switching in-app PIP(picture-in-picture) mode
ShopLive.startPictureInPicture()

// Switching full-view mode
ShopLive.stopPictureInPicture()
}
...
}    
```
<br>

### 3. How to run `ShopliveShortform SDK for iOS` Player

#### 3-1. Initializing ShopLiveShortformSDK
- Initialize the ShopliveShortform iOS SDK using the prepared Access Key.
```Swift

// AppDelegate.swift

@main
class  AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ShopLiveCommon.setAccesskey(accessKey : {YOUR_ACCESSKEY})
        return  true
    }
}
```
<br>

#### 3-2. How to show Shortform CollectionView
- Shortform CollectionView has 3 types of layout and use builder to make each one of it.  
CardTypeView  
VerticalTypeView  
HorizontalTypeView  

- <B>Building Shortform CollectionView</B>
```Swift
import UIKit
import ShopliveShortformSDK

class ViewController : UIViewController { 
    lazy private var builder : ShopLiveShortform.CardTypeViewBuilder = {
        let builder = ShopLiveShortform.CardTypeViewBuilder()
        builder.build(cardViewType: .type1,
                      listViewDelegate: self,
                      enableSnap: currentSnap,
                      enablePlayVideo: true,
                      playOnlyOnWifi: false,
                      cellSpacing: 20)
        return builder
    }()

    lazy private var cardTypeView : UIView = {
        return builder.getView()
    }()
}

    override func viewDidLoad(){
        super.viewDidLoad()
        self.view.addSubView(cardTypeView)
        // call submit() to initialize data
        builder.submit()
}

```
<br>

#### 3-3. How to show Shortform DetailListView
- Show DetailListView with two Different types of requestData  
ShortformCollectionData   
ShortformRelatedData  

- <B>Show Shortform DetailListView</B>
```Swift
import UIKit
import ShopliveShortformSDK

class ViewController : UIViewController { 
    override func viewDidLoad(){
        super.viewDidLoad()
        ShopLiveShortform.player(requestData : ShopLiveShortformCollectionData?)
        ShopLiveShortform.player(requestData : ShopLiveShortformRelatedData?)
    }
}

```
<br>

#### 3-3. How to show Shortform Preview

- <B>Show Shortform preview</B>
```Swift
import UIKit
import ShopliveShortformSDK

class ViewController : UIViewController { 
    override func viewDidLoad(){
        super.viewDidLoad()
        ShopLiveShortform.showPreview(requestData : ShopLiveShortformRelatedData?)
}

```


## The guide is available in English and Korean.
> - [English](https://en.shoplive.guide/docs/shoplive-sdk-for-ios)
> - [한국어](https://docs.shoplive.kr/docs/ios-shoplive-sdk)
