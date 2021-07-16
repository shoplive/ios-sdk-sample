//
//  keySetRegisterController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/06/09.
//

import UIKit
import ShopLiveSDK

protocol KeySetRegisterDelegate: AnyObject {
    func upateKeyInfo(key: ShopLiveKeySet)
}

final class KeySetRegisterController: UIViewController {

    weak var delegate: KeySetRegisterDelegate?
    @IBOutlet weak var alistText: UITextField!
    @IBOutlet weak var campaignText: UITextField!
    @IBOutlet weak var accessText: UITextField!
    @IBOutlet weak var tableView: UITableView!

    private var keysets: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        hideKeyboard()
        loadDatas()
    }

    private func loadDatas() {
        keysets.removeAll()
        keysets = ShopLiveDemoKeyTools.shared.alias()
        tableView.reloadData()
    }

    private func setupViews() {
        let tableTapGesture = UIGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tableTapGesture)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    private func configure(key: ShopLiveKeySet) {
        self.alistText.text = key.alias
        self.campaignText.text = key.campaignKey
        self.accessText.text = key.accessKey
    }

    @IBAction func register(_ sender: Any) {
        guard let alias = alistText.text, let campaign = campaignText.text, let accessKey = accessText.text else {
            return
        }

        guard !alias.isEmpty && !campaign.isEmpty && !accessKey.isEmpty else {
            return
        }

        ShopLiveDemoKeyTools.shared.save(key: .init(alias: alias, campaignKey: campaign, accessKey: accessKey))
        loadDatas()
        tableView.reloadData()
    }

    func useKeyset(key: ShopLiveKeySet) {
        ShopLiveDemoKeyTools.shared.saveCurrentKey(alias: key.alias)
        self.dismiss(animated: true, completion: {
            self.delegate?.upateKeyInfo(key: key)
            self.dismissKeyboard()
        })
    }

    private func openSelectSheet(key: ShopLiveKeySet) {
        let keySheet = UIAlertController.init(title: "선택한 키: [\(key.alias)]", message: nil, preferredStyle: .alert)

        keySheet.addAction(.init(title: "수정", style: .default, handler: { _ in
            self.configure(key: key)
            self.dismissKeyboard()
        }))
        keySheet.addAction(.init(title: "삭제", style: .default, handler: { _ in
            ShopLiveDemoKeyTools.shared.delete(alias: key.alias)
            self.loadDatas()
        }))
        keySheet.addAction(.init(title: "적용", style: .default, handler: { _ in
            self.useKeyset(key: key)
        }))

        keySheet.addAction(.init(title: "취소", style: .cancel, handler: nil))

        self.present(keySheet, animated: true, completion: nil)
    }

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            guard let key = ShopLiveDemoKeyTools.shared.currentKey() else { return }
            self.delegate?.upateKeyInfo(key: key)
        })
    }
}

extension KeySetRegisterController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        keysets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = keysets[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        guard let key = ShopLiveDemoKeyTools.shared.load(alias: keysets[indexPath.row]) else { return }

        openSelectSheet(key: key)
//        configure(key: key)
    }
}

extension KeySetRegisterController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        if touch.view?.isDescendant(of: self.tableView) == true {
            return false
        }
        return true
    }
}
