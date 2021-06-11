//
//  ShopLiveWebView.swift
//  shopliveWebviewOveray
//
//  Created by ShopLive on 2021/03/12.
//

import Foundation
import WebKit

class ShopLiveWebView: WKWebView {
    override var inputAccessoryView: UIView? {
        return nil
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }

    func sendEventToWeb(event: WebInterface, _ param: Any? = nil) {
        let command: String = param == nil ? "window.__receiveAppEvent('\(event.functionString)');" : "window.__receiveAppEvent('\(event.functionString)', \(String(describing: param!)));"

        self.evaluateJavaScript(command, completionHandler: nil)
    }
}
