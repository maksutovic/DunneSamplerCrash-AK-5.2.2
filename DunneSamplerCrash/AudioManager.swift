//
//  AudioManager.swift
//  DunneSamplerCrash
//
//  Created by Maximilian Maksutovic on 11/17/21.
//

import Foundation
import CoreAudioKit
import AudioKit
import AudioKitEX
import DunneAudioKit
import CDunneAudioKit

protocol AudioManagerEngineStatus {
    func audioEngineDidStart()
}

class AudioManager {
    static let shared = { AudioManager() }()
    let engine = AudioEngine()
    
    let mainMixer: Mixer
    var pianoSampler: Sampler = Sampler()
    var trumpetSampler: Sampler = Sampler()
    
    var engineDelegate: AudioManagerEngineStatus?
    
    init() {
        Settings.bufferLength = .medium
        Settings.fixTruncatedRecordings = true
        Settings.enableLogging = true
        
        pianoSampler.isMonophonic = 1.0
        trumpetSampler.isMonophonic = 1.0
        
        mainMixer = Mixer([pianoSampler,trumpetSampler])
        engine.output = mainMixer
    }
    
    public func start() {
        do {
            try engine.start()
            print("Started Audio Engine")
            engineDelegate?.audioEngineDidStart()
        } catch let error as NSError {
            Log("ERROR: Can't start AudioKit! \(error)")
        }
    }
    
    public func stop() {
        engine.stop()
    }
}

extension AudioManager {
    func loadTrumpetSample() {
        let path = Bundle.main.path(forResource: "trumpet-sample", ofType:"aif")!
        let url = URL(fileURLWithPath: path)
        do {
           let audioFile = try AVAudioFile(forReading: url)
            let sampleDescriptor = SampleDescriptor(noteNumber: 60, noteFrequency: 261.63, minimumNoteNumber: 30, maximumNoteNumber: 80, minimumVelocity: 1, maximumVelocity: 127, isLooping: false, loopStartPoint: 0.0, loopEndPoint: 2.0, startPoint: 0.0, endPoint: 2.0)
            self.trumpetSampler = Sampler(sampleDescriptor: sampleDescriptor, file: audioFile)
            self.trumpetSampler.masterVolume = 1.0
            self.trumpetSampler.isMonophonic = 1.0
            self.trumpetSampler.loopThruRelease = 0.0
        } catch {
            print("ERROR: can't load audio file:\(error)")
        }
        
    }
    func loadPianoSamples() {
        DispatchQueue.main.async {
            let sfzPath = Bundle.main.bundlePath
            self.pianoSampler = Sampler(sfzPath: sfzPath, sfzFileName: "sampler.sfz")
            self.pianoSampler.masterVolume = 1.0
            self.pianoSampler.isMonophonic = 1.0
            self.pianoSampler.loopThruRelease = 0.0
        }
    }
    
    func playPiano(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        pianoSampler.play(noteNumber: note, velocity: velocity, channel: channel)
    }
    
    func stopPiano(note: MIDINoteNumber, channel: MIDIChannel) {
        pianoSampler.stop(noteNumber: note, channel: channel)
    }
    
    func playTrumpet(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        trumpetSampler.play(noteNumber: note, velocity: velocity, channel: channel)
    }
    
    func stopTrumpet(note: MIDINoteNumber, channel: MIDIChannel) {
        trumpetSampler.stop(noteNumber: note, channel: channel)
    }
}
