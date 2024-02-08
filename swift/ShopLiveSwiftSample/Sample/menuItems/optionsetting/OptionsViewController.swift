//
//  OptionsViewController.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit
import DropDown

final class OptionsViewController: SampleBaseViewController {

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

        setupNaviItems()
        setupOptions()
        setupViews()
    }

    override func handleNaviBack() {
        DemoConfiguration.shared.updateOptions()
        super.handleNaviBack()
    }

    private func setupNaviItems() {
        self.title = "sample.menu.step3.title".localized()
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

        let aspectOnTabletOption = SDKOptionItem(name: "sdkoption.section.setupPlayer.tabletAspect.title".localized(), optionDescription: "sdkoption.section.setupPlayer.tabletAspect.description".localized(), optionType: .aspectOnTablet)
        let keepWindowStateOnPlayExecutedOption = SDKOptionItem(name: "sdkoption.section.setupPlayer.keepWindowStateOnPlayExecuted.title".localized(), optionDescription: "sdkoption.section.setupPlayer.keepWindowStateOnPlayExecuted.description".localized(), optionType: .keepWindowStateOnPlayExecuted)
        
        let mixAudioOption = SDKOptionItem(name: "sdkoption.setupPlayer.mixAudio.title".localized(), optionDescription: "sdkoption.setupPlayer.mixAudio.description".localized(), optionType: .mixAudio)
        let statusBarVisibilityOption = SDKOptionItem(name: "sdkoption.statusbarvisibility.title".localized(), optionDescription: "sdkoption.statusbarvisibility.description".localized(), optionType: .statusBarVisibility)
        let setupPlayerOptions = SDKOption(optionTitle: "sdkoption.section.setupPlayer.title".localized(), optionItems: [aspectOnTabletOption, keepWindowStateOnPlayExecutedOption,mixAudioOption,statusBarVisibilityOption])
        
        items.append(setupPlayerOptions)
        
        let muteOption = SDKOptionItem(name: "sdkoption.sound.mute.title".localized(), optionDescription: "sdkoption.sound.mute.description".localized(), optionType: .mute)
        let muteOptions = SDKOption(optionTitle: "sdkoption.section.sound.title".localized(), optionItems: [muteOption])
        
        items.append(muteOptions)
        
        let previewOption = SDKOptionItem(name: "sdkoption.preview.title".localized(), optionDescription: "sdkoption.preview.description".localized(), optionType: .playWhenPreviewTapped)
        let closeButtonOption = SDKOptionItem(name: "sdkoption.preview.closebutton.title".localized(), optionDescription: "sdkoption.preview.closebutton.description".localized(), optionType: .useCloseButton)
        let previewOptions = SDKOption(optionTitle: "sdkoption.section.preview.title".localized(), optionItems: [previewOption,closeButtonOption])
        
        items.append(previewOptions)
        
        //MARK: - Pip Modes
        let pipPositionOption = SDKOptionItem(name: "sdkoption.pipPosition.title".localized(), optionDescription: "sdkoption.pipPosition.description".localized(), optionType: .pipPosition)
        let pipMaxSizeOption = SDKOptionItem(name: "sdkOption.pipMaxSize.title".localized(), optionDescription: "sdkOption.pipMaxSize.description".localized(), optionType: .maxPipSize)
        let pipFixedHeightOption = SDKOptionItem(name: "sdkOption.pipFixedHeight.title".localized(), optionDescription: "sdkOption.pipFixedHeight.description".localized(), optionType: .fixedHeightPipSize)
        let pipFixedWidthOption = SDKOptionItem(name: "sdkOption.pipFixedWidth.title".localized(), optionDescription: "sdkOption.pipFixedWidth.description".localized(), optionType: .fixedWidthPipSize)
        
        
        
        let nextActionPipOption = SDKOptionItem(name: "sdkoption.nextActionTypeOnNavigation.title".localized(), optionDescription: "sdkoption.nextActionTypeOnNavigation.description".localized(), optionType: .nextActionOnHandleNavigation)
        let pipKeepWindowStyle = SDKOptionItem(name: "sdkoption.pipKeepWindowStyle.title".localized(), optionDescription: "sdkoption.pipKeepWindowStyle.description".localized(), optionType: .pipKeepWindowStyle)
        let pipAreaOption = SDKOptionItem(name: "sdkoption.pipAreaSetting.title".localized(), optionDescription: "sdkoption.pipAreaSetting.description".localized(), optionType: .pipFloatingOffset)
        
        let pipEnableSwipeOutOption = SDKOptionItem(name: "sdkoption.pipEnableSwipeOutOption.title".localized(), optionDescription: "sdkoption.pipEnableSwipeOutOption.description".localized(), optionType: .pipEnableSwipeOut)
        
        let pipOptions = SDKOption(optionTitle: "sdkoption.section.pip.title".localized(), optionItems: [pipPositionOption,pipMaxSizeOption,pipFixedHeightOption,pipFixedWidthOption, nextActionPipOption, pipKeepWindowStyle, pipAreaOption,pipEnableSwipeOutOption])
        
        items.append(pipOptions)

        let headphoneOption1 = SDKOptionItem(name: "sdkoption.headphoneOption1.title".localized(), optionDescription: "sdkoption.headphoneOption1.description".localized(), optionType: .headphoneOption1)
        let headphoneOption2 = SDKOptionItem(name: "sdkoption.headphoneOption2.title".localized(), optionDescription: "sdkoption.headphoneOption2.description".localized(), optionType: .headphoneOption2)
        let callOption = SDKOptionItem(name: "sdkoption.callOption.title".localized(), optionDescription: "sdkoption.callOption.description".localized(), optionType: .callOption)

        let autoPlayOptions = SDKOption(optionTitle: "sdkoption.section.autoPlay.title".localized(), optionItems: [headphoneOption1, headphoneOption2, callOption])

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
        case .showAlert, .dropdown, .routeTo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonOptionCell", for: indexPath) as? ButtonOptionCell else {
                return UITableViewCell()
            }
            cell.configure(item: item)
            return cell
        case .routeTo:
            return UITableViewCell()
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

        guard let item = items[safe: indexPath.section]?.optionItems[safe: indexPath.row] else { return }

        switch item.optionType.settingType {
        case .showAlert:
            switch item.optionType {
            case .shareScheme:
                let schemeAlert = TextItemInputAlertController(header: "sdkoption.section.share.title".localized(), data: DemoConfiguration.shared.shareScheme, placeHolder: "sdkoption.shareScheme.alert.placeholder".localized()) { scheme in
                    DemoConfiguration.shared.shareScheme = scheme
                    self.tableView.reloadData()
                }
                schemeAlert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(schemeAlert, animated: false, completion: nil)
                break
            case .progressColor:
                let schemeAlert = TextItemInputAlertController(header: "sdkoption.progressColor.setting.guide".localized(), data: DemoConfiguration.shared.progressColor, placeHolder: "ex) #FF0000") { color in
                    DemoConfiguration.shared.progressColor = color.isEmpty ? nil : color
                    self.tableView.reloadData()
                }
                schemeAlert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(schemeAlert, animated: false, completion: nil)
                break
            case .maxPipSize:
                let fixedPipWidth = DemoConfiguration.shared.maxPipSize == nil ? "" : String(format: "%.0f",  DemoConfiguration.shared.maxPipSize!)
                let fixedPipWidthAlert = TextItemInputAlertController(header: "sdkOption.pipMaxSize.title".localized(), data: fixedPipWidth, placeHolder: "ex) 200") { fixedWidth in
                    DemoConfiguration.shared.maxPipSize = fixedWidth.cgfloatValue
                    DemoConfiguration.shared.fixedWidthPipSize = nil
                    DemoConfiguration.shared.fixedHeightPipSize = nil
                    self.tableView.reloadData()
                }
                fixedPipWidthAlert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(fixedPipWidthAlert, animated: false, completion: nil)
                break
            case .fixedHeightPipSize:
                let size = DemoConfiguration.shared.fixedHeightPipSize == nil ? "" : String(format: "%.0f",  DemoConfiguration.shared.fixedHeightPipSize!)
                let alert = TextItemInputAlertController(header: "sdkOption.pipFixedHeight.title".localized(), data: size, placeHolder: "ex) 200") { size in
                    DemoConfiguration.shared.fixedHeightPipSize = size.cgfloatValue
                    DemoConfiguration.shared.maxPipSize = nil
                    DemoConfiguration.shared.fixedWidthPipSize = nil
                    self.tableView.reloadData()
                }
                alert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(alert, animated: false, completion: nil)
                break
            case .fixedWidthPipSize:
                let size = DemoConfiguration.shared.fixedWidthPipSize == nil ? "" : String(format: "%.0f",  DemoConfiguration.shared.fixedWidthPipSize!)
                let alert = TextItemInputAlertController(header: "sdkOption.pipFixedWidth.title".localized(), data: size, placeHolder: "ex) 200") { size in
                    DemoConfiguration.shared.fixedWidthPipSize = size.cgfloatValue
                    DemoConfiguration.shared.fixedHeightPipSize = nil
                    DemoConfiguration.shared.maxPipSize = nil
                    self.tableView.reloadData()
                }
                alert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(alert, animated: false, completion: nil)
                break
            default:
                break
            }
            break
        case .dropdown:
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonOptionCell", for: indexPath) as? ButtonOptionCell else { return }

            let cellRect = view.convert(tableView.rectForRow(at: indexPath), from: tableView)
            let anchorView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            view.backgroundColor = .clear
            self.view.addSubview(anchorView)

            anchorView.frame = CGRect(origin: .init(x: 20, y: cellRect.origin.y + cell.frame.height), size: anchorView.frame.size)

            let dropdown = DropDown()
            dropdown.width = 150
            dropdown.anchorView = anchorView
            
            switch item.optionType {
                case .nextActionOnHandleNavigation:
                dropdown.dataSource = ["sdkoption.nextActionTypeOnNavigation.item1".localized(), "sdkoption.nextActionTypeOnNavigation.item2".localized(), "sdkoption.nextActionTypeOnNavigation.item3".localized()]
                    dropdown.selectionAction = { (index: Int, item: String) in
                        // print("selected item: \(item) index: \(index)")
                        DemoConfiguration.shared.nextActionTypeOnHandleNavigation = ActionType(rawValue: index) ?? .PIP
                        anchorView.removeFromSuperview()
                        self.tableView.reloadData()
                    }
                    break
                case .pipPosition:
                dropdown.dataSource = ["sdkoption.pipPosition.item1".localized(), "sdkoption.pipPosition.item2".localized(), "sdkoption.pipPosition.item3".localized(),"sdkoption.pipPosition.item4".localized()]
                    dropdown.selectionAction = { (index: Int, item: String) in
                        // print("selected item: \(item) index: \(index)")
                        DemoConfiguration.shared.pipPosition = ShopLive.PipPosition(rawValue: index) ?? .bottomRight
                        anchorView.removeFromSuperview()
                        self.tableView.reloadData()
                    }
                    break
                default:
                    break
            }

            dropdown.show()
            break
        case .routeTo:
            switch item.optionType {
            case .pipFloatingOffset:
                let pipAreaSetting = PipAreaSettingViewController()
                self.navigationController?.pushViewController(pipAreaSetting, animated: true)
                break
            default:
                break
            }
            break
        default:
            break
        }


    }


}

extension ActionType {
    var localizedName: String {
        switch self {
        case .PIP:
            return "sdkoption.nextActionTypeOnNavigation.item1".localized()
        case .KEEP:
            return "sdkoption.nextActionTypeOnNavigation.item2".localized()
        case .CLOSE:
            return "sdkoption.nextActionTypeOnNavigation.item3".localized()
        @unknown default:
            return "sdkoption.nextActionTypeOnNavigation.item1".localized()
        }
    }
}
