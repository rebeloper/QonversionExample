//
//  ContentView.swift
//  QonversionFirstProject
//
//  Created by Alex Nagy on 01/10/2020.
//

import SwiftUI

struct ContentView: View {
    
    @State var subscriptionIsUnlocked = false
    @State var perDeviceUserUid = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 18) {
                
                Text("\(subscriptionIsUnlocked ? "Unlocked" : "Locked")")
                    .font(.largeTitle)
                    .foregroundColor(.yellow)
                
                Button("Per device user id - \(perDeviceUserUid)") {
                    print("Per device user id...")
                    perDeviceUserUid = QonversionManager.perDeviceUserUid ?? ""
                }
                
                Button("Purchase") {
                    print("Purchasing...")
                    QonversionManager.purchase(QonversionManager.products[0]) { (result) in
                        switch result {
                        case .success(let purchased):
                            if let purchased = purchased {
                                print("Purchased with success: \(purchased)")
                                subscriptionIsUnlocked = true
                            } else {
                                print("Purchase is canceled")
                            }
                        case .failure(let err):
                            print(err.localizedDescription)
                        }
                    }
                }
                
                Button("Restore Permission") {
                    print("Restoring permission...")
                    QonversionManager.restorePurchases(forPermissionId: QonversionManager.permissionIds[0]) { (result) in
                        switch result {
                        case .success(let activeProducts):
                            print("Restored with success: \(activeProducts.count) products")
                            if activeProducts.count >= 1 {
                                subscriptionIsUnlocked = true
                            }
                        case .failure(let err):
                            print(err.localizedDescription)
                        }
                    }
                }
                
                Button("Restore All") {
                    print("Restoring all...")
                    QonversionManager.restoreAllPurchases() { (result) in
                        switch result {
                        case .success(let activeProducts):
                            print("Restored with success: \(activeProducts.count) products")
                            if activeProducts.count >= 1 {
                                subscriptionIsUnlocked = true
                            }
                        case .failure(let err):
                            print(err.localizedDescription)
                        }
                    }
                }
                
                Button("Check purchase") {
                    print("Checking purchase...")
                    QonversionManager.checkPermissions([QonversionManager.permissionIds[0]]) { (result) in
                        switch result {
                        case .success(let activePermissions):
                            activePermissions.forEach { (activePermission) in
                                print("Active permission: \(activePermission.id) - productId: \(activePermission.permission.productID) - expirationDate: \(String(describing: activePermission.permission.expirationDate?.description(with: .current)))")
                                switch activePermission.permission.renewState {
                                case .willRenew, .nonRenewable:
                                    print(".willRenew")
                                    subscriptionIsUnlocked = true
                                    // .willRenew is the state of an auto-renewable subscription
                                    // .nonRenewable is the state of consumable/non-consumable iaps that could unlock lifetime access
                                    break
                                case .billingIssue:
                                    print(".billingIssue")
                                    // Grace period: permission is active, but there was some billing issue.
                                    // Prompt the user to update the payment method.
                                    subscriptionIsUnlocked = false
                                    break
                                case .cancelled:
                                    print(".cancelled")
                                    subscriptionIsUnlocked = false
                                    // The user has turned off auto-renewal for the subscription, but the subscription has not expired yet.
                                    // Prompt the user to resubscribe with a special offer.
                                    break
                                default: break
                                }
                            }
                        case .failure(let err):
                            print(err.localizedDescription)
                        }
                    }
                }
                
                Spacer()
            }.navigationTitle("Qonversion")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
