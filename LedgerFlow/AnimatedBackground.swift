import SwiftUI

struct AnimatedBackground: View {
    @State private var animationPhase: CGFloat = 0
    @State private var particles: [BackgroundParticle] = []
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                
                let gradient = Gradient(colors: [
                    ThemeColors.background,
                    ThemeColors.accent.opacity(0.1),
                    ThemeColors.primary.opacity(0.05)
                ])
                
                let radialGradient = RadialGradient(
                    gradient: gradient,
                    center: UnitPoint(
                        x: 0.5 + sin(now * 0.3) * 0.1,
                        y: 0.5 + cos(now * 0.2) * 0.1
                    ),
                    startRadius: size.width * 0.2,
                    endRadius: size.width * 1.2
                )
                
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .radialGradient(
                        Gradient(colors: [
                            ThemeColors.background,
                            ThemeColors.accent.opacity(0.1),
                            ThemeColors.primary.opacity(0.05)
                        ]),
                        center: CGPoint(
                            x: size.width * (0.5 + sin(now * 0.3) * 0.1),
                            y: size.height * (0.5 + cos(now * 0.2) * 0.1)
                        ),
                        startRadius: size.width * 0.2,
                        endRadius: size.width * 1.2
                    )
                )
                
                for particle in particles {
                    let x = particle.x + sin(now * particle.speed) * particle.amplitude
                    let y = particle.y + cos(now * particle.speed * 0.7) * particle.amplitude * 0.5
                    let opacity = 0.1 + sin(now * particle.speed * 2) * 0.05
                    
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: x - particle.size / 2,
                            y: y - particle.size / 2,
                            width: particle.size,
                            height: particle.size
                        )),
                        with: .color(ThemeColors.accent.opacity(opacity))
                    )
                }
            }
        }
        .onAppear {
            generateParticles()
        }
        .ignoresSafeArea()
    }
    
    private func generateParticles() {
        particles = (0..<20).map { _ in
            BackgroundParticle(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height),
                size: CGFloat.random(in: 2...8),
                speed: CGFloat.random(in: 0.5...1.5),
                amplitude: CGFloat.random(in: 10...30)
            )
        }
    }
}

struct BackgroundParticle {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let speed: CGFloat
    let amplitude: CGFloat
}
