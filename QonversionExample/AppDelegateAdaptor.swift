//
//  AppDelegateAdaptor.swift
//  QonversionFirstProject
//
//  Created by Alex Nagy on 01/10/2020.
//

import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        QonversionManager.configure { (result) in
            switch result {
            case .success(let activePermissions):
                activePermissions.forEach { (activePermission) in
                    print("Active permission: \(activePermission.id) - productId: \(activePermission.permission.productID) - expirationDate: \(String(describing: activePermission.permission.expirationDate?.description(with: .current)))")
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
        return true
    }
}

