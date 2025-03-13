//
// © 2025 Nao Watanabe
//

import SwiftUI

struct IntTextField: View {
    @Binding var intValue: Int
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.zeroSymbol = ""
        return formatter
    }()

    var body: some View {
        TextField("購入金額", value: $intValue, formatter: formatter)
            .keyboardType(.numberPad)
    }
}
