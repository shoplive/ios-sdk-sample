# Change Log

- v1.2.2(2022-03-10)
  + We improved to link quiz functions such as vibration and sound effects.
  + We improved to does not switch to PIP in the app even if the user swipes down when there is an Analog Dialog or other screen in Shoplive Player.
  + Added API that is selectable the next action instead of forcibly switching to PIP in the app when the user selects a product or notices.
  + Added API to set endpoint.
  

<br>

- v1.2.1(2022-01-13)
  + We improved logic that automatically changes image quality depending on the viewer's network environment, and improved live streaming to be more stable.
  + When PIP runs inside the customer's Mobile App, the exposure position of the PIP is automatically changed according to the height of the keyboard

<br>

- v1.2.0(2021-12-15)
  + added ShopLive.isSuccessCampaignJoin() interface

<br>

- v1.1.4(2021-12-08)
  + added ShopLive.sdkVersion interface

<br>
  
- v1.1.3(2021-11-15)
  + added handleReceivedCommand callback

<br>

- v1.1.2(2021-11-11)
  + added ShopLive.setLoadingAnimation(images:) interface
  + changed handleCustomActionResult, handleCustomActionResult callback to optional

<br>

- v1.1.1(2021-11-08)
  + added handleCustomActionResult, handleCustomActionResult callback
  + added onSetUserName callback

<br>

- v1.0.18(2021-10-01)
  + added ShopLive.user.add(params:) interface

<br>

- v1.0.17(2021-09-16)
  + added ShopLive.setKeepAspectOnTabletPortrait(_ keep:) interface

<br>

- v1.0.16(2021-09-08)
  + reactivated playing settings API after phone call on sound policy (does not use CallKit)
  + fixed to display load indicator only during initia video play
  + applied to seek stream's most recent position during OS PIP video stop/ressume on live
 
<br>

- v1.0.13(2021-09-06)
  + added a loading indicator. (Default: White)
  + fixed to display inapp PIP on tio of keyboard.

<br>

- v1.0.10(2021-09-01)
  + changed player status to Command's payload value type (from String to Int)
  + added hookNavigation API
  + applied to deliver event following player's status change through handleCommand.
  + default screen change to pip mode when entering as handleNavigation on product selection.

<br>

- v1.0.6(2021-08-31)
  + disabled resume settings API after phone call on sound policy (some countries disallow CallKit)
  + fixed a bug on preview switch handling.

<br>

- v1.0.4(2021-08-30)
  + added Preview API to start PIP from current screen as a preview
  + added property to use ShopLive campaign screen's ViewController

<br>

- v1.0.3(2021-08-22)
  + applied to re-attempt reconnect during unstable connections
  + changed share API's scheme parameter to optional from required
  + added close ( player close) API
  + deliver campaign information on campaign entry
  + deliver status values if campaign status changes
  + deliver code/message if error occurs
  + default value for returning after a phone call from 'stop video' to 'automatically resume video'


<br>
- v1.0.2(2021-08-09)
  + fixed a problem where instance was not disabled when the player was turned off.

<br>

- v1.0.1(2021-08-05)
  + fixed a problem where event was not delivered to handleDownloadCoupon.






