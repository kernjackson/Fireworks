import SwiftUI

struct FireworkModel {
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

struct BloomingFirework: View {
    @State var time: Double = 0
    let endPoint: CGPoint
    let burstColor: Color
    
    let timer = Timer.publish(
        every: 1/120,
        on: .main,
        in: .common
    ).autoconnect()
    
    init(model: FireworkModel) {
        self.time = model.time
        self.endPoint = model.endPoint
        self.burstColor = model.burstColor
    }
    
    var body: some View {
        let time = time
        
        Color.black
            .visualEffect { view, proxy in
                view.colorEffect(
                    ShaderLibrary.bundle(.main)
                        .trailEffect(
                            .float(time),
                            .float2(proxy.size),
                            .float2(endPoint),
                            .color(burstColor)
                        )
                )
            }
            .onReceive(timer) { _ in
                if self.time < 4.0 { // Only animate up to n seconds
                    self.time += 0.016667
                }
            }
    }

    static func randomColor() -> Color {
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

#Preview {
    ZStack {
        Color.black
        BloomingFirework(model: FireworkModel(time: 0.0, endPoint: .init(x: 0.2, y: 0.6), burstColor: BloomingFirework.randomColor()))
        BloomingFirework(model: FireworkModel(time: 0.9, endPoint: .init(x: 0.7, y: 0.2), burstColor: BloomingFirework.randomColor()))
        BloomingFirework(model: FireworkModel(time: 0.4, endPoint: .init(x: 0.4, y: 0.3), burstColor: BloomingFirework.randomColor()))
    }
    .ignoresSafeArea()
}

