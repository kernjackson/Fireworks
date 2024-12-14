import SwiftUI

extension Color {
    static var random: Color {
        let colors: [Color] = [
            .red,
            .blue, 
            .green,
            .yellow,
            .purple,
            .cyan,
            .orange,
            .pink
        ]
        return colors.randomElement() ?? .white
    }
}
