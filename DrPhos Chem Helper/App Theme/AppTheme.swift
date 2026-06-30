import SwiftUI

struct AppTheme {
    static let enterButtonColor = Color("phosblue1")
    static let clearButtonColor = Color("phosred1")
    static let backgroundColor = Color(.systemGroupedBackground)
    static let textColor = Color.primary
    static let cornerRadius: CGFloat = 14
    static let screenPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 16
    static let readableContentWidth: CGFloat = 680

    static func standardFont(size: CGFloat = 18, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
}
