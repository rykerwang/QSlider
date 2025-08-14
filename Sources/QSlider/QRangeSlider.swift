import SwiftUI

public struct QRangeSlider: View {
    // Bound values
    @Binding public var lowerValue: Double
    @Binding public var upperValue: Double

    // Basic configuration
    public var range: ClosedRange<Double> = 0...100
    public var trackHeight: CGFloat = 8

    // Track colors (left segment / selected segment / right segment)
    public var leftTrackColor: Color = .gray.opacity(0.3)
    public var selectedTrackColor: Color = .blue
    public var rightTrackColor: Color = .gray.opacity(0.3)

    // Thumb appearance (left/right)
    public var thumbSize: CGFloat = 28
    public var leftThumbColor: Color = .white
    public var rightThumbColor: Color = .white
    public var leftThumbIcon: String? = nil
    public var rightThumbIcon: String? = nil
    public var leftThumbIconColor: Color = .black
    public var rightThumbIconColor: Color = .black

    // Optional: min/max gap limit (unit same as range)
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

            // Current value -> x offset
            let xLower = CGFloat((lowerValue - range.lowerBound) / span) * usableWidth
            let xUpper = CGFloat((upperValue - range.lowerBound) / span) * usableWidth

            // Minimum visual gap to prevent overlap (when minGap is not set)
            let visualMinGapValue = Double(thumbSize / usableWidth) * span

            ZStack(alignment: .leading) {
                // Left segment (range.lower...lowerValue)
                Capsule()
                    .fill(leftTrackColor)
                    .frame(width: xLower + thumbSize/2, height: trackHeight)
                    .alignmentGuide(.leading) { _ in 0 }

                // Middle segment (lowerValue...upperValue)
                Capsule()
                    .fill(selectedTrackColor)
                    .frame(width: max(xUpper - xLower, 0), height: trackHeight)
                    .offset(x: xLower + thumbSize/2)

                // Right segment (upperValue...range.upper)
                Capsule()
                    .fill(rightTrackColor)
                    .frame(width: max(usableWidth - xUpper, 0), height: trackHeight)
                    .offset(x: xUpper + thumbSize/2)

                // Left thumb
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

                // Right thumb
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
            lowerValue = clampLower(new, currentUpper: upperValue, span: range.upperBound - range.lowerBound, visualMinGapValue: 0)
        }
        .onChange(of: upperValue) { new in
            upperValue = clampUpper(new, currentLower: lowerValue, span: range.upperBound - range.lowerBound, visualMinGapValue: 0)
        }
    }


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
        .contentShape(Rectangle()) // Increase tappable area
    }

    private func clampLower(_ proposed: Double, currentUpper: Double, span: Double, visualMinGapValue: Double) -> Double {
        var v = proposed
        // Basic bounds
        v = max(range.lowerBound, min(v, currentUpper))

        // Apply minGap (prefer explicit minGap, otherwise use visual min gap to prevent overlap)
        let minGapValue = (minGap ?? 0) > 0 ? (minGap ?? 0) : max(visualMinGapValue, 0)
        v = min(v, currentUpper - minGapValue)

        // Apply maxGap (upper limit of gap)
        if let maxGap, maxGap > 0 {
            v = max(v, currentUpper - maxGap)
        }
        // Clamp again to total range
        return min(max(v, range.lowerBound), currentUpper)
    }

    private func clampUpper(_ proposed: Double, currentLower: Double, span: Double, visualMinGapValue: Double) -> Double {
        var v = proposed
        // Basic bounds
        v = min(range.upperBound, max(v, currentLower))

        // Apply minGap (prefer explicit minGap, otherwise use visual min gap to prevent overlap)
        let minGapValue = (minGap ?? 0) > 0 ? (minGap ?? 0) : max(visualMinGapValue, 0)
        v = max(v, currentLower + minGapValue)

        // Apply maxGap (upper limit of gap)
        if let maxGap, maxGap > 0 {
            v = min(v, currentLower + maxGap)
        }
        // Clamp again to total range
        return max(min(v, range.upperBound), currentLower)
    }

    public func setValue(lower: Double, upper: Double) {
        // When setting values, ensure they are within range
        lowerValue = clampLower(lower, currentUpper: upperValue, span: range.upperBound - range.lowerBound, visualMinGapValue: 0)
        upperValue = clampUpper(upper, currentLower: lowerValue, span: range.upperBound - range.lowerBound, visualMinGapValue: 0)
    }

    public func getValue() -> (lower: Double, upper: Double) {
        return (lowerValue, upperValue)
    }
}
