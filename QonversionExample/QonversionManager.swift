//
//  QonversionManager.swift
//  QonversionFirstProject
//
//  Created by Alex Nagy on 01/10/2020.
//

import Qonversion

struct QonversionManager {
    
    // https://github.com/qonversion/qonversion-ios-sdk
    
    static let projectKey = "ptbRgpxoZ-Woz0E23MqGfk0X7zPOwGak"
    static let permissionIds = ["premium"]
    static let products = [
        QonversionProduct(id: "silver", permissionId: permissionIds[0])
    ]
    
    static var perDeviceUserUid: String?
    
    static func launch(withKey key: String = projectKey, completion: @escaping (Result<Qonversion.LaunchResult, Error>) -> () = {_ in}) {
        // https://dash.qonversion.io/project/settings
        Qonversion.launch(withKey: key) { (result, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            perDeviceUserUid = result.uid
            completion(.success(result))
        }
    }
    
    static func checkPermissions(_ permissionIds: [String] = permissionIds, completion: @escaping (Result<[QonversionActivePermission], Error>) -> ()) {
        
        Qonversion.checkPermissions { (permissions, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            
            var activePermissions = [QonversionActivePermission]()
            for i in 0..<permissionIds.count {
                let permissionId = permissionIds[i]
                if let permission = permissions[permissionId], permission.isActive {
                    let activePermission = QonversionActivePermission(id: permissionId, permission: permission)
                    activePermissions.append(activePermission)
                }
            }
            print("Active permissions count: \(activePermissions.count)")
            completion(.success(activePermissions))
        }
    }
    
    static func configure(withKey key: String = projectKey, permissionIds: [String] = permissionIds, completion: @escaping (Result<[QonversionActivePermission], Error>) -> ()) {
        QonversionManager.launch(withKey: key) { (result) in
            switch result {
            case .success(let launchResult):
                print("Launch result permissions count: \(launchResult.permissions.count)")
                QonversionManager.checkPermissions(permissionIds) { (result) in
                    switch result {
                    case .success(let activePermissions):
                        completion(.success(activePermissions))
                    case .failure(let err):
                        completion(.failure(err))
                    }
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    static func setSideUserUid(_ uid: String = UUID().uuidString) {
        Qonversion.setUserID(uid)
    }
    
    static func resetPerDeviceUserUid() {
        Qonversion.resetUser()
    }
    
    static func setUserProperty(_ property: Qonversion.Property, value: String) {
        Qonversion.setProperty(property, value: value)
    }
    
    static func setCustomUserProperty(_ property: String, value: String) {
        Qonversion.setUserProperty(property, value: value)
    }
    
    static func purchase(_ product: QonversionProduct, completion: @escaping (Result<Bool?, Error>) -> ()) {
        Qonversion.purchase(product.id) { (permissions, err, isCanceled) in
            if let err = err {
                completion(.failure(err))
                return
            }
            if let permission = permissions[product.permissionId], permission.isActive {
                completion(.success(true))
            } else {
                if isCanceled {
                    completion(.success(nil))
                } else {
                    completion(.success(false))
                }
            }
        }
    }
    
    static func restorePurchases(forPermissionId permissionId: String, completion: @escaping (Result<[QonversionProduct], Error>) -> ()) {
        Qonversion.restore { (permissions, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            
            var activeProducts = [QonversionProduct]()
            products.forEach { (product) in
                if product.permissionId == permissionId, let permission = permissions[product.permissionId], permission.isActive {
                    activeProducts.append(product)
                }
            }
            
            print("\(activeProducts.count == 0 ? "Nothing to restore" : "Restored products count: \(activeProducts.count)")")
            completion(.success(activeProducts))
        }
    }
    
    static func restoreAllPurchases(completion: @escaping (Result<[QonversionProduct], Error>) -> ()) {
        Qonversion.restore { (permissions, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            
            var activeProducts = [QonversionProduct]()
            products.forEach { (product) in
                if let permission = permissions[product.permissionId], permission.isActive {
                    activeProducts.append(product)
                }
            }
            
            print("\(activeProducts.count == 0 ? "Nothing to restore" : "Restored products count: \(activeProducts.count)")")
            completion(.success(activeProducts))
            
        }
    }
}

struct QonversionActivePermission {
    let id: String
    let permission: Qonversion.Permission
}

struct QonversionProduct {
    let id: String
    let permissionId: String
}
