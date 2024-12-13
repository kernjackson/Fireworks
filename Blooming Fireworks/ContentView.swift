import SwiftUI

struct ContentView: View {
    @State private var fireworks: [FireworkModel] = [] // Track the fireworks
    
    var body: some View {
        GeometryReader { geometry in // Use GeometryReader to get the size
            ZStack {
                Color.black            
                ForEach(fireworks, id: \.id) { firework in
                    BloomingFirework(model: firework)
                }
            }
            .onTapGesture { location in
                let x = location.x / geometry.size.width // Use geometry.size.width
                let y = location.y / geometry.size.height // Use geometry.size.height
                fireworks.append(FireworkModel(
                    time: 0.0,
                    endPoint: .init(x: x, y: y),
                    burstColor: BloomingFirework.randomColor()))
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
