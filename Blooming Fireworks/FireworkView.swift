import SwiftUI

struct FireworkView: View {
    @State var time: Double = 0
    let endPoint: CGPoint
    let burstColor: Color
    
    // Creates a timer that "publishes" events 120 times per second (1/120 seconds)
    // The timer runs on the main thread/queue (.main)
    // .common means the timer runs in the default run loop mode
    // .autoconnect() starts the timer immediately when this property is accessed
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

}

#Preview {
    ZStack {
        Color.black
        FireworkView(model: FireworkModel(time: 0.0, endPoint: .init(x: 0.2, y: 0.6), burstColor: .random))
        FireworkView(model: FireworkModel(time: 0.9, endPoint: .init(x: 0.7, y: 0.2), burstColor: .random))
        FireworkView(model: FireworkModel(time: 0.4, endPoint: .init(x: 0.4, y: 0.3), burstColor: .random))
    }
    .ignoresSafeArea()
}

