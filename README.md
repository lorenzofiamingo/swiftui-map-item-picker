# MapItemPicker 🗺️

`MapItemPicker` is a location picker sheet. Currently supports only iOS and Mac Catalyst.

<img src="https://user-images.githubusercontent.com/40797951/155740664-43a7e5ab-d188-483a-b80c-b7afa0bcf7d0.PNG" height="448">

## Usage

`MapItemPicker` has similar same API and behavior as other [Presentation Modifiers](https://developer.apple.com/documentation/swiftui/view-presentation).
```swift
import SwiftUI
import MapItemPicker

struct ContentView: View {
    
    @State private var showingPicker = false
    
    var body: some View {
        Button("Choose location") {
            showingPicker = true
        }
        .mapItemPicker(isPresented: $showingPicker) { item in
            if let name = item?.name {
                print("Selected \(name)")
            }
        }
    }
}
```

## Installation

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/lorenzofiamingo/SwiftUI-MapItemPicker`) and click **Next**.
3. Click **Finish**.


## Other projects

[CachedAsyncImage 🗃️](https://github.com/lorenzofiamingo/SwiftUI-CachedAsyncImage)

[VerticalTabView 🔝](https://github.com/lorenzofiamingo/SwiftUI-VerticalTabView)

[SharedObject 🍱](https://github.com/lorenzofiamingo/SwiftUI-SharedObject)
