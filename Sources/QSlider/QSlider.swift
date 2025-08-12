import SwiftUI

public struct QSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var trackHeight: CGFloat
    var minTrackColor: Color
    var maxTrackColor: Color
    var thumbSize: CGFloat
    var thumbColor: Color
    var thumbIcon: String?
    var thumbIconColor: Color
    
    public init(
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...100,
        trackHeight: CGFloat = 8,
        minTrackColor: Color = .blue,
        maxTrackColor: Color = .gray,
        thumbSize: CGFloat = 24,
        thumbColor: Color = .white,
        thumbIcon: String? = nil,
        thumbIconColor: Color = .black
    ) {
        self._value = value
        self.range = range
        self.trackHeight = trackHeight
        self.minTrackColor = minTrackColor
        self.maxTrackColor = maxTrackColor
        self.thumbSize = thumbSize
        self.thumbColor = thumbColor
        self.thumbIcon = thumbIcon
        self.thumbIconColor = thumbIconColor
    }
    
    public var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(maxTrackColor)
                    .frame(height: trackHeight)
                
                Capsule()
                    .fill(minTrackColor)
                    .frame(width: progress * totalWidth, height: trackHeight)
                
                ZStack {
                    Circle()
                        .fill(thumbColor)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(radius: 2)
                    
                    if let iconName = thumbIcon {
                        Image(systemName: iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: thumbSize * 0.5, height: thumbSize * 0.5)
                            .foregroundColor(thumbIconColor)
                    }
                }
                .offset(x: progress * (totalWidth - thumbSize))
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let percent = min(max(0, gesture.location.x / (totalWidth - thumbSize)), 1)
                            value = range.lowerBound + Double(percent) * (range.upperBound - range.lowerBound)
                        }
                )
            }
        }
        .frame(height: max(trackHeight, thumbSize))
    }
}
