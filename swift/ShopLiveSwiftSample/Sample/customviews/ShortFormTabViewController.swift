//
//  ShortFormExampleViewController.swift
//  ShopLiveSwiftSample
//
//  Created by sangmin han on 2023/05/12.
//

import Foundation
import UIKit
import Parchment

class ShortFormTabViewController : UIViewController {
    
    var pagingViewController: PagingViewController?
    let cardTypeExampleViewController = ShortFormCardTypeViewController()
    let verticalTypeExamplViewController = ShortFormVerticalTypeViewController()
    let horizontalTypeExamplViewController = ShortFormHorizontalTypeViewController()
    
    lazy var viewControllers: [(String , UIViewController)] = [
        ("MAIN",cardTypeExampleViewController),
        ("ROW",verticalTypeExamplViewController),
        ("COL",horizontalTypeExamplViewController)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setUpTab()
        setLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setUpTab(){
        var options = PagingOptions()
        options.indicatorColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        options.selectedTextColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        options.menuBackgroundColor = .white
        options.borderOptions = .hidden
        options.menuPosition = .bottom
        options.menuItemSize = .sizeToFit(minWidth: view.bounds.width/4, height: 44)
        options.menuInteraction = .none
        options.contentInteraction = .none
        
        pagingViewController = PagingViewController(options: options)
        pagingViewController?.delegate = self
        pagingViewController?.dataSource = self
        pagingViewController?.collectionView.isScrollEnabled = false
    }
    
    
}
extension ShortFormTabViewController {
    private func setLayout(){
        addChild(pagingViewController!)
        view.addSubview(pagingViewController!.view)
        pagingViewController!.didMove(toParent: self)
        
        pagingViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pagingViewController!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingViewController!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingViewController!.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pagingViewController!.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
}
extension ShortFormTabViewController : PagingViewControllerDataSource, PagingViewControllerDelegate {
    func pagingViewController(_: Parchment.PagingViewController, pagingItemAt index: Int) -> Parchment.PagingItem {
        return PagingIndexItem(index: index, title: viewControllers[index].0)
    }
    
    func pagingViewController(_: Parchment.PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return viewControllers[index].1
    }
    
    func numberOfViewControllers(in pagingViewController: Parchment.PagingViewController) -> Int {
        return viewControllers.count
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
      
    }
    
}
