//
//  MainViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit
import SideMenu

class MainViewController: SideMenuBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        self.title = "SDK Demo"
        setupSampleOptions()
    }

    func setupSampleOptions() {
        SampleOptions.campaignNaviMoreOptions = ["직접 입력", "Dev-Admin", "Admin", "전체삭제"]
        SampleOptions.campaignNaviMoreSelectionAction = { (index: Int, item: String) in
            print("selected item: \(item) index: \(index)")

            switch index {
            case 0: // 직접 입력
                let vc = CampaignInputAlertController()
//                self.present(vc, animated: true)
//                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KeySetRegisterController") as? KeySetRegisterController else { return }
                vc.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(vc, animated: false, completion: nil)
                break
            case 1: // Dev-Admin
                print("Dev-Admin")
                break
            case 2: // Admin
                print("Admin")
                break
            case 3: // 전체삭제
                print("전체삭제")
                ShopLiveDemoKeyTools.shared.clearKey()
                break
            default:
                break
            }

        }
    }

    override func preview() {

    }

    override func play() {

    }

}
