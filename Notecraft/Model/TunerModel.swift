//
//  TunerModel.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 19/05/2024.
//

import Foundation
import Observation
import AVFoundation

enum FullNoteType: String, CaseIterable {
    case C, D, E, F, G, A, B
    case CSharp = "C♯"
    case DSharp = "D♯"
    case FSharp = "F♯"
    case GSharp = "G♯"
    case ASharp = "A♯"
    case DFlat = "D♭"
    case EFlat = "E♭"
    case GFlat = "G♭"
    case AFlat = "A♭"
    case BFlat = "B♭"
    
    var note: Note {
        switch self {
        case .C: return Note(.C, .natural)
        case .D: return Note(.D, .natural)
        case .E: return Note(.E, .natural)
        case .F: return Note(.F, .natural)
        case .G: return Note(.G, .natural)
        case .A: return Note(.A, .natural)
        case .B: return Note(.B, .natural)
        case .CSharp: return Note(.C, .sharp)
        case .DSharp: return Note(.D, .sharp)
        case .FSharp: return Note(.F, .sharp)
        case .GSharp: return Note(.G, .sharp)
        case .ASharp: return Note(.A, .sharp)
        case .DFlat: return Note(.D, .flat)
        case .EFlat: return Note(.E, .flat)
        case .GFlat: return Note(.G, .flat)
        case .AFlat: return Note(.A, .flat)
        case .BFlat: return Note(.B, .flat)
        }
    }
    
    var sharp: FullNoteType {
        switch self {
        case .C: return .CSharp
        case .D: return .DSharp
        case .F: return .FSharp
        case .G: return .GSharp
        case .A: return .ASharp
        default: return self
        }
    }
    
    var flat: FullNoteType {
        switch self {
        case .D: return .DFlat
        case .E: return .EFlat
        case .G: return .GFlat
        case .A: return .AFlat
        case .B: return .BFlat
        default: return self
        }
    }
    
    static let sharpPitchNote: [FullNoteType] = FullNoteType.allCases.filter { $0.note.accidental != .flat }
    static let flatPitchNote: [FullNoteType] = FullNoteType.allCases.filter { $0.note.accidental != .sharp }
}

@Observable
class TunerModel {
    var note: String = ""
    var accidental: AccidentalType = .natural
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
    
    func startTuning() {
        do {
            try audioEngine?.start()
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }

    func stopTuning() {
        audioEngine?.stop()
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
}

