//
//  ShopLiveWebView.swift
//  shopliveWebviewOveray
//
//  Created by ShopLive on 2021/03/12.
//

import Foundation
import WebKit

internal final class ShopLiveWebView: WKWebView {
    override var inputAccessoryView: UIView? {
        return nil
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }

    func sendEventToWeb(event: WebInterface, _ param: Any? = nil, _ wrapping: Bool = false) {
        let command: String = param == nil ? "window.__receiveAppEvent('\(event.functionString)');" : "window.__receiveAppEvent('\(event.functionString)', " + (wrapping ? "'\(String(describing: param!))');" : "\(String(describing: param!)));")
        self.evaluateJavaScript(command, completionHandler: nil)
    }
}

extension Dictionary {
    func toJson() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        if let jsonString = String(data: jsonData!, encoding: .utf8){
            return jsonString
        }else{
            return nil
        }
    }
}
