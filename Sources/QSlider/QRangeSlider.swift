import SwiftUI

public struct QRangeSlider: View {
    // 绑定值
    @Binding public var lowerValue: Double
    @Binding public var upperValue: Double

    // 基本配置
    public var range: ClosedRange<Double> = 0...100
    public var trackHeight: CGFloat = 8

    // 轨道颜色（左段 / 中间选中段 / 右段）
    public var leftTrackColor: Color = .gray.opacity(0.3)
    public var selectedTrackColor: Color = .blue
    public var rightTrackColor: Color = .gray.opacity(0.3)

    // 左右 thumb 外观
    public var thumbSize: CGFloat = 28
    public var leftThumbColor: Color = .white
    public var rightThumbColor: Color = .white
    public var leftThumbIcon: String? = nil
    public var rightThumbIcon: String? = nil
    public var leftThumbIconColor: Color = .black
    public var rightThumbIconColor: Color = .black

    // 可选：最小/最大差值限制（单位与 range 一致）
    public var minGap: Double? = nil
    public var maxGap: Double? = nil

    public init(
        lowerValue: Binding<Double>,
        upperValue: Binding<Double>,
        range: ClosedRange<Double> = 0...100,
        trackHeight: CGFloat = 8,
        leftTrackColor: Color = .gray.opacity(0.3),
        selectedTrackColor: Color = .blue,
        rightTrackColor: Color = .gray.opacity(0.3),
        thumbSize: CGFloat = 28,
        leftThumbColor: Color = .white,
        rightThumbColor: Color = .white,
        leftThumbIcon: String? = nil,
        rightThumbIcon: String? = nil,
        leftThumbIconColor: Color = .black,
        rightThumbIconColor: Color = .black,
        minGap: Double? = nil,
        maxGap: Double? = nil
    ) {
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.range = range
        self.trackHeight = trackHeight
        self.leftTrackColor = leftTrackColor
        self.selectedTrackColor = selectedTrackColor
        self.rightTrackColor = rightTrackColor
        self.thumbSize = thumbSize
        self.leftThumbColor = leftThumbColor
        self.rightThumbColor = rightThumbColor
        self.leftThumbIcon = leftThumbIcon
        self.rightThumbIcon = rightThumbIcon
        self.leftThumbIconColor = leftThumbIconColor
        self.rightThumbIconColor = rightThumbIconColor
        self.minGap = minGap
        self.maxGap = maxGap
    }

    public var body: some View {
        GeometryReader { geo in
            let totalWidth = max(geo.size.width, 1)
            let usableWidth = max(totalWidth - thumbSize, 1)
            let span = (range.upperBound - range.lowerBound)

            // 当前值 -> x 偏移
            let xLower = CGFloat((lowerValue - range.lowerBound) / span) * usableWidth
            let xUpper = CGFloat((upperValue - range.lowerBound) / span) * usableWidth

            // 防止视觉重叠的最小间距（当未设置 minGap 时）
            let visualMinGapValue = Double(thumbSize / usableWidth) * span

            ZStack(alignment: .leading) {
                // 左段（range.lower...lowerValue）
                Capsule()
                    .fill(leftTrackColor)
                    .frame(width: xLower + thumbSize/2, height: trackHeight)
                    .alignmentGuide(.leading) { _ in 0 }

                // 中段（lowerValue...upperValue）
                Capsule()
                    .fill(selectedTrackColor)
                    .frame(width: max(xUpper - xLower, 0), height: trackHeight)
                    .offset(x: xLower + thumbSize/2)

                // 右段（upperValue...range.upper）
                Capsule()
                    .fill(rightTrackColor)
                    .frame(width: max(usableWidth - xUpper, 0), height: trackHeight)
                    .offset(x: xUpper + thumbSize/2)

                // 左 thumb
                thumbView(color: leftThumbColor, icon: leftThumbIcon, iconColor: leftThumbIconColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: xLower)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { g in
                                let raw = min(max(0, g.location.x), usableWidth)
                                let proposed = range.lowerBound + Double(raw / usableWidth) * span
                                lowerValue = clampLower(
                                    proposed,
                                    currentUpper: upperValue,
                                    span: span,
                                    visualMinGapValue: visualMinGapValue
                                )
                            }
                    )

                // 右 thumb
                thumbView(color: rightThumbColor, icon: rightThumbIcon, iconColor: rightThumbIconColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: xUpper)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { g in
                                let raw = min(max(0, g.location.x), usableWidth)
                                let proposed = range.lowerBound + Double(raw / usableWidth) * span
                                upperValue = clampUpper(
                                    proposed,
                                    currentLower: lowerValue,
                                    span: span,
                                    visualMinGapValue: visualMinGapValue
                                )
                            }
                    )
            }
            .frame(height: max(trackHeight, thumbSize))
        }
        .frame(height: max(trackHeight, thumbSize))
        .onChange(of: lowerValue) { new in
            // 保证初始值也满足约束
            lowerValue = clampLower(new, currentUpper: upperValue, span: range.upperBound - range.lowerBound, visualMinGapValue: 0)
        }
        .onChange(of: upperValue) { new in
            upperValue = clampUpper(new, currentLower: lowerValue, span: range.upperBound - range.lowerBound, visualMinGapValue: 0)
        }
    }

    // MARK: - 视图与工具

    private func thumbView(color: Color, icon: String?, iconColor: Color) -> some View {
        ZStack {
            Circle()
                .fill(color)
                .shadow(radius: 2)
            if let name = icon {
                Image(systemName: name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: thumbSize * 0.5, height: thumbSize * 0.5)
                    .foregroundStyle(iconColor)
            }
        }
        .contentShape(Rectangle()) // 增大可点区域
    }

    private func clampLower(_ proposed: Double, currentUpper: Double, span: Double, visualMinGapValue: Double) -> Double {
        var v = proposed
        // 基础边界
        v = max(range.lowerBound, min(v, currentUpper))

        // 应用 minGap（优先使用显式 minGap，否则用视觉最小间距防止重叠）
        let minGapValue = (minGap ?? 0) > 0 ? (minGap ?? 0) : max(visualMinGapValue, 0)
        v = min(v, currentUpper - minGapValue)

        // 应用 maxGap（上限差值）
        if let maxGap, maxGap > 0 {
            v = max(v, currentUpper - maxGap)
        }
        // 再次夹取到总范围
        return min(max(v, range.lowerBound), currentUpper)
    }

    private func clampUpper(_ proposed: Double, currentLower: Double, span: Double, visualMinGapValue: Double) -> Double {
        var v = proposed
        // 基础边界
        v = min(range.upperBound, max(v, currentLower))

        // 应用 minGap（优先使用显式 minGap，否则用视觉最小间距防止重叠）
        let minGapValue = (minGap ?? 0) > 0 ? (minGap ?? 0) : max(visualMinGapValue, 0)
        v = max(v, currentLower + minGapValue)

        // 应用 maxGap（上限差值）
        if let maxGap, maxGap > 0 {
            v = min(v, currentLower + maxGap)
        }
        // 再次夹取到总范围
        return max(min(v, range.upperBound), currentLower)
    }

    public func setValue(lower: Double, upper: Double) {
        // 设置值时，确保在范围内
        lowerValue = clampLower(lower, currentUpper: upperValue, span: range.upperBound - range.lowerBound, visualMinGapValue: 0)
        upperValue = clampUpper(upper, currentLower: lowerValue, span: range.upperBound - range.lowerBound, visualMinGapValue: 0)
    }

    public func getValue() -> (lower: Double, upper: Double) {
        return (lowerValue, upperValue)
    }
}
