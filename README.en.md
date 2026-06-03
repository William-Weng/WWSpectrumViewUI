# WWSpectrumViewUI

![SwiftUI](https://img.shields.io/badge/SwiftUI-524520?logo=swift)
[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWSpectrumViewUI)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

`WWSpectrumViewUI` is a lightweight audio spectrum analysis and visualization toolkit built with Swift, SwiftUI, and Accelerate. It extracts raw frequency-band data from an `AVAudioNode`, then renders it as a configurable live spectrum view.

[English](./README.en.md) | [繁體中文](./README.md)

https://github.com/user-attachments/assets/60f35681-554e-49d7-a943-5b7aa4dc28f8

---

## ✨ Features

- Real-time FFT-based spectrum analysis.
- Raw frequency-band output with `SpectrumBandRaw`.
- SwiftUI spectrum visualization view.
- Multiple bar styles: `rounded`, `sharp`, `glow`, and `gradient`.
- Multiple color schemes: `rainbow`, `fire`, `ocean`, `neon`, `sunset`, `matrix`, and custom colors.
- Configurable `fftSize`, `barCount`, `minFrequency`, `maxFrequency`, and animation duration.
- Separation of analysis layer and UI layer for easier customization.

---

## 📦 Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/William-Weng/WWSpectrumViewUI.git", .upToNextMajor(from: "1.0.0"))
]
```

Or in Xcode, go to **File > Add Package Dependencies...** and paste the repository URL.

---

## 🚀 Quick Start

### 1. Create a view model

```swift
let viewModel = WWSpectrumViewUI.ViewModel()
```

### 2. Start raw spectrum analysis

```swift
spectrumAnalyzer.installRawTap(on: audioNode, sampleRate: sampleRate) { bands in
    DispatchQueue.main.async { viewModel.rawBands = bands }
}
```

### 3. Show the spectrum view

```swift
WWSpectrumViewUI(viewModel: viewModel, colorScheme: .rainbow, barStyle: .glow, duration: 0.25).frame(height: 220)
```

## 💡 Usage Example

```swift
import AVFAudio
import SwiftUI
import WWNormalizeAudioPlayer
import WWSpectrumViewUI

final class ViewController: UIViewController {
    
    private let audioPlayer = WWNormalizeAudioPlayer()
    private let spectrumAnalyzer = WWNormalizeAudioPlayer.SpectrumAnalyzer()
    private let viewModel = WWSpectrumViewUI.ViewModel()
    private let filenames = ["audio.m4a"]
    
    private var spectrumHostingController: UIHostingController<WWSpectrumViewUI>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpectrumView()
        setupAudio()
    }
}

extension ViewController {
    
    func setupSpectrumView() {
        
        let spectrumView = WWSpectrumViewUI(viewModel: viewModel, colorScheme: .neon, barStyle: .glow, duration: 0.5)
        let hostingController = UIHostingController(rootView: spectrumView)
        
        hostingController.view.backgroundColor = .clear
        spectrumHostingController = hostingController

        addChild(hostingController)
        self.view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            hostingController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])

        hostingController.didMove(toParent: self)
    }
    
    func setupAudio() {
        
        Task {
            do {
                try audioPlayer.configure(delegate: self)
                
                let sampleRate = audioPlayer.audioNode.outputFormat(forBus: 0).sampleRate
                
                spectrumAnalyzer.installRawTap(on: audioPlayer.audioNode, sampleRate: sampleRate) { [self] rawBands in
                    
                    let rawBands = rawBands.map { raw in
                        WWSpectrumViewUI.BandRaw(index: raw.index, lowerFrequency: raw.lowerFrequency, upperFrequency: raw.upperFrequency, values: raw.values)
                    }

                    Task { @MainActor in self.viewModel.rawBands = rawBands }
                }
                
                await audioPlayer.play(filenames: filenames, loop: true)
            } catch {
                print(error)
            }
        }
    }
}

extension ViewController: WWNormalizeAudioPlayer.Delegate {
    
    func audioPlayer(_ player: WWNormalizeAudioPlayer, trackIndex: Int, currentTime: TimeInterval, trackTime: TimeInterval) {}
    
    func audioPlayer(_ player: WWNormalizeAudioPlayer, didFinishTrackIndex trackIndex: Int, callbackType: AVAudioPlayerNodeCompletionCallbackType) {}
    
    func audioPlayer(_ player: WWNormalizeAudioPlayer, error: any Error) {}
}
```

---

## 🧩 Data Models

### SpectrumBandRaw

`SpectrumBandRaw` stores the raw FFT-bin values for a frequency band. It is intended for analysis, conversion, and custom visualization logic.

```swift
struct SpectrumBandRaw {
    public let index: Int
    public let lowerFrequency: Float
    public let upperFrequency: Float
    public let values: [Float]
}
```

### SpectrumBar

`SpectrumBar` stores a normalized amplitude value that is convenient for visualization or JSON output.

```swift
struct SpectrumBar: Codable {
    public let index: Int
    public let lowerFrequency: Float
    public let upperFrequency: Float
    public let amplitude: Float
}
```

---

## ⚙️ API Overview

### WWSpectrumViewUI

A SwiftUI view that reads raw bands from `ViewModel` and renders the spectrum bars.

### Color Schemes

- `rainbow`
- `fire`
- `ocean`
- `neon`
- `sunset`
- `matrix`
- `custom([Color])`

### Bar Styles

- `rounded`
- `sharp`
- `glow`
- `gradient`

---

## 📖 Example Workflow

1. Install a tap on an audio node.
2. Receive raw band data in the callback.
3. Publish the raw bands into the view model.
4. Let `WWSpectrumViewUI` render the live bars.

---

## ⚠️ Notes

- `fftSize` must be a power of two, such as `512`, `1024`, or `2048`.
- `viewModel.rawBands` should be updated on the main thread.
- The UI uses `GeometryReader` to adapt to different sizes.
- `bandAmplitude(_:)` converts raw band values into a normalized display amplitude.
