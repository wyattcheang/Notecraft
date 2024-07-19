//
//  MusicNotation.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 24/06/2024.
//

import Foundation

enum Direction {
    case up
    case down
}

struct Interval {
    var quality: IntervalQualityType
    var position: IntervalPositionType
    
    init?(quality: IntervalQualityType, position: IntervalPositionType) {
        // Check if the provided style is allowed for the provided series
        guard position.AvailableInterval.contains(quality) else {
            return nil  // Return nil to indicate an invalid combination
        }
        
        // If the combination is valid, initialize the properties
        self.quality = quality
        self.position = position
    }
    
    var semitone: Int {
        return quality.offset(for: position) + position.majorSemitone
    }
    
    var text: String {
        return "\(quality.abb) \(position)"
    }
}

enum IntervalQualityType: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case major
    case minor
    case perfect
    case augmented
    case diminished
        
    func offset(for position: IntervalPositionType) -> Int {
        switch (self, position) {
        case (.augmented, _): return 1
        case (.major, _), (.perfect, _): return 0
        case (.minor, _): return -1
        case (.diminished, .unison), (.diminished, .forth), (.diminished, .fifth), (.diminished, .octave): return -1
        case (.diminished, _): return -2
        }
    }
        
    var abb: String {
        return self.rawValue.prefix(3).capitalized
    }
}

enum IntervalPositionType: Int, CaseIterable, Identifiable {
    var id: Self { self }
    
    case unison = 1
    case second = 2
    case third = 3
    case forth = 4
    case fifth = 5
    case sixth = 6
    case seventh = 7
    case octave = 8
    
    var AvailableInterval: [IntervalQualityType] {
        switch self {
        case .unison, .octave: return [.perfect]
        case .forth, .fifth: return [.diminished, .perfect, .augmented]
        case .second, .third, .sixth, .seventh: return [.diminished, .minor, .major, .augmented]
        }
    }
    
    var reset: IntervalQualityType {
        switch self {
        case .unison, .octave, .forth, .fifth: return .perfect
        case .second, .third, .sixth, .seventh: return .major
        }
    }
    
    var majorSemitone: Int {
        switch self {
        case .unison:
            return 0
        case .second:
            return 2
        case .third:
            return 4
        case .forth:
            return 5
        case .fifth:
            return 7
        case .sixth:
            return 9
        case .seventh:
            return 11
        case .octave:
            return 12
        }
    }
}

enum BaseNoteType: Int, CaseIterable {
    case C = 0, D, E, F, G, A, B
    
    var frequencyPosition: Int {
        switch self {
        case .C: return -9
        case .D: return -7
        case .E: return -5
        case .F: return -4
        case .G: return -2
        case .A: return 0
        case .B: return 2
        }
    }
    
    var MIDIReference: Int {
        switch self {
        case .C: return 0
        case .D: return 2
        case .E: return 4
        case .F: return 5
        case .G: return 7
        case .A: return 9
        case .B: return 11
        }
    }
    
    var next: BaseNoteType {
        return BaseNoteType(rawValue: (self.rawValue + 1) % BaseNoteType.allCases.count) ?? .C
    }
    
    var prev: BaseNoteType {
        return BaseNoteType(rawValue: (self.rawValue - 1 + BaseNoteType.allCases.count) % BaseNoteType.allCases.count) ?? .C
    }
    
    var check: Int {
        return ((self.rawValue - 1 + BaseNoteType.allCases.count) % BaseNoteType.allCases.count)
    }
}

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

enum AccidentalType: String, Hashable, Identifiable {
    var id: Self { return self }
    
    case natural = "Natural"
    case sharp = "Sharp"
    case flat = "Flat"
    case doubleSharp = "Double Sharp"
    case doubleFlat = "Double Flat"
    
    var offset: Int {
        switch self {
        case .flat      : return -1
        case .natural   : return 0
        case .sharp     : return 1
        case .doubleSharp     : return 2
        case .doubleFlat     : return -2
        }
    }
    
    var symbol: String {
        switch self {
        case .sharp         : return "266F".toUnicode
        case .flat          : return "266D".toUnicode
        case .natural       : return ""
        case .doubleSharp   : return "1D12A".toUnicode
        case .doubleFlat    : return "1D12B".toUnicode
        }
    }
    
    var allSymbol: String {
        switch self {
        case .natural       : return "266E".toUnicode
        default             : return symbol
        }
    }
    
    static let preference: [AccidentalType] = [.sharp, .flat]
    
    static func from(offset: Int) -> AccidentalType? {
        switch offset {
        case -2: return .doubleFlat
        case -1: return .flat
        case 0:  return .natural
        case 1:  return .sharp
        case 2:  return .doubleSharp
        default: return nil
        }
    }
}

enum StepType: Int {
    case H = 1
    case W = 2
    case WH = 3
    
    var text: String {
        switch self {
        case .H: return "Half Step"
        case .W: return "Whole Step"
        case .WH: return "Whole Half Step"
        }
    }
}

enum ScaleOrder: Int {
    case both
    case ascending
    case descending
}

enum ScaleType: Hashable, Identifiable {
    case major
    case minor(MinorScaleType = .natural)
    
    var id: Self { return self }
    
    enum MinorScaleType {
        case natural
        case harmonic
        case melodic
    }
    
    var name: String {
        switch self {
        case .major:
                return "Major"
        case .minor(_):
            return "Minor"
        }
    }
    
    var nameWithType: String {
        switch self {
        case .major:
            return "Major"
        case .minor(let minorScaleType):
            switch minorScaleType {
            case .natural:
                return "Natural Minor"
            case .harmonic:
                return "Harmonic Minor"
            case .melodic:
                return "Melodic Minor"
            }
        }
    }
    
    var ascIntervals: [StepType] {
        switch self {
        case .major:
            return [.W, .W, .H, .W, .W, .W, .H]
        case .minor(let minorScaleType):
            switch minorScaleType {
            case .natural:
                return [.W, .H, .W, .W, .H, .W, .W]
            case .harmonic:
                return [.W, .H, .W, .W, .H, .WH, .H]
            case .melodic:
                return [.W, .H, .W, .W, .W, .W, .H]
            }
        }
    }
    
    var decIntervals: [StepType] {
        switch self {
        case .major, .minor(.harmonic), .minor(.natural): return ascIntervals.reversed()
        case .minor(.melodic): return [.W, .W, .H, .W, .W, .H, .W]
        }
    }
    
    static let basicCase: [ScaleType] = [.major, .minor(.natural)]
    static let TypeCase: [ScaleType] = [.major, .minor(.natural), .minor(.harmonic), .minor(.melodic)]
}

enum KeyType: String, CaseIterable, Identifiable {
    case C, Csharp, Dflat, D, Dsharp, Eflat, E, F, Fsharp, Gflat, G, Gsharp, Aflat, A, Asharp, Bflat, B, Cflat
    
    var id: Self { self }
    
    var baseNote: BaseNoteType {
        switch self {
        case .C, .Csharp, .Cflat: return .C
        case .D, .Dsharp, .Dflat: return .D
        case .E, .Eflat: return .E
        case .F, .Fsharp: return .F
        case .G, .Gsharp, .Gflat: return .G
        case .A, .Asharp, .Aflat: return .A
        case .B, .Bflat: return .B
        }
    }
    
    var accidental: AccidentalType {
        switch self {
        case .C, .D, .E, .F, .G, .A, .B: return .natural
        case .Csharp, .Dsharp, .Fsharp, .Gsharp, .Asharp: return .sharp
        case .Dflat, .Eflat, .Gflat, .Aflat, .Bflat, .Cflat: return .flat
        }
    }
    
    var note: Note {
        return Note(baseNote, accidental)
    }
    
    var text: String {
        return "\(baseNote)\(accidental.symbol)"
    }
}

extension KeyType {
    static let sharpMajorKeysAdded: [BaseNoteType] = [.F, .C, .G, .D, .A, .E, .B]
    static let sharpMinorKeysAdded: [BaseNoteType] = [.A, .E, .B, .F, .C, .G, .D]
    
    static let sharpKeysMajor: [KeyType] = [.G, .D, .A, .E, .B, .Fsharp, .Csharp]
    static let flatKeysMajor: [KeyType] = [.F, .Bflat, .Eflat, .Aflat, .Dflat, .Gflat, .Cflat]
    static let sharpKeysMinor: [KeyType] = [.E, .B, .Fsharp, .Csharp, .Gsharp, .Dsharp, .Asharp]
    static let flatKeysMinor: [KeyType] = [.D, .G, .C, .F, .Bflat, .Eflat, .Aflat]
    
    static let circleOfFifthMajorSharp: [KeyType] = [.C, .G, .D, .A, .E, .B, .Fsharp, .Csharp, .Aflat, .Eflat, .Bflat, .F]
    static let circleOfFifthMajorFlat: [KeyType] = [.C, .G, .D, .A, .E, .Cflat, .Gflat, .Dflat, .Aflat, .Eflat, .Bflat, .F]
    static let circleOfFifthMinorSharp: [KeyType] = [.A, .E, .B, .Fsharp, .Csharp, .Gsharp, .Dsharp, .Asharp, .F, .C, .G, .D]
    static let circleOfFifthMinorFlat: [KeyType] = [.A, .E, .B, .Fsharp, .Csharp, .Aflat, .Eflat, .Bflat, .F, .C, .G, .D]
}

enum ClefType: String, CaseIterable, Identifiable {
    case treble
    case bass
    case alto
    case tenor
    
    var id: Self { self }
    
    var symbol: String {
        switch self {
        case .treble: return "1D11E".toUnicode
        case .bass: return "1D122".toUnicode
        case .alto: return "1D121".toUnicode
        case .tenor: return "1D121".toUnicode
        }
    }
    
    var yOffset: CGFloat {
        switch self {
        case .treble: return 0
        case .bass: return -0.9
        case .alto: return 0
        case .tenor: return -2.3
        }
    }
    
    var firstBottomLedgerPitch: BasePitch {
        switch self {
        case .treble: return BasePitch(note: .D, octave: 4)
        case .bass: return BasePitch(note: .F, octave: 2)
        case .alto: return BasePitch(note: .E, octave: 3)
        case .tenor: return BasePitch(note: .B, octave: 2)
        }
    }
    
    var firstTopLedgerPitch: BasePitch {
        switch self {
        case .treble: return BasePitch(note: .G, octave: 5)
        case .bass: return BasePitch(note: .B, octave: 3)
        case .alto: return BasePitch(note: .A, octave: 4)
        case .tenor: return BasePitch(note: .G, octave: 4)
        }
    }
    
    var preferenceOctaveRange: ClosedRange<Int> {
        switch self {
        case .treble: return 4...6
        case .bass: return 2...4
        case .alto: return 3...5
        case .tenor: return 3...5
        }
    }
    
    var defaultOctave: Int {
        return (preferenceOctaveRange.lowerBound + preferenceOctaveRange.upperBound) / 2
    }
}

enum NotationSize: String, CaseIterable, Identifiable {
    case standard
    case large
    
    var id: Self { self }
    var CGFloatValue: CGFloat {
        switch self {
        case .standard:
            return 36.0
        case .large:
            return 48.0
        }
    }
}

extension BaseNoteType {
    private static let baseOffsets: [ClefType: [BaseNoteType: CGFloat]] = [
        .treble: [.C: -3, .D: -2, .E: -1, .F: 0, .G: 1, .A: 2, .B: 3],
        .alto:   [.C: -4, .D: -3, .E: -2, .F: -1, .G: 0, .A: 1, .B: 2],
        .tenor:  [.C: -2, .D: -1, .E: 0, .F: 1, .G: 2, .A: 3, .B: 4],
        .bass:   [.C: -5, .D: -4, .E: -3, .F: -2, .G: -1, .A: 0, .B: 1]
    ]
    
    func baseOffset(for clefType: ClefType) -> CGFloat {
        return BaseNoteType.baseOffsets[clefType]?[self] ?? 0
    }
    
    public static let clefBaseOctaves: [ClefType: Int] = [
        .bass: 2,
        .alto: 3,
        .tenor: 3,
        .treble: 4
    ]
    
    func octaveShift(for clefType: ClefType, octave: Int, spacing: CGFloat) -> CGFloat {
        guard let clefBaseOctave = BaseNoteType.clefBaseOctaves[clefType] else { return 0 }
        return spacing * CGFloat(octave - clefBaseOctave) * 7
    }
    
    func offset(for clefType: ClefType, in octave: Int, notationSize: NotationSize) -> CGFloat {
        let spacing = notationSize.CGFloatValue / 8
        return -(baseOffset(for: clefType) * spacing + octaveShift(for: clefType, octave: octave, spacing: spacing))
    }
}

enum DurationType: CaseIterable {
    case breve
    case semibreve
    case minim
    case crotchet
    case quaver
    case semiquaver
    case demisemiquaver
    case hemidemisemiquaver
    
    var note: String {
        switch self {
        case .breve: return "1D15C".toUnicode
        case .semibreve: return "1D15D".toUnicode
        case .minim: return "1D15E".toUnicode
        case .crotchet: return "1D15F".toUnicode
        case .quaver: return "1D160".toUnicode
        case .semiquaver: return "1D161".toUnicode
        case .demisemiquaver: return "1D152".toUnicode
        case .hemidemisemiquaver: return "1D153".toUnicode
        }
    }
    
    var rest: String {
        switch self {
        case .breve: return "1D13A".toUnicode
        case .semibreve: return "1D13B".toUnicode
        case .minim: return "1D13C".toUnicode
        case .crotchet: return "1D13D".toUnicode
        case .quaver: return "1D13E".toUnicode
        case .semiquaver: return "1D13F".toUnicode
        case .demisemiquaver: return "1D140".toUnicode
        case .hemidemisemiquaver: return "1D141".toUnicode
        }
    }
    
    var durationInBeats: Double {
        switch self {
        case .breve: return 8.0
        case .semibreve: return 4.0
        case .minim: return 2.0
        case .crotchet: return 1.0
        case .quaver: return 0.5
        case .semiquaver: return 0.25
        case .demisemiquaver: return 0.125
        case .hemidemisemiquaver: return 0.0625
        }
    }
}

struct Note: Hashable, Identifiable {
    var id: String { "\(baseNote.rawValue)\(accidental.rawValue)" }
    var baseNote: BaseNoteType
    var accidental: AccidentalType

    init(_ baseNote: BaseNoteType, _ accidental: AccidentalType) {
        self.baseNote = baseNote
        self.accidental = accidental
    }
    
    var MIDIReference: Int {
        return baseNote.MIDIReference + accidental.offset
    }
    
    var frequencyPositionReference: Int {
        baseNote.frequencyPosition + accidental.offset
    }
    
    var text: String {
        return "\(baseNote)\(accidental.symbol)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(baseNote)
        hasher.combine(accidental)
    }
}

struct BasePitch {
    var note: BaseNoteType
    var octave: Int
    
    func toPitch(accidental: AccidentalType) -> Pitch {
        return Pitch(Note(note, accidental), octave: octave)
    }
}

struct Pitch: Hashable, Identifiable {
    var id: String { "\(note.baseNote.rawValue)\(note.accidental.rawValue)\(octave)" }
    var note: Note
    var octave: Int
    
    init(_ note: Note, octave: Int = 4) {
        self.note = note
        self.octave = octave
    }
    
    var MIDINote: UInt8 {
        return UInt8((octave + 1) * 12 + note.MIDIReference)
    }
    
    var text: String {
        return "\(note.text)\(octave)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(note)
        hasher.combine(octave)
    }
    
    var basePitch: BasePitch {
        return BasePitch(note: self.note.baseNote, octave: self.octave)
    }
}

enum TimeSignBeat: String {
    case duple
    case triple
    case quadruple
    case irregular
}

enum TimeSignComplexity: String {
    case simple
    case compound
    case irregular
}

struct KeyScale {
    var scale: ScaleType
    var key: KeyType
    
    init(scale: ScaleType, key: KeyType) {
        self.scale = scale
        self.key = key
    }
}

class MusicNotation {
    // Enharmonic equivalents dictionary using Note struct
    let enharmonicEquivalents: [Int: [Note]] = [
        0: [Note(.C, .natural), Note(.B, .sharp), Note(.D, .doubleFlat)],
        1: [Note(.C, .sharp), Note(.D, .flat), Note(.B, .doubleSharp)],
        2: [Note(.D, .natural), Note(.C, .doubleSharp), Note(.E, .doubleFlat)],
        3: [Note(.D, .sharp), Note(.E, .flat), Note(.F, .doubleFlat)],
        4: [Note(.E, .natural), Note(.F, .flat), Note(.D, .doubleSharp)],
        5: [Note(.F, .natural), Note(.E, .sharp), Note(.G, .doubleFlat)],
        6: [Note(.F, .sharp), Note(.G, .flat), Note(.E, .doubleSharp)],
        7: [Note(.G, .natural), Note(.F, .doubleSharp), Note(.A, .doubleFlat)],
        8: [Note(.G, .sharp), Note(.A, .flat)],
        9: [Note(.A, .natural), Note(.G, .doubleSharp), Note(.B, .doubleFlat)],
        10: [Note(.A, .sharp), Note(.B, .flat), Note(.C, .doubleFlat)],
        11: [Note(.B, .natural), Note(.C, .flat), Note(.A, .doubleSharp)],
        ]

    
    public static let shared = MusicNotation()
    
    func generateScale(scaleType: ScaleType, key: KeyType, startingOctave: Int = 4, order: ScaleOrder = .ascending) -> [Pitch] {
        var ascNote: [Pitch] = []
        var dscNote: [Pitch] = []
        var octave = startingOctave
        var note = Note(key.baseNote, key.accidental)
        
        ascNote.append(Pitch(note, octave: octave))
        
        for interval in scaleType.ascIntervals {
            if note.baseNote == .B {
                octave += 1
            }
            let nextNote = nextNote(note, interval: interval, isForward: true)
            ascNote.append(Pitch(nextNote, octave: octave))
            note = nextNote
        }
        
        note = Note(key.baseNote, key.accidental)
        octave = startingOctave + 1
        dscNote.append(Pitch(note, octave: octave))
        
        for interval in scaleType.decIntervals {
            if note.baseNote == .C {
                octave -= 1
            }
            let nextNote = nextNote(note, interval: interval, isForward: false)
            dscNote.append(Pitch(nextNote, octave: octave))
            note = nextNote
        }
        
        switch order {
        case .ascending:
            return ascNote
        case .descending:
            return dscNote
        case .both:
            return ascNote.dropLast() + dscNote
        }
    }

    func nextNote(_ note: Note, interval: StepType, isForward: Bool) -> Note {
        guard let currentIndex = enharmonicEquivalents.first(where: { $0.value.contains { $0 == note } })?.key else {
            return note
        }
        
        let nextIndex = (currentIndex + (isForward ? interval.rawValue : -interval.rawValue) + 12) % 12
        let nextNotes = enharmonicEquivalents[nextIndex]
        
        let nextMeetNote = isForward ? note.baseNote.next : note.baseNote.prev
        
        if let nextNote = nextNotes?.first(where: { $0.baseNote == nextMeetNote }) {
            return nextNote
        }
        return note
    }

    func addOctave(notes: [Note], startingOctave: Int = 4, ascending: Bool = true) -> [Pitch] {
        var pitchNotes: [Pitch] = []
        var currentOctave = startingOctave
        
        for note in notes {
            let pitchNote = Pitch(note, octave: currentOctave)
            pitchNotes.append(pitchNote)
            
            // Adjust octave based on the note and direction
            if note.baseNote == .B {
                if ascending {
                    currentOctave += 1
                } else {
                    currentOctave -= 1
                }
            }
        }
        
        return pitchNotes
    }
    
    enum PitchCompare {
        case higher
        case lower
        case equal
    }

    func compareTwoPitch(pitch1: Pitch, pitch2: Pitch) -> PitchCompare {
        if pitch1.octave != pitch2.octave {
            return pitch1.octave > pitch2.octave ? .higher : .lower
        }
        
        if pitch1.note.baseNote.rawValue != pitch2.note.baseNote.rawValue {
            return pitch1.note.baseNote.rawValue > pitch2.note.baseNote.rawValue ? .higher : .lower
        }
        
        if pitch1.note.accidental.offset != pitch2.note.accidental.offset {
            return pitch1.note.accidental.offset > pitch2.note.accidental.offset ? .higher : .lower
        }
        
        return .equal
    }
    
    func baseNoteDistance(from pitch1: BasePitch, to pitch2: BasePitch) -> Int {
        let baseNoteDistance = pitch2.note.rawValue - pitch1.note.rawValue
        let octaveDistance = pitch2.octave - pitch1.octave
        return baseNoteDistance + (octaveDistance * 7)
    }
    
    func semitoneDifference(from pitch1: Pitch, to pitch2: Pitch) -> Int {
        let semitones1 = pitch1.MIDINote
        let semitones2 = pitch2.MIDINote
        
        // Calculate the absolute difference in semitones
        let semitoneDifference = abs(Int(semitones1) - Int(semitones2))
        
        return semitoneDifference
    }
    
    func findInterval(from pitch1: Pitch, to pitch2: Pitch) -> Interval? {
        let baseDifference = baseNoteDistance(from: pitch1.basePitch, to: pitch2.basePitch)
        let semitoneDifference = semitoneDifference(from: pitch1, to: pitch2)
        
        guard let position = IntervalPositionType(rawValue: (baseDifference + 1)) else {
            return nil
        }
        
        // Determine the semitone offset for this series
        let semitone = position.majorSemitone
        
        for quality in position.AvailableInterval {
            if quality.offset(for: position) == semitoneDifference - semitone {
                return Interval(quality: quality, position: position)
            }
        }
        return nil
    }
    
    func upBasePitch(basePitch: BasePitch, loop: Int) -> BasePitch {
        var note = basePitch.note
        var octave = basePitch.octave
        for _ in 0..<loop {
            if note == .B {
                octave += 1
            }
            note = note.next
        }
        return BasePitch(note: note, octave: octave)
    }
    
    func intervalPitch(from pitch: Pitch, in interval: Interval) -> Pitch? {
        let baseNoteShift = interval.position.rawValue - 1
        let basePitch = upBasePitch(basePitch: pitch.basePitch, loop: baseNoteShift)
        
        guard let accidental = AccidentalType.from(offset: interval.quality.offset(for: interval.position)) else {
            return nil
        }
        
        return basePitch.toPitch(accidental: accidental)
    }
    
    func getLedgerLine(pitch: Pitch, clef: ClefType) -> (Int, Direction) {
        let bottomDifference = baseNoteDistance(from: pitch.basePitch, to: clef.firstBottomLedgerPitch)
        let topDifference = baseNoteDistance(from: clef.firstTopLedgerPitch, to: pitch.basePitch)
        
        if topDifference > 0 {
            return (Int(ceil(Double(topDifference) / 2.0)), .up)
        } else if bottomDifference > 0 {
            return (Int(ceil(Double(bottomDifference) / 2.0)), .down)
        } else {
            return (0, .up)
        }
    }
}
