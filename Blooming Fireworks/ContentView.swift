import SwiftUI

struct ContentView: View {
    @State private var fireworks: [FireworkModel] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                ForEach(fireworks, id: \.id) { firework in
                    FireworkView(model: firework)
                }
            }
            .onTapGesture { location in
                let x = location.x / geometry.size.width
                let y = location.y / geometry.size.height
                
                let newFirework = FireworkModel(
                    id: UUID(),
                    time: 0.0,
                    endPoint: .init(x: x, y: y),
                    burstColor: .random)
                
                fireworks.append(newFirework)
                if fireworks.count > 10 {
                    fireworks.removeFirst()
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
