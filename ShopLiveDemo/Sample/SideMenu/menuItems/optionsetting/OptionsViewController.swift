//
//  OptionsViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

final class OptionsViewController: SideMenuItemViewController {

    var items: [SDKOption] = []

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.contentInsetAdjustmentBehavior = .never
        view.alwaysBounceVertical = false
        view.register(SwitchOptionCell.self, forCellReuseIdentifier: "SwitchOptionCell")
        view.register(ButtonOptionCell.self, forCellReuseIdentifier: "ButtonOptionCell")
        view.register(OptionSectionHeader.self, forHeaderFooterViewReuseIdentifier: "OptionSectionHeader")
        view.contentInset = .init(top: 0, left: 0, bottom: ((UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + 16), right: 0)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = SideMenuTypes.options.stringKey.localized()
        removeTapGesture()
        setupOptions()
        setupViews()
    }

    private func setupViews() {
        if #available(iOS 15, *) {
            tableView.sectionHeaderTopPadding = 1
        }
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupOptions() {
        let headphoneOption1 = SDKOptionItem(name: "sdkoption.headphoneOption1.title".localized(), optionDescription: "sdkoption.headphoneOption1.description".localized(), optionType: .headphoneOption1)
        let callOption = SDKOptionItem(name: "sdkoption.callOption.title".localized(), optionDescription: "sdkoption.callOption.description".localized(), optionType: .callOption)

        let autoPlayOptions = SDKOption(optionTitle: "sdkoption.section.autoPlay.title".localized(), optionItems: [headphoneOption1, callOption])

        items.append(autoPlayOptions)

        let customShareOption = SDKOptionItem(name: "sdkoption.customShare.title".localized(), optionDescription: "sdkoption.customShare.description".localized(), optionType: .customShare)

        let shareSchemeOption = SDKOptionItem(name: "sdkoption.shareScheme.title".localized(), optionDescription: "sdkoption.shareScheme.description".localized(), optionType: .shareScheme)

        let shareOptions = SDKOption(optionTitle: "sdkoption.section.share.title".localized(), optionItems: [customShareOption, shareSchemeOption])

        items.append(shareOptions)

        let progressColorOption = SDKOptionItem(name: "sdkoption.progressColor.title".localized(), optionDescription: "sdkoption.progressColor.description".localized(), optionType: .progressColor)

        let customProgressOption = SDKOptionItem(name: "sdkoption.customProgress.title".localized(), optionDescription: "sdkoption.customProgress.description".localized(), optionType: .customProgress)

        let progressOptions = SDKOption(optionTitle: "sdkoption.section.progress.title".localized(), optionItems: [progressColorOption, customProgressOption])

        items.append(progressOptions)

        let chatInputFontOption = SDKOptionItem(name: "sdkoption.chatInputCustomFont.title".localized(), optionDescription: "sdkoption.chatInputCustomFont.description".localized(), optionType: .chatInputCustomFont)

        let chatSendButtonFontOption = SDKOptionItem(name: "sdkoption.chatSendButtonCustomFont.title".localized(), optionDescription: "sdkoption.chatSendButtonCustomFont.description".localized(), optionType: .chatSendButtonCustomFont)

        let chatFontOptions = SDKOption(optionTitle: "sdkoption.section.chatFont.title".localized(), optionItems: [chatInputFontOption, chatSendButtonFontOption])

        items.append(chatFontOptions)
    }

}

extension OptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let item = items[safe: indexPath.section]?.optionItems[safe: indexPath.row]  else {
            return UITableViewCell()
        }

        switch item.optionType.settingType {
        case .switchControl:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchOptionCell", for: indexPath) as? SwitchOptionCell else {
                return UITableViewCell()
            }
            cell.configure(item: item)
            return cell
        case .showAlert:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonOptionCell", for: indexPath) as? ButtonOptionCell else {
                return UITableViewCell()
            }
            cell.configure(item: item)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].optionItems.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OptionSectionHeader") as? OptionSectionHeader, let item = items[safe: section] else { return nil }
        header.configure(headerTitle: item.optionTitle, section: section)
        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let item = items[safe: indexPath.section]?.optionItems[safe: indexPath.row], item.optionType.settingType == .showAlert else { return }

        switch item.optionType {
        case .shareScheme:
            let schemeAlert = TextItemInputAlertController(header: "공유하기", data: DemoConfiguration.shared.shareScheme, placeHolder: "scheme 또는 url") { scheme in
                DemoConfiguration.shared.shareScheme = scheme
                self.tableView.reloadData()
            }
            schemeAlert.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(schemeAlert, animated: false, completion: nil)
            break
        case .progressColor:
            let schemeAlert = TextItemInputAlertController(header: "로딩 프로그레스 색상", data: DemoConfiguration.shared.progressColor, placeHolder: "ex) #FF0000") { color in
                DemoConfiguration.shared.progressColor = color
                self.tableView.reloadData()
            }
            schemeAlert.modalPresentationStyle = .overCurrentContext
            self.navigationController?.present(schemeAlert, animated: false, completion: nil)
            break
        default:
            break
        }

    }



}
