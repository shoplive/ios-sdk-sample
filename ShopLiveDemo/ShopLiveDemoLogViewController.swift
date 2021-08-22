//
//  ShopLiveDemoLogViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/08/18.
//

import UIKit

final class ShopLiveDemoLogger {
    let v = ShopLiveDemoLogViewController()

    private lazy var logWindow: UIWindow = {
        let window = UIWindow()
        window.backgroundColor = .black
        window.alpha = 0.6
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width / 2, height: UIScreen.main.bounds.size.height / 2)
        window.center = CGPoint(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.5)
        window.setNeedsLayout()
        window.layoutIfNeeded()

        v.view.isUserInteractionEnabled = true
        window.isUserInteractionEnabled = true
        if #available(iOS 13.0, *) {
            window.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        } else {
            // Fallback on earlier versions
        }
        window.rootViewController = v
        window.isHidden = true
        window.makeKeyAndVisible()
        return window
    }()

    static var shared: ShopLiveDemoLogger = {
        return ShopLiveDemoLogger()
    }()


    func setVisible(show: Bool) {
        logWindow.isHidden = !show
    }

    func addLog(log: String) {
        v.addLog(log: log)
    }
}

final class ShopLiveDemoLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var logs: [String] = []
    private lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.allowsSelection = false
        v.allowsMultipleSelection = false
        v.dataSource = self
        v.delegate = self
        v.backgroundColor = .black
        v.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }

    private func setupViews() {
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: view.topAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     tableView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }

    func addLog(log: String) {
        self.logs.append(log)
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if let log: String = logs[safe: indexPath.row] {
            cell?.textLabel?.text = log
        }

        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = .byWordWrapping
        cell?.textLabel?.textColor = .white
        cell?.backgroundColor = .black


        return cell ?? UITableViewCell()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Array {
    subscript (safe index: Int) -> Element? {
        // iOS 9 or later
        return indices ~= index ? self[index] : nil
        // iOS 8 or earlier
        // return startIndex <= index && index < endIndex ? self[index] : nil
        // return 0 <= index && index < self.count ? self[index] : nil
    }
}
