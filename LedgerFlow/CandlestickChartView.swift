import SwiftUI

struct CandlestickChartView: View {
    let data: [CandlestickPoint]
    @State private var selectedPoint: CandlestickPoint?
    @State private var showCallout = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                    .fill(ThemeColors.white)
                    .shadow(color: ThemeColors.black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                if data.isEmpty {
                    Text("No data available")
                        .font(ThemeFonts.body)
                        .foregroundColor(ThemeColors.gray)
                } else {
                    chartContent(in: geometry)
                }
                
                if showCallout, let point = selectedPoint {
                    calloutView(for: point, in: geometry)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleTap(at: value.location, in: CGRect(origin: .zero, size: geometry.size))
                    }
            )
        }
    }
    
    private func chartContent(in geometry: GeometryProxy) -> some View {
        let inset: CGFloat = 16
        let plotRect = CGRect(x: inset, y: inset, width: geometry.size.width - inset * 2, height: geometry.size.height - inset * 2)
        var globalHigh = data.map { $0.high }.max() ?? 1
        var globalLow = data.map { $0.low }.min() ?? 0
        if abs(globalHigh - globalLow) < 1e-6 {
            let v = globalHigh
            globalHigh = v + 1
            globalLow = v - 1
        }
        let range = globalHigh - globalLow
        func yFor(_ value: Double) -> CGFloat {
            let ratio = (globalHigh - value) / range
            return plotRect.minY + CGFloat(ratio) * plotRect.height
        }
        return Canvas { context, size in
            let gridCount = 4
            for i in 0...gridCount {
                let t = CGFloat(i) / CGFloat(gridCount)
                let y = plotRect.minY + plotRect.height * t
                let path = Path(CGRect(x: plotRect.minX, y: y, width: plotRect.width, height: 0.5))
                context.stroke(path, with: .color(ThemeColors.lightGray), lineWidth: 0.5)
            }
            let slotWidth = plotRect.width / CGFloat(max(data.count, 1))
            let candleWidth = min(24, slotWidth * 0.6)
            for (index, point) in data.enumerated() {
                let x = plotRect.minX + CGFloat(index) * slotWidth + candleWidth / 2
                let highY = yFor(point.high)
                let lowY = yFor(point.low)
                var openY = yFor(point.open)
                var closeY = yFor(point.close)
                if abs(highY - lowY) < 1 {
                    openY = plotRect.minY + 2
                    closeY = plotRect.maxY - 2
                }
                let wick = Path { p in
                    p.move(to: CGPoint(x: x, y: highY))
                    p.addLine(to: CGPoint(x: x, y: lowY))
                }
                context.stroke(wick, with: .color(ThemeColors.gray), lineWidth: 1)
                let bodyHeight = max(abs(closeY - openY), 2)
                let bodyRect = CGRect(x: x - candleWidth / 2, y: min(openY, closeY), width: candleWidth, height: bodyHeight)
                let bodyColor = point.isPositive ? ThemeColors.success : ThemeColors.danger
                context.fill(Path(roundedRect: bodyRect, cornerRadius: 2), with: .color(bodyColor))
            }
        }
    }
    
    private func calloutView(for point: CandlestickPoint, in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
            Text(DateFormatter.shortDate.string(from: point.date))
                .font(ThemeFonts.caption1)
                .foregroundColor(ThemeColors.primary)
                .fontWeight(.semibold)
            
            HStack {
                Text("Volume:")
                Spacer()
                Text("\(point.volume)")
            }
            .font(ThemeFonts.caption2)
            .foregroundColor(ThemeColors.gray)
            
            HStack {
                Text("High:")
                Spacer()
                Text(point.high.currencyFormatted)
            }
            .font(ThemeFonts.caption2)
            .foregroundColor(ThemeColors.gray)
            
            HStack {
                Text("Low:")
                Spacer()
                Text(point.low.currencyFormatted)
            }
            .font(ThemeFonts.caption2)
            .foregroundColor(ThemeColors.gray)
        }
        .padding(ThemeSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.small)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .position(x: geometry.size.width / 2, y: 40)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showCallout = false
            }
        }
    }
    
    private func handleTap(at location: CGPoint, in rect: CGRect) {
        let inset: CGFloat = 16
        let plotWidth = rect.width - inset * 2
        guard location.x >= inset && location.x <= rect.width - inset else { return }
        let spacing = plotWidth / CGFloat(max(data.count, 1))
        let index = Int((location.x - inset) / spacing)
        
        guard index >= 0 && index < data.count else { return }
        
        selectedPoint = data[index]
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showCallout = true
        }
        
        HapticsService.shared.light()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showCallout = false
            }
        }
    }
}
