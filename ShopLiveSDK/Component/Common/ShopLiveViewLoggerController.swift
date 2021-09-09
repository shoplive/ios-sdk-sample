//
//  ShopLiveDemoLogViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/08/18.
//

import UIKit

final class ShopLiveViewLogger {
    let v = ShopLiveViewLoggerController()

    var panGestureInitialCenter: CGPoint = .zero
    @objc private func windowPanGestureHandler(_ recognizer: UIPanGestureRecognizer) {
        guard let liveWindow = recognizer.view else { return }

        let translation = recognizer.translation(in: liveWindow)

        switch recognizer.state {
        case .began:
            panGestureInitialCenter = liveWindow.center
        case .changed:
            let centerX = panGestureInitialCenter.x + translation.x
            let centerY = panGestureInitialCenter.y + translation.y
            liveWindow.center = CGPoint(x: centerX, y: centerY)
        case .ended:
            break
        default:
            break
        }
    }

    private lazy var logWindow: UIWindow = {
        let window = UIWindow()
        window.backgroundColor = .black
        window.alpha = 0.6
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.96, height: UIScreen.main.bounds.size.height / 2)
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

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(windowPanGestureHandler))
        window.addGestureRecognizer(panGesture)

        window.rootViewController = v
        window.isHidden = true
        window.makeKeyAndVisible()
        return window
    }()

    static var shared: ShopLiveViewLogger = {
        return ShopLiveViewLogger()
    }()

    func setVisible(show: Bool) {
        logWindow.isHidden = !show
    }

    func addLog(log: String) {
        v.addLog(log: log)
    }
}

final class ShopLiveViewLoggerController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var logs: [String] = []
    @objc private dynamic var isOn: Bool = true

    private var videoWindowPanGestureRecognizer: UIPanGestureRecognizer?

    private lazy var onOffButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.7
        button.backgroundColor = .lightGray
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(didTapOnOffButton(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.allowsSelection = false
        v.allowsMultipleSelection = false
        v.separatorStyle = .none
        v.dataSource = self
        v.delegate = self
        v.backgroundColor = .black
        v.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        v.register(ShopLiveViewLoggerCell.self, forCellReuseIdentifier: "LogCell")
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        addObserver()
    }

    deinit {
        removeObserver()
    }

    private func setupViews() {

        self.view.addSubview(onOffButton)

        let onOffWidth: NSLayoutConstraint = .init(item: onOffButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOffHeight: NSLayoutConstraint = .init(item: onOffButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOffLeading: NSLayoutConstraint = .init(item: onOffButton, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0)
        let onOffTop: NSLayoutConstraint = .init(item: onOffButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)

        onOffButton.addConstraints([onOffWidth, onOffHeight])
        self.view.addConstraints([onOffLeading, onOffTop])

        self.view.addSubview(tableView)

        let tableViewTop: NSLayoutConstraint = .init(item: tableView, attribute: .top, relatedBy: .equal, toItem: onOffButton, attribute: .bottom, multiplier: 1.0, constant: 0)
        self.view.addConstraint(tableViewTop)
        NSLayoutConstraint.activate([ tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

    }

    @objc func didTapOnOffButton(_ sender: UIButton) {
        self.isOn = !self.isOn
//window.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: UIScreen.main.bounds.size.height / 2)
        guard let x = self.view.window?.frame.origin.x, let y = self.view.window?.frame.origin.y else { return }
        self.view.window?.frame = isOn ? CGRect(x: x, y: y, width: UIScreen.main.bounds.size.width * 0.9, height: UIScreen.main.bounds.size.height / 2) : CGRect(x: x, y: y, width: onOffButton.frame.width, height: onOffButton.frame.width)
    }

    func addLog(log: String) {
        self.logs.append(log)
        self.tableView.reloadData()
        self.scrollToBottom()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as? ShopLiveViewLoggerCell else {
            return UITableViewCell.init(style: .default, reuseIdentifier: "Cell")
        }

        if let log: String = logs[safe: indexPath.row] {
            cell.configure(log: log)
        }

        return cell
    }

    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath.init (row: self.logs.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

}

extension ShopLiveViewLoggerController {

    private func addObserver() {
        self.addObserver(self, forKeyPath: "isOn", options: [.initial, .old, .new], context: nil)
    }

    private func removeObserver() {
        self.removeObserver(self, forKeyPath: "isOn")
    }

    func handleIsOn() {
        onOffButton.setTitle(isOn ? "닫기" : "열기", for: .normal)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else { return }

        switch key {
        case "isOn":
            handleIsOn()
            break
        default:
            break
        }
    }
}


final class ShopLiveViewLoggerCell: UITableViewCell {

    private lazy var logLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {

        self.backgroundColor = .clear

        self.addSubview(logLabel)

        let leadingConstraint: NSLayoutConstraint = .init(item: logLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 10)
        let trailingConstraint: NSLayoutConstraint = .init(item: logLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -10)
        let topConstraint: NSLayoutConstraint = .init(item: logLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 1)
        let bottomConstraint: NSLayoutConstraint = .init(item: logLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -1)
        self.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }

    func configure(log: String) {
        self.logLabel.text = log
    }

}
