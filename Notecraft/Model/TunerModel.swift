//
//  TunerModel.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 19/05/2024.
//

import Foundation
import Observation
import AVFoundation

@Observable
class TunerModel {
    var note: String = ""
    var accidental: AccidentalType = .sharp
    var octave: Int = 4
    var cent: Double = 0.0
    var frequency: Double = 0.0
    
    var pitchDict: [FullNoteType: [Double]] {
        pitchDictGenerator()
    }
    
    private var pitchStandard: Double = 440.0
    private var accidentalPreference: AccidentalType = .sharp
    
    private var audioSession: AVAudioSession?
    private var audioEngine: AVAudioEngine?
    private var audioInputNode: AVAudioInputNode?
    private var bufferSize: AVAudioFrameCount
    private var sampleRate: Double
    
    init(bufferSize: AVAudioFrameCount = 1024, sampleRate: Double = 44100.0) {
        self.bufferSize = bufferSize
        self.sampleRate = sampleRate
        setupAudioEngine()
    }
    
    func setPrams(pitchStandard: Double = 440.0, accidentalPreference: AccidentalType = .sharp) {
        self.pitchStandard = pitchStandard
        self.accidentalPreference = accidentalPreference
    }
    
    private func setupAudioEngine() {
        audioSession = AVAudioSession.sharedInstance()
        guard let audioSession = audioSession else { return }
        do {
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch let error as NSError {
            print("ERROR:", error)
        }
        
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        audioInputNode = audioEngine.inputNode
        guard let inputNode = audioInputNode else { return }
        
        let inputFormat = inputNode.outputFormat(forBus: 0)
        sampleRate = inputFormat.sampleRate
        
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { buffer, time in
            self.processBuffer(buffer)
        }
        
        audioEngine.prepare()
    }
    
    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else {
            return
        }
        let channelDataValue = channelData.pointee
        let channelDataArray = Array(UnsafeBufferPointer(start: channelDataValue, count: Int(buffer.frameLength)))
        let yin = YIN(sampleRate: sampleRate, bufferSize: Int(bufferSize))
        let frequency = yin.detectPitch(data: channelDataArray)
        if frequency != 0.0 {
            DispatchQueue.main.async {
                self.frequency = Double(frequency)
                self.updateCurrentNoteAndOctave()
            }
        }
    }
    
    private func pitchDictGenerator() -> [FullNoteType: [Double]] {
        var dict = [FullNoteType: [Double]]()
        
        for octave in 0...7 {
            let PitchNotes = accidentalPreference == .flat ? FullNoteType.flatPitchNote : FullNoteType.sharpPitchNote
            
            for note in PitchNotes {
                let relativePosition = note.note.frequencyPositionReference + (octave - 4) * 12
                let frequency = pitchStandard * pow(2.0, Double(relativePosition) / 12.0)
                dict[note, default: []].append(frequency)
            }
        }
        return dict
    }
    
    private func updateCurrentNoteAndOctave() {
        var closestNote: FullNoteType = .A
        var closestOctave: Int = 0
        var minDifference: Double = Double.greatestFiniteMagnitude
        
        let pitchDict = pitchDictGenerator()
        
        for (note, frequencies) in pitchDict {
            for (octave, noteFrequency) in frequencies.enumerated() {
                let centsDifference = abs(1200 * log2(frequency / noteFrequency))
                if centsDifference < minDifference {
                    minDifference = centsDifference
                    closestNote = note
                    closestOctave = octave
                }
            }
        }
        
        self.note = "\(closestNote.note.baseNote)"
        self.accidental = closestNote.note.accidental
        self.octave = closestOctave
        self.cent = 1200 * log2(frequency / pitchDict[closestNote]![closestOctave])
    }
    
    func start() {
        do {
            try audioEngine?.start()
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        audioEngine?.stop()
    }
}

//    private func analyzeBuffer(_ buffer: AVAudioPCMBuffer) {
//        guard let channelData = buffer.floatChannelData?[0] else { return }
//        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
//        let fft = FFT(sampleCount: Int(bufferSize), sampleRate: sampleRate)
//
//        let magnitudes = fft.calculateMagnitudes(buffer: channelDataArray)
//
//        if let maxMagnitude = magnitudes.max(), let maxIndex = magnitudes.firstIndex(of: maxMagnitude) {
//            let frequency = fft.frequency(at: maxIndex)
//            DispatchQueue.main.async {
//                self.frequency = frequency
//            }
//        }
//    }
//}
