//
//  PurchaseManager.swift
//  Basic-Car-Maintenance
//
//  Created by Mikaela Caron on 6/4/24.
//

import Foundation
import StoreKit
import SwiftUI

enum LoadState {
    case loading, loaded(Product), failed
}

/// Handles all in app purchases.
@Observable
class PurchaseManager {
    
    var loadState = LoadState.loading
    
    private var storeTask: Task<Void, Never>?
    
    init() {
        storeTask = Task {
            await monitorTransactions()
        }
    }
    
    func monitorTransactions() async {
        // Check for previous purchases.
        for await entitlement in Transaction.currentEntitlements {
            if case let .verified(transaction) = entitlement {
                await finalize(transaction)
            }
        }
        
        // Watch for future transactions coming in.
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                await finalize(transaction)
            }
        }
    }
    
    @MainActor
    func finalize(_ transaction: StoreKit.Transaction) async {
        
        // finish the transactions if they're one of the specified IAPs
        switch transaction.productID {
        case IAPProduct.smallTip, IAPProduct.mediumTip, IAPProduct.largeTip, IAPProduct.xLargeTip:
            await transaction.finish()
            AnalyticsService.shared.logEvent(.successfulPurchase)
        default: break
        }
    }
    
    func load() async {
        loadState = .loading
        
        do {
            try await Task.sleep(for: .seconds(0.5))
            
            let products = try await Product.products(
                for: [
                    IAPProduct.smallTip,
                    IAPProduct.mediumTip,
                    IAPProduct.largeTip,
                    IAPProduct.xLargeTip
                ]
            )
            
            if let product = products.first {
                loadState = LoadState.loaded(product)
            } else {
                loadState = .failed
            }
        } catch {
            print("❌ Error loading products: \(error.localizedDescription)")
            loadState = .failed
        }
    }
}
