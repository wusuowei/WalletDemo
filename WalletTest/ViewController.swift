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

    var passToAdd: PKPass?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showWalletPass(_ sender: Any) {
        guard PKPassLibrary.isPassLibraryAvailable() else {
            showAlert(message: "您的设备不支持Wallet")
            return
        }
        guard let fileUrl = Bundle.main.url(forResource: "Lollipop", withExtension: "pkpass") else {
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
        let actionConfirm = UIAlertAction.init(title: "立即查看", style: UIAlertActionStyle.default) { [weak self] _ in
            guard let passURL = self?.passToAdd?.passURL else {
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
            self?.showLookAlert(message: "添加完成")
        }
    }
}

