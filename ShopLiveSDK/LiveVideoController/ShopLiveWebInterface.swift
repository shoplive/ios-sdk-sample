//
//  ShopLiveWebInterface.swift
//  ShopLiveSDK
//
//  Created by purpleworks on 2021/02/05.
//

import Foundation
import WebKit

enum WebInterface {
    static var allFunctions: [WebFunction] {
        return WebFunction.allCases
    }
    
    case systemInit
    case setPosterUrl(url: URL)
    case setForegroundPosterUrl(url: URL)
    case setLiveStreamUrl(url: URL)
    case setVideoMute(isMuted: Bool)
    case setIsPlayingVideo(isPlaying: Bool)
    case reloadVideo
    case startPictureInPicture
    case close
    case navigation(url: URL)
    case coupon(id: String)
    case playVideo
    case pauseVideo
    case clickShareButton(url: URL)
    case replay(width: CGFloat, height: CGFloat)
    case command(command: String, payload: Any?)
    
    var functionString: String {
        switch self {
        case .systemInit:
            return WebFunction.systemInit.rawValue
        case .setPosterUrl:
            return WebFunction.setPosterUrl.rawValue
        case .setForegroundPosterUrl:
            return WebFunction.setForegroundPosterUrl.rawValue
        case .setLiveStreamUrl:
            return WebFunction.setLiveStreamUrl.rawValue
        case .setVideoMute:
            return WebFunction.setVideoMute.rawValue
        case .setIsPlayingVideo:
            return WebFunction.setIsPlayingVideo.rawValue
        case .reloadVideo:
            return WebFunction.reloadVideo.rawValue
        case .startPictureInPicture:
            return WebFunction.startPictureInPicture.rawValue
        case .close:
            return WebFunction.close.rawValue
        case .navigation:
            return WebFunction.navigation.rawValue
        case .coupon:
            return WebFunction.coupon.rawValue
        case .playVideo:
            return WebFunction.playVideo.rawValue
        case .pauseVideo:
            return WebFunction.pauseVideo.rawValue
        case .clickShareButton:
            return WebFunction.clickShareButton.rawValue
        case .replay:
            return WebFunction.replay.rawValue
        case .command:
            return WebFunction.command.rawValue
        }
    }
    
    enum WebFunction: String, CustomStringConvertible, CaseIterable {
        var description: String { return self.rawValue }
        
        case systemInit = "SYSTEM_INIT"
        case setPosterUrl = "SET_POSTER_URL"
        case setForegroundPosterUrl = "SET_FG_POSTER_URL"
        case setLiveStreamUrl = "SET_LIVE_STREAM_URL"
        case setVideoMute = "SET_VIDEO_MUTE"
        case setIsPlayingVideo = "SET_IS_PLAYING_VIDEO"
        case reloadVideo = "RELOAD_VIDEO"
        case startPictureInPicture = "ENTER_PIP"
        case close = "CLOSE"
        case navigation = "NAVIGATION"
        case coupon = "DOWNLOAD_COUPON"
        case playVideo = "PLAY_VIDEO"
        case pauseVideo = "PAUSE_VIDEO"
        case clickShareButton = "CLICK_SHARE_BTN"
        case replay = "REPLAY"
        case command = "COMMAND"
    }
}

extension WebInterface {
    init?(message: WKScriptMessage) {
        guard message.name == "ShopLiveAppInterface" else { return nil }
        guard let body = message.body as? [String: Any] else { return nil }
        guard let command = body["action"] as? String else { return nil }
        let function = WebFunction(rawValue: command)
        let parameters = body["payload"] as? [String: Any]
        
        switch function {
        case .systemInit:
            self = .systemInit
        case .setPosterUrl:
            guard let urlString = parameters?["posterUrl"] as? String else { return nil }
            guard let url = URL(string: urlString) else { return nil }
            self = .setPosterUrl(url: url)
        case .setForegroundPosterUrl:
            guard let urlString = parameters?["posterUrl"] as? String else { return nil }
            guard let url = URL(string: urlString) else { return nil }
            self = .setForegroundPosterUrl(url: url)
        case .setLiveStreamUrl:
            guard let urlString = parameters?["liveStreamUrl"] as? String else { return nil }
            guard let url = URL(string: urlString) else { return nil }
            self = .setLiveStreamUrl(url: url)
        case .setVideoMute:
            guard let isMuted = parameters?["isMuted"] as? Bool else { return nil }
            self = .setVideoMute(isMuted: isMuted)
        case .setIsPlayingVideo:
            guard let isPlaying = parameters?["isPlaying"] as? Bool else { return nil }
            self = .setIsPlayingVideo(isPlaying: isPlaying)
        case .reloadVideo:
            self = .reloadVideo
        case .startPictureInPicture:
            self = .startPictureInPicture
        case .close:
            self = .close
        case .navigation:
            guard let urlString = parameters?["url"] as? String else { return nil }
            guard let url = URL(string: urlString) else { return nil }
            self = .navigation(url: url)
        case .coupon:
            guard let couponId = parameters?["id"] as? String else { return nil }
            self = .coupon(id: couponId)
        case .playVideo:
            self = .playVideo
        case .pauseVideo:
            self = .pauseVideo
        case .clickShareButton:
            guard let urlString = parameters?["url"] as? String else { return nil }
            guard let url = URL(string: urlString) else { return nil }
            self = .clickShareButton(url:  url)
        case .replay:
            guard let width = parameters?["width"] as? CGFloat else { return nil }
            guard let height = parameters?["height"] as? CGFloat else { return nil }
            debugPrint("width: \(width) x height: \(height)")
            self = .replay(width: width, height: height)
        case .command:
            guard let customCommand = parameters?["action"] as? String else { return nil }
            let customPayload = parameters?["payload"]
            self = .command(command: customCommand, payload: customPayload)
        case .none:
            self = .command(command: command, payload: body["payload"])
        }
    }
}


