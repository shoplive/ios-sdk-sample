//
//  SampleBaseViewController.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/12/23.
//

import UIKit

class SampleBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        setupNavigation()
        setupEdgeGesture()
        setupBackButton()
    }

    @objc func setupNavigation() {
        // navigation background color
        let naviBgColor = UIColor(red: 238/255, green: 52/255, blue: 52/255, alpha: 1)
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = naviBgColor
            self.navigationController?.navigationBar.standardAppearance = appearance;
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        } else {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.navigationBar.tintColor = naviBgColor
        }
    }

    func setupBackButton() {
        guard self.navigationController?.viewControllers.count ?? 1 > 1 else { return }
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(handleNaviBack)
        )
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton

        self.navigationController?.navigationBar.topItem?.backBarButtonItem = nil
    }

    @objc func handleNaviBack() {
        shopliveHideKeyboard()
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func handleEdgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .recognized else {
            return
        }
        shopliveHideKeyboard()
        self.navigationController?.popViewController(animated: true)
    }

    private func setupEdgeGesture() {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeGesture(_:)))
        edgePanGesture.edges = .left
        self.view.addGestureRecognizer(edgePanGesture)
    }
}
