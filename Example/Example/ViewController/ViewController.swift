//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2026/6/3.
//

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

