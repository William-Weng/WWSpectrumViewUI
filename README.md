# WWSpectrumViewUI

![SwiftUI](https://img.shields.io/badge/SwiftUI-524520?logo=swift)
[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWSpectrumViewUI)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

`WWSpectrumViewUI` 是一個用 Swift、SwiftUI 與 Accelerate 製作的即時音訊頻譜分析與視覺化套件。它可以從 `AVAudioNode` 擷取音訊資料，轉成原始頻帶資料，並用可自訂的 SwiftUI 頻譜視圖呈現。 

[English](./README.en.md) | [繁體中文](./README.md)

https://github.com/user-attachments/assets/60f35681-554e-49d7-a943-5b7aa4dc28f8

---

## ✨ 特色

- 即時 FFT 頻譜分析。
- 輸出 `SpectrumBandRaw` 原始頻帶資料。
- 提供 SwiftUI 頻譜視覺化元件。
- 多種 bar 樣式：`rounded`、`sharp`、`glow`、`gradient`。
- 多種配色方案：`rainbow`、`fire`、`ocean`、`neon`、`sunset`、`matrix`、`custom`。
- 可設定 `fftSize`、`barCount`、`minFrequency`、`maxFrequency` 與動畫時間。
- 分離分析層與 UI 層，方便自行客製。 [web:221][web:226]

---

## 📦 安裝方式

### Swift Package Manager

在 `Package.swift` 中加入：

```swift
dependencies: [
    .package(url: "https://github.com/William-Weng/WWSpectrumViewUI.git", .upToNextMajor(from: "1.0.0"))
]
```

或者在 Xcode 中選擇 **File > Add Package Dependencies...**，貼上 GitHub 倉庫網址即可。

---

## 🚀 快速開始

### 1. 建立 ViewModel

```swift
let viewModel = WWSpectrumViewUI.ViewModel()
```

### 2. 安裝 raw tap

```swift
spectrumAnalyzer.installRawTap(on: audioNode, sampleRate: sampleRate) { bands in
    DispatchQueue.main.async { viewModel.rawBands = bands }
}
```

### 3. 顯示頻譜視圖

```swift
WWSpectrumViewUI(viewModel: viewModel, colorScheme: .rainbow, barStyle: .glow, duration: 0.25).frame(height: 220)
```

---

## 💡 使用範例

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

## 🧩 資料模型

### SpectrumBandRaw

`SpectrumBandRaw` 用來保存每個頻帶的原始 FFT bin 值，適合做進一步分析、自訂轉換或客製視覺化。

```swift
struct SpectrumBandRaw {
    public let index: Int
    public let lowerFrequency: Float
    public let upperFrequency: Float
    public let values: [Float]
}
```

### SpectrumBar

`SpectrumBar` 用來保存已正規化的振幅，適合拿來畫圖或輸出 JSON。

```swift
struct SpectrumBar: Codable {
    public let index: Int
    public let lowerFrequency: Float
    public let upperFrequency: Float
    public let amplitude: Float
}
```

---

## ⚙️ API 總覽

### WWSpectrumViewUI

SwiftUI 視覺化元件，會從 `ViewModel` 讀取 raw bands，並即時畫出頻譜條。

### ColorScheme

內建配色：

- `rainbow`
- `fire`
- `ocean`
- `neon`
- `sunset`
- `matrix`
- `custom([Color])`

### BarStyle

內建樣式：

- `rounded`
- `sharp`
- `glow`
- `gradient`

---

## 📖 資料流

1. 在音訊節點上安裝 tap。
2. 取得 raw band 資料。
3. 將資料更新到 view model。
4. 由 `WWSpectrumViewUI` 繪製即時 bar。

---

## ⚠️ 注意事項

- `fftSize` 必須是 2 的次方，例如 `512`、`1024`、`2048`。
- `viewModel.rawBands` 請在主執行緒更新。
- 頻譜視圖會依照容器大小自動調整。
- `bandAmplitude(_:)` 會把 raw band 轉成 `0...1` 的顯示振幅。

