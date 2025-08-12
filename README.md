# QSlider

A fully customizable SwiftUI slider with adjustable track height, colors, and thumb icon.

## Features
- Adjustable track height
- Separate colors for min/max track
- Custom thumb color, size, and icon
- Pure SwiftUI implementation
                        
## Installation
Add the package to your Xcode project:
                            
1. In Xcode: `File` → `Add Packages...`
2. Enter repository URL: https://github.com/rykerwang/QSlider.git



## Usage
```swift
import SwiftUI
import QSlider

struct ContentView: View {
    @State private var value = 50.0
    var body: some View {
        QSlider(
            value: $value,
            range: 0...100,
            trackHeight: 10,
            minTrackColor: .green,
            maxTrackColor: .gray.opacity(0.3),
            thumbSize: 30,
            thumbColor: .white,
            thumbIcon: "star.fill",
            thumbIconColor: .yellow
        )
        .frame(height: 50)
        .padding()
    }
}
```
                            


