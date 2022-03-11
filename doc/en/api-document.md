- [API - Play](#API---Play)
  
  - [configure(with:)](#configurewith)
  - [play(with:)](#playwith)
  - [preview(with:, completion:)](#previewwith-completion)
  
    <br>

- [API - Option](#API---Option)
  
  - [setShareScheme(\_ scheme:, custom:)](#setsharescheme_-scheme-custom)
  - [setChatViewFont(inputBoxFont:, sendButtonFont:)](#setchatviewfontinputboxfont-sendbuttonfont)
  - [setLoadingAnimation(images:)](#setloadinganimationimages)
  - [pipPosition](#pipposition)
  - [pipScale](#pipscale)
  - [startPictureInPicture(with: , scale: )](#startpictureinpicturewith--scale-)
  - [stopPictureInPicture()](#stoppictureinpicture)
  - [hookNavigation(navigation: @escaping ((URL) -> Void))](#hooknavigationnavigation-escaping-url---void)[](#hooknavigationnavigation-escaping-url---void)
  - [setKeepAspectOnTabletPortrait(\_ keep:)](#setkeepaspectontabletportrait_-keep)
  - [user](#user)
  - [authToken](#authtoken)
  - [style](#style)
  - [viewController](#viewcontroller)
  - [indicatorColor](#indicatorcolor)
  - [isSuccessCampaignJoin() -> Bool](#issuccesscampaignjoin---bool)
  - [AutoResumeVideoOnCallEnded option](#autoresumevideooncallended-option)
    - [setAutoResumeVideoOnCallEnded(\_ autoResume: Bool)](#setautoresumevideooncallended_-autoresume-bool)
    - [isAutoResumeVideoOnCallEnded() -> Bool](#isautoresumevideooncallended---bool)
  - [KeepPlayVideoOnHeadphoneUnplugged option](#keepplayvideoonheadphoneunplugged-option)
    - [setKeepPlayVideoOnHeadphoneUnplugged(\_ keepPlay: Bool)](#setkeepplayvideoonheadphoneunplugged_-keepplay-bool)
    - [isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool](#iskeepplayvideoonheadphoneunplugged---bool)
  
    <br>


- [Handler (delegate)](#Handler-delegate)
  
  - [delegate](#delegate)
  - [handleNavigation(with:)](#handlenavigationwith)
  - [handleChangeCampaignStatus(status:)](#handlechangecampaignstatusstatus)
  - [handleCampaignInfo(campaignInfo:)](#handlecampaigninfocampaigninfo)
  - [onSetUserName(\_ payload:)](#onsetusername_-payload)
  - [handleCommand(\_ command: , with payload:)](#handlecommand_-command--with-payload)
  - [handleReceivedCommand(\_ command: , with payload:)](#handlereceivedcommand_-command--with-payload)
    - [handleReceivedCommand list](#handlereceivedcommand-list)
      - [CLICK\_PRODUCT\_DETAIL](#click_product_detail)
      - [CLICK\_PRODUCT\_CART](#click_product_cart)
      - [LOGIN\_REQUIRED](#login_required)
      - [ON\_SUCCESS\_CAMPAIGN\_JOIN](#on_success_campaign_join)
  - [Coupon](#coupon)
    - [handleDownloadCouponResult(with: completion:)](#handledownloadcouponresultwith-completion)
    - [handleCustomActionResult(with id:, type:, payload:, completion:)](#handlecustomactionresultwith-id-type-payload-completion)
  - [NextActionOnHandleNavigation option](#nextactiononhandlenavigation-option)
    - [setNextActionOnHandleNavigation(actionType:)](#setnextactiononhandlenavigationactiontype)
    - [getNextActionTypeOnHandleNavigation() -> ActionType](#getnextactiontypeonhandlenavigation---actiontype)
  - [setEndpoint(_ url:)](#setendpoint_-url)
  - [handleError(code:, message:)](#handleerrorcode-message)
    <br>

# iOS Shoplive API Document

<br>

## API - Play

- ### configure(with:)
  
  > Initialize the Shoplive iOS SDK using the Access Key received from the Shoplive representative.
  
  ```swift
  configure(with accessKey: String)
  ```
  
  | Parameter| Description
  |----------|----------
  | AccessKey| Access Key received from the Shoplive representative

  ```swift
  ShopLive.configure(with: "{AccessKey}")
  ```
  <br>

  > Application guide
  
  - [Running Shoplive Player](./index.md#step-2-running-shoplive-player) 

<br>

- ### play(with:)
  
  > Play the video using the campaign key.

    
   ```swift
   play(with campaignKey: String?)
   ```
  
    | Parameter| Description
    |----------|----------
    | campaignKey| Campaign key to play the video
  
  <br>

  > Sample code
  
  ```swift
  ShopLive.play(with: "{CampaignKey}")
  ```
  
  <br>
  
  > Application guide
  
   - [Running Shoplive Player](./index.md#step-2-running-shoplive-player) 

<br>

- ### preview(with:, completion:)
  
  > Play the video on mute in preview using the campaign key.  
  
  ```swift
  preview(with campaignKey: String?, completion: @escaping () -> Void)
  ```
  
  | Parameter| Description
  |----------|----------
  | campaignKey| Campaign key to play the video
  | completion| `completion` block function called when preview is selected(tapped)

  <br>
  
  > Sample code
  
  ```swift
  ShopLive.preview(with: "{CampaignKey}") {
      // Plays video when selecting(tapping) play in preview.
      ShopLive.play(with: "{CampaignKey}")
  }
  ```

  <br>
  
  > Application guide
  
   - [Running Shoplive Player](./index.md#step-2-running-shoplive-player) 

<br>

- ### close()
  
  > Close the video is being campaign.
  
  ```swift
  close()
  ```
  
  <br>
  
  > Sample code
  
  ```swift
  ShopLive.close()
  ```
  
<br>


## API - Option

- ### setShareScheme(\_ scheme:, custom:)
  
  > Set the `scheme` to be delivered to the system shared popup when sharing is selected(tapped).  
Use the `custom` callback function to set up s custom shared popup instead of the iOS system shared popup.
  
  ```swift
  setShareScheme(_ scheme: String?, custom: (() -> Void)?)
  ```
  
  | Parameter| Description
  |----------|----------
  | scheme| Scheme or URL to share
  | custom| Custom shared popup settings
 
  <br>
  
  > Sample code
  
  ```swift
  
  let scheme = "shoplive://live"
  let scheme = "https://shoplive.cloud/live"
  
  // iOS system shared popup
  ShopLive.setShareScheme(scheme, custom: nil)
  
  // Custom shared popup
  ShopLive.setShareScheme(scheme, custom: {
      let alert = UIAlertController.init(title: "Use Custom Share", message: nil, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
      }))
      ShopLive.viewController?.present(alert, animated: true, completion: nil)
  })
  ```
  
  <br>
  
  > Application guide
  
  - [Sharing a campaign link](./index.md#step-6-sharing-a-campaign-link)

<br>

- ### setChatViewFont(inputBoxFont:, sendButtonFont:)
  
  > Set the chat font and chat send button font.
  
  ```swift
  setChatViewFont(inputBoxFont: UIFont, sendButtonFont: UIFont)
  ```
  
  | Parameter| Description
  |----------|----------
  | inputBoxFont| Chat font
  | sendButtonFont| Chat send button font

  <br>
  
  > Sample code
  
  ```swift
  /**
      // Chat font setting
      let inputDefaultFont = UIFont.systemFont(ofSize: 14, weight: .regular)
  
      // Chat send button font setting
      let sendButtonDefaultFont = UIFont.systemFont(ofSize: 14, weight: .medium)
  
  */
  
  let customFont = UIFont(name: "{Custom Font}", size: 16)
  
  // Chat font and chat send button font setting 
  ShopLive.setChatViewFont(inputBoxFont: customFont, sendButtonFont: customFont)
  ```
  
  <br>
  
  > Application guide
  
  - [Changing the chat font](./index.md#Changing-the-chat-font)  

<br>

- ### setLoadingAnimation(images:)
  
  > Set the video loading progress to an image animation.
  
  ```swift
  setLoadingAnimation(images: [UIImage])
  ```
  
  | Parameter| Description
  |----------|----------
  | images| Image `UIImage` array to use for image animation

  <br>
  
  > Sample code
  
  ```swift
  var images: [UIImage] = []
  
  for i in 1...11 {
      images.append(.init(named: "loading\(i)")!)
  }
  
  ShopLive.setLoadingAnimation(images: images)
  ```
  
  <br>
   
  > Application guide
  
  - [Setting the indicator](./index.md#step-8-setting-the-indicator) 

    <br>

- ### pipPosition
  
  > Specifies the default location to start the PIP(picture-in-picture) mode.   
When playing for the first time and starting PIP(picture-in-picture) mode, PIP(picture-in-picture) mode starts at the specified location.   
Default value: `default`
  
 
  ```swift
  public enum PipPosition: Int {
      case topLeft
      case topRight
      case bottomLeft
      case bottomRight
      case `default`
  }
  ```
  
  | Parameter| Description
  |----------|----------
  | topLeft| Top left of the view
  | topRight| Top right of the view
  | bottomLeft| Bottom left of the view
  | bottomRight| Bottom right of the view
  | default| The last position <br>When running for the first time, it starts at the bottom right of the view.


  ```swift
  var pipPosition: ShopLive.PipPosition { get set }
  ```
  
  <br>

     > Sample code
  
  ```swift
  print(ShopLive.pipPosition)
  ```
  
  <br>
  
  > Application guide
  
  - [Running as PIP(Picture-in-Picture) mode](./index.md#step-7-running-as-pippicture-in-picture-mode)

<br>

- ### pipScale
  
  > Default view scaling when starting PIP(Picture-in-Picture) mode.  
When playing for the first time and starting PIP(picture-in-picture) mode, PIP(picture-in-picture) mode starts with the specified view scale.  
The default value is the last specified value. If there is no last specified value, the default value is 0.4x view scale.
  
  <br>
  
  - Enter a value between 0.0 and 1.0.
  - Displays the PIP view at a reduced view scale based on the device view width.
  - The PIP(Picture-in-Picture) mode view scale is changed to the video view scale being played.
  
  <br>
  


   ```swift
  var pipScale: CGFloat { get set }
  ```
  
  <br>
  
  > Sample code
  
  ```swift
  print(ShopLive.pipScale)
  ```
  
  <br>
  
  > Application guide
  
  - [Running as PIP(Picture-in-Picture) mode](./index.md#step-7-running-as-pippicture-in-picture-mode)

<br>

- ### startPictureInPicture(with: , scale: )
  
  > Switch from full-view mode to PIP(Picture-in-Picture) mode.
  
  ```swift
  startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat)
  startPictureInPicture()
  ```
  
  | Parameter| Description
  |----------|----------
  | position| Position when PIP(Picture-in-Picture)  mode starts <br> Default value: `default`
  | scale| Enter a value between 0.0 and 1.0

  <br>
  
  > Sample code
  
  ```swift
  // Switching In-app PIP mode to 0.4x (default) size
  ShopLive.startPictureInPicture()
  
  // Switching In-app PIP mode to 0.1x size at the bottom right of the view
  ShopLive.startPictureInPicture(with: .bottomRight, scale: 0.1)
  
  // Switching In-app PIP mode to 0.8x size at the top left of the view
  ShopLive.startPictureInPicture(with: .topLeft, scale: 0.8)
  ```
 
  <br>
   
  > View scale setting example
  
  | Scale| PIP view| Scale| PIP view| Scale| PIP view
  |----------|----------|----------|----------|----------|----------
  | 0.1| <img src="../_images/inapp_10_scale.PNG" width="150">| 0.4 <br> (default)| <img src="../_images/inapp_basic_scale.PNG" width="150">| 0.8| <img src="../_images/inapp_80_scale.PNG" width="150">


  > Application guide
  
  - [Switching in-app PIP(picture-in-picture) mode using API](./index.md#switching-in-app-pippicture-in-picture-mode-using-API)  

<br>

- ### stopPictureInPicture()
  
  > Switch the PIP(picture-in-picture) mode to full-view mode.
  
  ```swift
  stopPictureInPicture()
  ```
  
  <br>
  
  > Sample code
  
  ```swift
  ShopLive.stopPictureInPicture()
  ```
  
  <br>
  
  > Application guide
  
  - [Switching in-app PIP(picture-in-picture) mode using API](./index.md#switching-in-app-pippicture-in-picture-mode-using-API)  

<br>

- ### hookNavigation(navigation: @escaping ((URL) -> Void))
  
  > When selecting a product or banner, receive the event directly with the `custom` Callback function set in the parameter (`navigation` entered as a parameter).
  
  ```swift
  hookNavigation(navigation: @escaping ((URL) -> Void))
  ```
  
  | Parameter| Description
  |----------|----------
  | navigation| Call Block when product or banner is selected <br> - Delivers the URL of the selected product or banner

  <br>
  
  > Sample code
  
  ```swift
     ShopLive.hookNavigation { url in
         // url: Detailed information URL set for the selected product or banner
         print("hookNavigation \(url)")
     }
  ```
  
  <br>
  
  > Application guide
  
  - [Delivering Events Using API Functions](./index.md#delivering-events-using-api-functions)  

<br>

- ### setKeepAspectOnTabletPortrait(\_ keep:)
  
  > Sets the aspect ratio of the Shoplive view in tablet portrait mode.  
`true`: Keep Aspect Ratio (default)  
`false`: Change Aspect Ration to the maximum supported by the tablet
  
  ```swift
  setKeepAspectOnTabletPortrait(_ keep: Bool)
  ```
  
  | Parameter| Description
  |----------|----------
  | keep| Set whether to keep the aspect ratio

  <br>
  
  > Sample code
  
  ```swift
  ShopLive.setKeepAspectOnTabletPortrait(true)
  ```

  <br>
    
  > Application guide
  
  - [Setting the aspect ratio in tablet portrait mode](./index.md#step-10-setting-the-aspect-ratio-in-tablet-portrait-mode)

<br>

- ### user
  
  > `user` is an authenticated user using Shoplive.  
Enter user information to authenticate the user.
  

  ```swift
  var user: ShopLiveUser? { get set }
  ```
  

  ```swift
  // User Gender
  public enum Gender : Int, Codable, CaseIterable {
      case female = 1
      case male = 2
      case neutral = 3
      case unknown = 0
  }
  ```
  
  ```swift
  public class ShopLiveUser: NSObject, Codable {
      let name: String?
      let gender: Gender?
      let id: String?
      let age: Int?
  
      func add(_ params: [String: Any?])
      func getParams() -> [String: String]
  }
  ```
  
  <br>
  
  - add(\_ params:)
  
    > Add parameters to the user.  
Add parameters using a `params` - `Dictionary (key: value)`.  
\# This option is only available after prior consultation.
  

 	 | Parameter| Description
	  |----------|----------
	  | userScore| user score

    <br>

    > Sample code
  
    ```swift
    let user = ShopLiveUser(id: "id", name: "name", gender: Gender.male, age: 20)
    user.add(["userScore": 40])
  
    ShopLive.user = user
    ```   

    <br>
   
     > Application guide
  
    - [Chat as an authenticated user](./index.md#chat-as-an-authenticated-user)

<br>

- ### authToken
  
  > A secure authentication token (JWT) string for authenticated users using Shoplive.  
Enter the security authentication token (JWT) string of the authenticated user for user authentication.
  
  ```swift
  var authToken: String? { get set }
  ```
  <br>

  > Sample code
  
  ```swift
  let generatedJWT = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2MTA1NzA1dfadsfasfadsfasdfwO"
  
  ShopLive.authToken = generatedJWT
  ```
  <br>

  > Application guide  
  - [Chat as an authenticated user](./index.md#chat-as-an-authenticated-user)

<br>

- ### style
  
  > The style of the current Shoplive Player.
  
  ```swift
  var style: ShopLive.PresentationStyle { get }
  ```
  
  ```swift
  public enum PresentationStyle: Int {
      case unknown
      case fullScreen
      case pip
  }
  ```
  <br>

  > Sample code
  
  ```swift
  print(ShopLive.style)
  ```
<br>

- ### viewController
  
  > The instance of the UIViewController that the Shoplive Player is currently viewing.
  
  ```swift
  var viewController: ShopLiveViewController? { get }
  ```
  
  <br>

  > Sample code
  
  ```swift
  // View Alert on Shoplive Player
  let alert = UIAlertController.init(title: "Alert on Player", message: nil, preferredStyle: .alert)
  alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
  
  ShopLive.viewController?.present(alert, animated: true, completion: nil)
  ```
  <br>
  
  > Application guide
  
  - [Using the custom system shared UI](./index.md#using-the-custom-system-shared-ui)

<br>

- ### indicatorColor
  
  > Sets the loading indicator color.
  
  ```swift
  var indicatorColor: UIColor { get set }
  ```
  
  <br>

  > Sample code
  
  ```swift
  ShopLive.indicatorColor = UIColor.red
  ```
  
  <br>

  > Application guide
  
  - [Setting the indicator color](./index.md#setting-the-indicator-color)

<br>

- ### isSuccessCampaignJoin() -> Bool
  
  > Check whether the entry into the campaign was successful.  
Related `Callback`: [handleReceivedCommand - ON\_SUCCESS\_CAMPAIGN\_JOIN](#on_success_campaign_join)[ ](#on_success_campaign_join)
  
  ```swift
  isSuccessCampaignJoin() -> Bool
  ```
  
  <br>

  > Sample code

  
  ```swift
  print(ShopLive.isSuccessCampaignJoin())
  ```

<br>

- ### **AutoResumeVideoOnCallEnded option**
  
  > When returning to the video after the call ended, set the video to resume play automatically without stopping.
  
  - #### **setAutoResumeVideoOnCallEnded(\_ autoResume: Bool)**
    
    ```swift
    setAutoResumeVideoOnCallEnded(_ autoResume: Bool)
    ```
    
    | Parameter| Description
    |----------|----------
    | autoResume| After the call ended, the video automatically resume plays <br>  `true`: Auto resume play <br>  `false`: No Auto resume play (default)

    <br>

    > Sample code
    
    ```swift
    ShopLive.setAutoResumeVideoOnCallEnded(true)
    ```
    
    <br>
    
    > Application guide
    
    - [Interrupt due to call connection](./index.md#interrupt-due-to-call-connection)  

    <br>

   - #### **isAutoResumeVideoOnCallEnded() -> Bool**
    
     > Returns the currently set value. <br>`true`: Automatically resume play video after the call ended <br>`false`: Stop playing video after the call ended
    
     ```swift
     isAutoResumeVideoOnCallEnded() -> Bool
     ```

     <br>

        > Sample code

    
     ```swift
     print(ShopLive.isAutoResumeOnCallEnded())
     ```
      <br>

        > Application guide
    
      - [Interrupt due to call connection](./index.md#interrupt-due-to-call-connection)  

<br>

- ### KeepPlayVideoOnHeadphoneUnplugged option
  
  > When the earphone (or headset) is disconnected, set the video to keep play without stopping.
  
  - #### **setKeepPlayVideoOnHeadphoneUnplugged(\_ keepPlay: Bool)**
    
    > When the earphone (or headset) is disconnected, set the video to keep play without stopping.
    
    ```swift
    setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool)
    ```
    
    | Parameter| Description
    |----------|----------
    | keepPlay| After the earphone (or headset) is disconnected, the video keep plays <br>  `true`: keep play <br>  `false`: No keep play (default)

    <br>
    
    > Sample code
    
    ```swift
    ShopLive.setKeepPlayVideoOnHeadphoneUnplugged(true)
    ```
    
    <br>

     > Application guide
    
    - [Interrupt due to earphone (or headset) disconnection](./index.md#interrupt-due-to-earphone-or-headset-disconnection)  

   <br>
  
  - #### **isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool**
    
    > Returns the currently set value.  <br> - `true`: Autoplay <br> - `false`: No Autoplay
    
    ```swift
    isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool
    ```
    
    <br>

    > Sample code
    
    ```swift
    print(ShopLive.isKeepPlayVideoOnHeadPhoneUnplugged())
    ```
    
    <br>
    
    > Application guide
    
    - [Interrupt due to earphone (or headset) disconnection](./index.md#interrupt-due-to-earphone-or-headset-disconnection)  
<br>
    
---
<br>

## Handler (delegate)

> The client receives notifications such as user UI events or status changes that have occurred in Shoplive Player through a handler (delegate) function and takes necessary handling. <br>

- ### delegate
  
  > This `property` declares a function that receives the handler event of the Shoplive iOS SDK and connects the event with the Shoplive iOS SDK.
  
  ```swift
  @objc var delegate: ShopLiveSDKDelegate? { get set }
  ```
  
  ```swift
  @objc public protocol ShopLiveSDKDelegate: AnyObject {
      @objc func handleNavigation(with url: URL)
      @objc func handleChangeCampaignStatus(status: String)
      @objc func handleCampaignInfo(campaignInfo: [String : Any])
  
      @objc func onSetUserName(_ payload: [String : Any])
  
      @objc func handleCommand(_ command: String, with payload: Any?)
      @objc func handleReceivedCommand(_ command: String, with payload: Any?)
  
      @objc func handleError(code: String, message: String)
  
      @objc optional func handleDownloadCouponResult(with couponId: String, completion: @escaping (CouponResult) -> Void)
      @objc optional func handleCustomActionResult(with id: String, type: String, payload: Any?, completion: @escaping (CustomActionResult) -> Void)
  }
  ```
  
  <br>

  > Sample code
  
  ```swift
  class MainViewController: UIViewController {
      ...
      override func viewDidLoad() {
          super.viewDidLoad()
  
          // Connects the delegate with the current class.
          ShopLive.delegate = self
  
      }
      ...
  }
  
  // The class to connect the delegate implements the ShopLiveSDKDelegate Protocol. 
  extension MainViewController: ShopLiveSDKDelegate {
      func handleNavigation(with url: URL) {
          print("handleNavigation \(url)")
      }
      ...
  }
  ```

<br>

- ### handleNavigation(with:)
  
  > When selecting(tapping) a product, banner, etc. in Shoplive, deliver the selected product or banner information.
  
  ```swift
  handleNavigation(with url: URL)
  ```
  
  | Parameter| Description
  |----------|----------
  | url| URL to go to when product or banner is selected

  <br>

  > Sample code
  
  ```swift
  extension MainViewController: ShopLiveSDKDelegate {
      func handleNavigation(with url: URL) {
          print("handleNavigation \(url)")
  
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
      ...
  }
  ```
  
  <br>

  > Application guide
  
  - [Delivering Events Using Handler Functions](./index.md#delivering-events-using-handler-functions) 

<br>

- ### handleChangeCampaignStatus(status:)
  
  > Delivers the changed campaign status When changing the campaign status.
  
  ```swift
  @objc func handleChangeCampaignStatus(status: String)
  ```
  
  | Parameter| Description
  |----------|----------
  | status| Campaign status <br>   `READY`, `ONAIR`, `CLOSED`

  <br>

  > Sample code
  
  ```swift
  extension MainViewController: ShopLiveSDKDelegate {
      func handleChangeCampaignStatus(status: String) {
          print("handleChangeCampaignStatus \(status)")
  
          switch status {
              case "READY", "ONAIR":
                  break
              case "CLOSED":
                  print("ended campaign")
                  break
          }
      }
      ...
  }
  ```

<br>

- ### handleCampaignInfo(campaignInfo:)
  
  > Delivers information about the current campaign.
  
  ```swift
  handleCampaignInfo(campaignInfo: [String : Any])
  ```
  
  | Parameter| Description
  |----------|----------
  | campaignInfo| Current campaign information<br>   Example) `title`: Campaign title

  <br>

  > Sample code
  
  ```swift
  extension MainViewController: ShopLiveSDKDelegate {
      func handleCampaignInfo(campaignInfo: [String : Any]) {
  
          campaignInfo.forEach { (key, value) in
              print("campaignInfo key: \(key)  value: \(value)")
          }
  
      }
      ...
  }
  ```
<br>

- ### onSetUserName(\_ payload:)
  
  > Call when changing the username.
  

  ```swift
  onSetUserName(_ payload: [String : Any])
  ```
  
  | Parameter| Description
  |----------|----------
  | payload| User information<br>   Example) `userId`: User ID

  <br>

  > Sample code
  
  ```swift
  extension MainViewController: ShopLiveSDKDelegate {
      func onSetUserName(_ payload: [String : Any]) {
          payload.forEach { (key, value) in
              print("onSetUserName key: \(key) value: \(value)")
          }
      }
      ...
  }
  ```

  <br>

  > Application guide
  
    - [Changing nickname](./index.md#changing-nickname) 

<br>

- ### handleCommand(\_ command: , with payload:)
  
  > Delivers specific command information from Shoplive iOS SDK.
  
  ```swift
  handleCommand(_ command: String, with payload: Any?)
  ```
  
  | Parameter| Description
  |----------|----------
  | command| Command name
  | payload| Data delivered with the command

    <br>

  - #### Change Shoplive Player status
    
    > Command to be delivered when Shoplive Player status changes
    
    | Parameter| Description
    |----------|----------
    | willShopLiveOn| Shoplive Player starts changing to full-view
    | didShopLiveOn| Shoplive Player completes changing to full-view
    | willShopLiveOff| Shoplive Player starts changing to PIP(picture-in-picture) mode or end status
    | didShopLiveOff| Shoplive Player completes changing to PIP(picture-in-picture) mode or end status

    <br>

    > payload  
Delivers the pre-change Shoplive Player status as a `payload`.
    
    | Parameter| Description
    |----------|----------
    | style| rawValue (Int) of PresentationStyle

    <br>

    > Sample code
  
    ```swift
    extension MainViewController: ShopLiveSDKDelegate {
       func handleCommand(_ command: String, with payload: Any?) {
           print("handleCommand: \(command)  payload: \(payload)") 
       }
       ...
    }
    ```

<br>

- ### handleReceivedCommand(\_ command: , with payload:)
  
  > Delivers the command information from the WEB of Shoplive iOS SDK.
  
  ```swift
  handleReceivedCommand(_ command: String, with payload: Any?)
  ```
  
  | Parameter| Description
  |----------|----------
  | command| Command name
  | payload| Data delivered with the command

  <br>

  > Sample code
  
  ```swift
  extension MainViewController: ShopLiveSDKDelegate {
      func handleReceivedCommand(_ command: String, with payload: Any?) {
          // print("handleReceivedCommand: \(command)  payload: \(payload)")
      }
      ...
  }
  ```
  
  <br>
    
  > Application guide
  
  - [Delivering Events Using Handler Functions](./index.md#delivering-events-using-handler-functions)


<br>
  
  - #### handleReceivedCommand list
    
    - ##### CLICK\_PRODUCT\_DETAIL
      
      > Product information that is delivered when the product list is opened on the campaign view and a product is selected.
      
      ```javascript
      command:
      CLICK_PRODUCT_DETAIL
      
      payload:
      {
          action = LINK;
          brand = BRAND;
          sku = product01234;
          url = "http://product.com";
      }
      ```
    
    <br>
    
    - ##### CLICK\_PRODUCT\_CART
      
      > Shopping cart information that is delivered when the product list is opened on the campaign view and the shopping cart button is selected.
      
      ```javascript
      command:
      CLICK_PRODUCT_CART
      
      payload:
      {
      action = LINK;
          brand = "company brand";
          ...
          url = "https://company.com/product/12345/detail";
      }
      ```
      
    <br>

    - ##### LOGIN\_REQUIRED
      
      > Requests a sign-in action that is delivered when a sign-in is required by an app covered by the Shoplive iOS SDK.
      
      ```javascript
      command:
      LOGIN_REQUIRED
      
      payload: NONE
      ```
      
    <br>

    - ##### ON\_SUCCESS\_CAMPAIGN\_JOIN
      
      > This information is delivered when the campaign entry is successful.
      
      ```javascript
      command:
      ON_SUCCESS_CAMPAIGN_JOIN
      
      payload:
      {
      isGuest: 1 // 1: unauthenticated user, 0: authenticated user
      }
      ```
<br>

- ### handleError(code:, message:)
  
  > Delivers a message about an error situation that occurs before or during the campaign.
  
  ```swift
  handleError(code: String, message: String)
  ```
  
  | Parameter| Description
  |----------|----------
  | code| Error code
  | message| Error message

  <br>

  > Sample code
  
  ```swift
  extension MainViewController: ShopLiveSDKDelegate {
      func handleError(code: String, message: String) {}
          print("handleError \(code) \(message)")
      }
      ...
  }
  ```
<br>

- ## Coupon
  
  > Status to set whether coupons are active when coupon handling is complete.
  
  ```swift
  @objc public enum ResultStatus: Int, CaseIterable {
      case SHOW // Coupon reactivated
      case HIDE // Coupon disappeared
      case KEEP // Keep Coupon Status
  
      public var name: String {
          switch self {
          case .SHOW:
              return "SHOW"
          case .HIDE:
              return "HIDE"
          case .KEEP:
              return "KEEP"
          }
      }
  }
  ```
  
  > Set the type of notification message that appears when coupon handling is complete.
  
  ```swift
  @objc public enum ResultAlertType: Int, CaseIterable {
      case ALERT // Alert
      case TOAST // Toast
  
      public var name: String {
          switch self {
          case .ALERT:
              return "ALERT"
          case .TOAST:
              return "TOAST"
          }
      }
  }
  ```
  
  ```swift
  @objc public class CouponResult: NSObject {
      var success: Bool         // Coupon handling success/failure
      var coupon: String = ""   // Coupon ID
      var message: String?      // Alert message
      var couponStatus: ResultStatus // Coupon status after completion
      var alertType: ResultAlertType // Alert message output type
  
      public init(couponId: String, success: Bool, message: String?, status: ResultStatus, alertType: ResultAlertType) {
          self.coupon = couponId
          self.success = success
          self.message = message
          self.couponStatus = status
          self.alertType = alertType
      }
  }
  ```
<br>

- ### handleDownloadCouponResult(with: completion:)
  
  > When a coupon is selected(tapped) in Shoplive, deliver the coupon information to the client. Set the coupon status in Shoplive Player through the completion callback, which delivers the client's coupon handling result back to the Shoplive iOS SDK.
  
  ```swift
  handleDownloadCouponResult(with couponId: String, completion: @escaping (CouponResult) -> Void)
  ```
  
  | Parameter| Description
  |----------|----------
  | couponId| Coupon ID
  | completion| A completion callback that delivers the result to the Shoplive iOS SDK

  <br>  

  > Sample code
  
  ```swift
  extension MainViewController: ShopLiveSDKDelegate {
      func handleDownloadCouponResult(with couponId: String, completion: @escaping (CouponResult) -> Void) {
          print("handleDownloadCouponResult: \(couponId)")
  
          // Called when coupon handling is complete (handling result)
          // Success
          let result = CouponResult(couponId: couponId, success: true, message: "Coupon download was successful.", status: .SHOW, alertType: .ALERT)
          // Failure
          let result = CouponResult(couponId: couponId, success: false, message: "Coupon download failed.", status: .HIDE, alertType: .TOAST)
          completion(result)
      }
      ...
  }
  ```
  <br>

  > Application guide
  
  - [Using coupon](./index.md#step-4-using-coupon)

<br>

- ### handleCustomActionResult(with id:, type:, payload:, completion:)
  
  > The selecting(tapping) event is designated as `custom` in the popup and the popup is selected(tapped), deliver the popup information. Delivers `id`, `type` (`COUPON`, `BANNER`, `NOTICE`), and `payload` of the popup.
  
  ```swift
  handleCustomActionResult(with id: String, type: String, payload: Any?, completion: @escaping (CustomActionResult) -> Void)
  ```
  
  | Parameter| Description
  |----------|----------
  | id| Popup ID
  | type| Popup type<br> - `COUPON`, `BANNER`, `NOTICE`
  | payload| Custom data
  | completion| A completion callback that delivers the result to the Shoplive iOS SDK

  <br>

  > Sample code
  
  ```swift
  extension MainViewController: ShopLiveSDKDelegate {
      func handleCustomActionResult(with id: String, type: String, payload: Any?, completion: @escaping (CustomActionResult) -> Void) {
          print("handleCustomAction \(id) \(type) \(payload.debugDescription)")
  
          //Called when pop-up handling is complete (handling result)
          // Sucess
          let result = CustomActionResult(id: id, success: true, message: "Coupon download was successful.", status: .SHOW, alertType: .ALERT)
          // Failure
          let result = CustomActionResult(id: id, success: false, message: "Coupon download failed.", status: .HIDE, alertType: .TOAST)
          completion(result)
      }
      ...
  }
  ```
  <br>
  
  > Application guide
  
  - [Using coupon](./index.md#step-4-using-coupon)

<br>

 - ### NextActionOnHandleNavigation option

    > Set next Shoplive Player action when a user selects a link, such as a product, announcement, or banner.

    <br>

    ```swift
    public enum ActionType: Int {
        case PIP
        case KEEP
        case CLOSE
    }
    ```

    | Parameter| Description |
    | ----------- | --- |
    | PIP     | Switch to PIP |
    | KEEP    | Keep in status |
    | CLOSE  | Close |

    <br>

    - #### setNextActionOnHandleNavigation(actionType:)

        ```swift
        setNextActionOnHandleNavigation(actionType: ActionType)
        ```

        | Parameter | Description |
        | ---------- | --- |
        | actionType  | Next Shoplive Player action when a user selects a link |

        <br>

        > Sample code
        ```swift
        // Switch to PIP
        ShopLive.setNextActionOnHandleNavigation(.PIP)
    
        // Keep in status
        ShopLive.setNextActionOnHandleNavigation(.KEEP)
    
        // Close
        ShopLive.setNextActionOnHandleNavigation(.CLOSE)
        ```

    <br>

    - #### getNextActionTypeOnHandleNavigation() -> ActionType 
    
        > Check the next Shoplive Player action when user selects a link.

        ```swift
        getNextActionTypeOnHandleNavigation() -> ActionType
        ```
        
        <br>

        > Sample code
        ```swift
        print(ShopLive.getNextActionTypeOnHandleNavigation())
        ```
        <br>
        
        > Application guide  
        - [Setting Shoplive Player's next action when a user selects a link](./index.md#step-11-setting-shoplive-players-next-action-when-a-user-selects-a-link)


<br>

- ### setEndpoint(_ url:)

    > Use this when you need to use the Shoplive service on a specific landing page or URL that is not the Shoplive Web landing page.
    > For example, if the Shoplive landing page is not available due to security reasons, create a landing page with a specific domain.<br>
    > ※ Using the Shoplive service on a specific landing page or URL is applicable only after consultation with Shoplive.

    <br>

    ```swift
    setEndpoint(_ url: String?)
    ```
    
    | Parameter | Description |
    | ---------- | --- |
    | url  | Shoplive Player's Web landing URL |

    <br>

    > Sample code
    ```swift
    // Set the Web landing URL in Shoplive Player
    ShopLive.setEndpoint("{Shoplive Player's' Web landing URL}")

    // Initialize
    ShopLive.setEndpoint(nil)
    ```

    <br>

- ### handleError(code:, message:)
  
  > Delivers a message about an error situation that occurs before or during the campaign.
  
  ```swift
  handleError(code: String, message: String)
  ```
  
  | Parameter| Description
  |----------|----------
  | code| Error code
  | message| Error message

  <br>

  > Sample code
  
  ```swift
  extension MainViewController: ShopLiveSDKDelegate {
      func handleError(code: String, message: String) {}
          print("handleError \(code) \(message)")
      }
      ...
  }
  ```
<br>
