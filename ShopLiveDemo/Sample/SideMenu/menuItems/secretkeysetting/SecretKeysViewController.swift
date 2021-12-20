//
//  SecretKeysViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/19.
//

import UIKit

final class SecretKeysViewController: SideMenuItemViewController {

    var items: [DemoSecretKeySet] = []
    var selectKeySet: Bool = false

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.register(SecretKeyCell.self, forCellReuseIdentifier: "SecretKeyCell")
        view.backgroundColor = .white
        view.contentInset = .init(top: 0, left: 0, bottom: ((UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + 16), right: 0)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        removeTapGesture()
        DemoSecretKeyTool.shared.addKeysetObserver(observer: self)
        items = DemoSecretKeyTool.shared.keysets
        setupNaviItems()
        setupViews()
    }

    func setupViews() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupNaviItems() {
        self.title = "menu.userinfo.secretkey".localized()
        let save = UIBarButtonItem(title: "sdk.user.secret.add".localized(from: "shoplive"), style: .plain, target: self, action: #selector(saveAct))

        save.tintColor = .white

        self.navigationItem.rightBarButtonItem = save
    }

    @objc func saveAct() {
        let vc = SecretKeyInputAlertController()
        vc.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(vc, animated: false, completion: nil)
    }

    func updateTableView() {
        self.items = DemoSecretKeyTool.shared.keysets
        self.tableView.reloadData()
    }
}

extension SecretKeysViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SecretKeyCell", for: indexPath) as? SecretKeyCell, let item = items[safe: indexPath.row] else {
            return UITableViewCell()
        }

        cell.configure(keySet: item)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            if let item = items[safe: indexPath.row] {
                DemoSecretKeyTool.shared.delete(name: item.name)
            } else {

            }
            updateTableView()
            break
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard selectKeySet else { return }

        guard let item = items[safe: indexPath.row] else { return }

        DemoSecretKeyTool.shared.saveCurrentKey(name: item.name)
        self.navigationController?.popViewController(animated: true)
    }
}

extension SecretKeysViewController: SecretKeySetObserver {

    var identifier: String {
        get {
            return "SecretKeysViewController"
        }
    }

    func setretKeysetUpdated() {
        updateTableView()
    }

}

