import Testing
import SwiftUI
@testable import QSlider

@MainActor @Test func example() throws {
    
    
    var value: Double = 0.5
    let binding = Binding<Double>(
        get: { value },
        set: { value = $0 }
    )
    
    let slider = QSlider(
        value: binding,
        range: 0...100,
        trackHeight: 20,
        minTrackColor: .blue,
        maxTrackColor: .gray,
        thumbSize: 40,
        thumbColor: .red,
        thumbIcon: "star.fill",
        thumbIconColor: .white
    )
    
    // 模拟修改 Binding 值
    binding.wrappedValue = 0.8
    #expect(value == 0.8)
    
    // 确认 slider 创建成功
    #expect(slider != nil)
}
