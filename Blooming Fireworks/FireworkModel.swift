import SwiftUI

struct FireworkModel: Identifiable {
    let id: UUID
    let time: Double
    let endPoint: CGPoint
    let burstColor: Color

    init(id: UUID = UUID(), time: Double, endPoint: CGPoint, burstColor: Color) {
        self.id = id
        self.time = time
        self.endPoint = endPoint
        self.burstColor = burstColor
    }
}
