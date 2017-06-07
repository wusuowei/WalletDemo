//
//  ViewController.swift
//  WalletTest
//
//  Created by 温天恩 on 2017/6/7.
//  Copyright © 2017年 温天恩. All rights reserved.
//

import UIKit
import PassKit

class ViewController: UIViewController {

    var passToAdd = PKPass()
    var passIsAdded = false
    let passLibrary = PKPassLibrary()

    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK:必须监听初始化的PKPassLibrary，不然收不到通知
        NotificationCenter.default.addObserver(self, selector: #selector(passChanged(_ :)), name: NSNotification.Name(rawValue: PKPassLibraryNotificationName.PKPassLibraryDidChange.rawValue), object: passLibrary)
    }

    func passChanged(_ notification: Notification) {
        guard let serialNumberUserInfoKey = notification.userInfo?[PKPassLibraryNotificationKey.serialNumberUserInfoKey] as? String else {
            return
        }
        passIsAdded = serialNumberUserInfoKey == passToAdd.serialNumber
    }

    @IBAction func showBoardingPass(_ sender: UIButton) {
        showWalletPass(fileName: "BoardingPass")
    }
    @IBAction func showCouponPass(_ sender: UIButton) {
        showWalletPass(fileName: "Coupon")
    }
    @IBAction func showFilmTicketPass(_ sender: UIButton) {
        showWalletPass(fileName: "Event")
    }
    @IBAction func showGenericPass(_ sender: Any) {
        showWalletPass(fileName: "Generic")
    }
    @IBAction func showStoreCardPass(_ sender: Any) {
        showWalletPass(fileName: "StoreCard")
    }

    func showWalletPass(fileName: String) {
        guard PKPassLibrary.isPassLibraryAvailable() else {
            showAlert(message: "您的设备不支持Wallet")
            return
        }
        guard let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "pkpass") else {
            showAlert(message: "未找到票据凭证")
            return
        }
        guard let passData = try? Data.init(contentsOf: fileUrl) else {
            showAlert(message: "未找到票据凭证")
            return
        }
        var error: NSError?
        let pass = PKPass(data: passData, error: &error)
        if error != nil {
            showAlert(message: "\(String(describing: error?.localizedDescription))")
            return
        }
        if PKAddPassesViewController.canAddPasses() {
            showPass(pass: pass)
        } else {
            showAlert(message: "您的设备不支持Wallet")
        }
    }

    func showPass(pass: PKPass) {
        if passLibrary.containsPass(pass) {
            showAlert(message: "凭证已添加")
            return
        }
        passToAdd = pass
        let addPassVc = PKAddPassesViewController(pass: pass)
        addPassVc.delegate = self
        self.present(addPassVc, animated: true) {
        }
    }

    func showAlert(message: String) {
        let alertVc = UIAlertController.init(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let actionConfirm = UIAlertAction.init(title: "确定", style: UIAlertActionStyle.default) { _ in
        }
        alertVc.addAction(actionConfirm)
        self.present(alertVc, animated: true) {
        }
    }

    func showLookAlert(message: String) {
        guard passLibrary.containsPass(passToAdd) else {
            return
        }
        let actionConfirm = UIAlertAction.init(title: "立即查看", style: UIAlertActionStyle.default) { [weak self] _ in
            guard let passURL = self?.passToAdd.passURL else {
                return
            }
            if UIApplication.shared.canOpenURL(passURL) {
                UIApplication.shared.open(passURL, options: [:], completionHandler: { _ in
                })
            }
        }

        let actionCancel = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.default) { _ in
        }

        let alertVc = UIAlertController.init(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertVc.addAction(actionConfirm)
        alertVc.addAction(actionCancel)
        self.present(alertVc, animated: true) {
        }
    }
}

extension ViewController: PKAddPassesViewControllerDelegate {
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {

        controller.dismiss(animated: true) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.showLookAlert(message: "添加完成")
        }
    }
}

