//
//  PaywallView.swift
//  Basic-Car-Maintenance
//
//  Created by Mikaela Caron on 1/14/24.
//

import StoreKit
import SwiftUI

struct PaywallView: View {
    
    @State private var purchaseManager = PurchaseManager()
    
    var body: some View {
        StoreView(products: purchaseManager.products)
    }
}

#Preview {
    PaywallView()
}
