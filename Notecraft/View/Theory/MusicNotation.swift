//
//  MusicNotation.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 24/06/2024.
//

import Foundation

enum AccidentalType: Int, Hashable, Identifiable, CaseIterable {
    var id: Self { self }
    
    case doubleFlat = -2, flat, natural, sharp, doubleSharp
    
    var offset: Int {
        return self.rawValue
    }
    
    static func from(offset: Int) -> AccidentalType? {
        return AccidentalType(rawValue: offset)
    }
}

extension AccidentalType {
    var text: String {
        switch self {
        case .doubleFlat: return "Double Flat"
        case .flat: return "Flat"
        case .natural: return "Natural"
        case .sharp: return "Sharp"
        case .doubleSharp: return "Double Sharp"
        }
    }

    var symbol: String {
        switch self {
        case .sharp: return 0x266F.toUnicode
        case .flat: return 0x266D.toUnicode
        case .natural: return ""
        case .doubleSharp: return 0x1D12A.toUnicode
        case .doubleFlat: return 0x1D12B.toUnicode
        }
    }

    var allSymbol: String {
        self == .natural ? 0x266E.toUnicode : symbol
    }

    static let preference: [AccidentalType] = [.sharp, .flat]
}

enum BaseNoteType: Int, CaseIterable {
    case C = 0, D, E, F, G, A, B
    
    var frequencyPosition: Int {
        return [-9, -7, -5, -4, -2, 0, 2][rawValue]
    }
    
    var MIDIReference: Int {
        return frequencyPosition + 9
    }
    
    var next: BaseNoteType {
        return BaseNoteType(rawValue: (self.rawValue + 1) % BaseNoteType.allCases.count) ?? .C
    }
    
    var prev: BaseNoteType {
        return BaseNoteType(rawValue: (self.rawValue - 1 + BaseNoteType.allCases.count) % BaseNoteType.allCases.count) ?? .C
    }
}

extension BaseNoteType {
    public static let clefBaseOctaves: [ClefType: Int] = [
        .bass: 2,
        .alto: 3,
        .tenor: 3,
        .treble: 4
    ]
    
    private static let baseOffsets: [ClefType: [BaseNoteType: CGFloat]] = [
        .treble: [.C: -3, .D: -2, .E: -1, .F: 0, .G: 1, .A: 2, .B: 3],
        .alto:   [.C: -4, .D: -3, .E: -2, .F: -1, .G: 0, .A: 1, .B: 2],
        .tenor:  [.C: -2, .D: -1, .E: 0, .F: 1, .G: 2, .A: 3, .B: 4],
        .bass:   [.C: -5, .D: -4, .E: -3, .F: -2, .G: -1, .A: 0, .B: 1]
    ]
    
    func baseOffset(for clefType: ClefType) -> CGFloat {
        return BaseNoteType.baseOffsets[clefType]?[self] ?? 0
    }
    
    func octaveShift(for clefType: ClefType, octave: Int, spacing: CGFloat) -> CGFloat {
        guard let clefBaseOctave = BaseNoteType.clefBaseOctaves[clefType] else { return 0 }
        return spacing * CGFloat(octave - clefBaseOctave) * 7
    }
    
    func offset(for clefType: ClefType, in octave: Int, notationSize: NotationSize) -> CGFloat {
        let spacing = notationSize.CGFloatValue / 8
        return -(baseOffset(for: clefType) * spacing + octaveShift(for: clefType, octave: octave, spacing: spacing))
    }
}

enum FullNoteType: String, CaseIterable {
    case C, D, E, F, G, A, B
    case CSharp = "C♯", DSharp = "D♯", FSharp = "F♯", GSharp = "G♯", ASharp = "A♯"
    case DFlat = "D♭", EFlat = "E♭", GFlat = "G♭", AFlat = "A♭", BFlat = "B♭"
    
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

    
    static let sharpPitchNote: [FullNoteType] = FullNoteType.allCases.filter { $0.note.accidental != .flat }
    static let flatPitchNote: [FullNoteType] = FullNoteType.allCases.filter { $0.note.accidental != .sharp }
}

enum ToneType: Int {
    case H = 1, W, WH
}

enum ScaleOrderType: String, CaseIterable, Identifiable {
    case both
    case ascending
    case descending
    
    var id: Self { return self }
}

enum ScaleType: Hashable, Identifiable {
    case major
    case minor(MinorScaleType = .natural)
    
    var id: Self { self }
    
    enum MinorScaleType: String, CaseIterable, Identifiable {
        case natural, harmonic, melodic
        
        var id: Self { self }
    }
    
    var name: String {
        switch self {
        case .major: return "Major"
        case .minor: return "Minor"
        }
    }
    
    var nameWithType: String {
        switch self {
        case .major:
            return "Major"
        case .minor(let minorScaleType):
            return "\(minorScaleType.rawValue.capitalized) Minor"
        }
    }
    
    var ascIntervals: [ToneType] {
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
    
    var decIntervals: [ToneType] {
        switch self {
        case .major, .minor(.natural), .minor(.harmonic):
            return ascIntervals.reversed()
        case .minor(.melodic):
            return [.W, .W, .H, .W, .W, .H, .W]
        }
    }
    
    static let basicCases: [ScaleType] = [.major, .minor(.natural)]
    static let allTypes: [ScaleType] = [.major, .minor(.natural), .minor(.harmonic), .minor(.melodic)]
}

enum LedgerLineDirection {
    case up
    case down
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

extension ClefType {
    var symbol: String {
        switch self {
        case .treble: return 0x1D11E.toUnicode
        case .bass: return 0x1D122.toUnicode
        case .alto: return 0x1D121.toUnicode
        case .tenor: return 0x1D121.toUnicode
        }
    }
    
    var offset: CGFloat {
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

enum DurationType: Int, CaseIterable {
    case breve = 0, semibreve, minim, crotchet, quaver, semiquaver, demisemiquaver, hemidemisemiquaver
    
    var note: String {
        return (0x1D15C + self.rawValue).toUnicode
    }
    
    var rest: String {
        return (0x1D13A + self.rawValue).toUnicode
    }
    
    var durationInBeats: Double {
        return 8.0 / pow(2, Double(self.rawValue))
    }
}

enum Meter: Hashable, Identifiable {
    case simple(BeatMeasurement)
    case compound(BeatMeasurement)
    case odd
    
    enum BeatMeasurement: String {
        case duple
        case triple
        case quadruple
        case irregular
    }
    
    var id: Self { self }
    
    var text: String {
        switch self {
        case .simple(let beatMeasurement):
            return "Simple \(beatMeasurement.rawValue.capitalized)"
        case .compound(let beatMeasurement):
            return "Compound \(beatMeasurement.rawValue.capitalized)"
        case .odd:
            return "Odd Meter"
        }
    }
}

enum IntervalGenericType: Int, CaseIterable, Identifiable {
    case unison = 1, second, third, forth, fifth, sixth, seventh, octave
    
    var id: Self { self }
    
    var availableQualities: [IntervalQualityType] {
        switch self {
        case .unison, .octave   : [.perfect]
        case .forth, .fifth     : [.diminished, .perfect, .augmented]
        default                 : [.diminished, .minor, .major, .augmented]
        }
    }
    
    var defaultQuality: IntervalQualityType {
        [.unison, .octave, .forth, .fifth].contains(self) ? .perfect : .major
    }

    var defaultSemitone: Int {
        [0, 2, 4, 5, 7, 9, 11, 12][rawValue - 1]
    }
    
    var ordinal: String { self.rawValue.ordinal }
}

enum IntervalQualityType: String, CaseIterable, Identifiable {
    case major, minor, perfect, augmented, diminished
    
    var id: Self { self }
    
    func offset(for position: IntervalGenericType) -> Int {
        switch (self, position) {
        case (.augmented, _): 1
        case (.major, _), (.perfect, _): 0
        case (.minor, _): -1
        case (.diminished, .unison), (.diminished, .forth), (.diminished, .fifth), (.diminished, .octave): -1
        case (.diminished, _): -2
        }
    }
    
    var abb: String { rawValue.prefix(3).capitalized }
}

struct Note: Hashable, Identifiable {
    var baseNote: BaseNoteType
    var accidental: AccidentalType

    var id: Self { self }
    
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
}

struct BasePitch {
    var note: BaseNoteType
    var octave: Int
    
    func toPitch(accidental: AccidentalType) -> Pitch {
        return Pitch(Note(note, accidental), octave: octave)
    }
}

struct Pitch: Hashable, Identifiable {
    var note: Note
    var octave: Int
    
    var id: Self { self }
    
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

struct Interval {
    var generic: IntervalGenericType
    var quality: IntervalQualityType
    
    init?(quality: IntervalQualityType, generic: IntervalGenericType) {
        // Check if the provided style is allowed for the provided series
        guard generic.availableQualities.contains(quality) else {
            return nil  // Return nil to indicate an invalid combination
        }
        
        // If the combination is valid, initialize the properties
        self.quality = quality
        self.generic = generic
    }
    
    var semitone: Int {
        return quality.offset(for: generic) + generic.defaultSemitone
    }
    
    var text: String {
        return "\(quality.rawValue.capitalized) \(generic)"
    }
}

class MusicNotation {
    
    public static let shared = MusicNotation()
    
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

    
    
    func generateScale(from scale: ScaleType,
                       in key: KeyType,
                       octave: Int = 4,
                       order: ScaleOrderType = .ascending) -> [Pitch] {
        
        func generateNotes(tone: [ToneType], startingNote: Note, startingOctave: Int, isForward: Bool) -> [Pitch] {
            var notes: [Pitch] = []
            var octave = startingOctave
            var note = startingNote

            notes.append(Pitch(note, octave: octave))
            for interval in tone {
                if (isForward && note.baseNote == .B) || (!isForward && note.baseNote == .C) {
                    octave += isForward ? 1 : -1
                }
                note = nextNote(note, tone: interval, isForward: isForward)
                notes.append(Pitch(note, octave: octave))
            }
            return notes
        }

        let ascNotes = generateNotes(tone: scale.ascIntervals,
                                     startingNote: Note(key.baseNote, key.accidental),
                                     startingOctave: octave, isForward: true)
        let dscNotes = generateNotes(tone: scale.decIntervals,
                                     startingNote: Note(key.baseNote, key.accidental),
                                     startingOctave: octave + 1, isForward: false)

        switch order {
        case .ascending:
            return ascNotes
        case .descending:
            return dscNotes
        case .both:
            return ascNotes.dropLast() + dscNotes
        }
    }

    func nextNote(_ note: Note, tone: ToneType, isForward: Bool) -> Note {
        guard let currentIndex = enharmonicEquivalents.first(where: { $0.value.contains(note) })?.key else {
            return note
        }

        let nextIndex = (currentIndex + (isForward ? tone.rawValue : -tone.rawValue) + 12) % 12
        let nextNotes = enharmonicEquivalents[nextIndex]
        let nextMeetNote = isForward ? note.baseNote.next : note.baseNote.prev

        if let nextNote = nextNotes?.first(where: { $0.baseNote == nextMeetNote }) {
            return nextNote
        }
        return note
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
        
        guard let position = IntervalGenericType(rawValue: (baseDifference + 1)) else {
            return nil
        }
        
        // Determine the semitone offset for this series
        let semitone = position.defaultSemitone
        
        for quality in position.availableQualities {
            if quality.offset(for: position) == semitoneDifference - semitone {
                return Interval(quality: quality, generic: position)
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
        let baseNoteShift = interval.generic.rawValue - 1
        let basePitch = upBasePitch(basePitch: pitch.basePitch, loop: baseNoteShift)
        
        let semitone = semitoneDifference(from: pitch, to: basePitch.toPitch(accidental: .natural))
        let difference = interval.semitone - semitone
        
        guard let accidental = AccidentalType.from(offset: difference) else {
            return nil
        }
        
        return basePitch.toPitch(accidental: accidental)
    }
    
    func getLedgerLine(pitch: Pitch, clef: ClefType) -> (Int, LedgerLineDirection) {
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
