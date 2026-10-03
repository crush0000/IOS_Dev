// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Deck Register

// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine

    var evacuationPriority: Int {
        switch self {
        case .bridge:
            return 1
        case .medbay:
            return 2
        case .lab:
            return 3
        case .engine:
            return 4
        case .cargo:
            return 5
        }
    }
}

print("\n--- LEVEL 1.1: DECKS ---")

for deck in Deck.allCases {
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}


// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let calculatedLevel = min(mass / 500, 3)
        return AlarmLevel(rawValue: calculatedLevel) ?? .red
    }
}

print("\n--- LEVEL 1.2: ALARM LEVEL ---")
print("0 kg:", AlarmLevel.level(forTotalMass: 0))
print("940 kg:", AlarmLevel.level(forTotalMass: 940))
print("4000 kg:", AlarmLevel.level(forTotalMass: 4000))


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}


// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)

    guard let tag = parts.first else {
        return .unknown(raw: line)
    }

    switch tag {

    case "crate":
        guard parts.count == 3,
              let id = Int(parts[1]),
              let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }

        return .crate(id: id, massKg: mass)

    case "container":
        guard parts.count == 3,
              let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }

        return .container(code: parts[1], massKg: mass)

    case "livestock":
        guard parts.count == 4,
              let count = Int(parts[2]),
              let massPerUnit = Int(parts[3]) else {
            return .unknown(raw: line)
        }

        return .livestock(
            species: parts[1],
            count: count,
            massPerUnitKg: massPerUnit
        )

    default:
        return .unknown(raw: line)
    }
}


// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {

    case .crate(_, let massKg):
        return massKg

    case .container(_, let massKg):
        return massKg

    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg

    case .unknown:
        return 0
    }
}


var totalManifestMass = 0
var unknownCount = 0

print("\n--- LEVEL 2: MANIFEST ---")

for line in rawManifest {
    let entry = parseEntry(line)

    totalManifestMass += mass(of: entry)

    switch entry {
    case .unknown(let raw):
        unknownCount += 1
        print("Unknown entry:", raw)

    case .crate(let id, let massKg):
        print("Crate \(id): \(massKg) kg")

    case .container(let code, let massKg):
        print("Container \(code): \(massKg) kg")

    case .livestock(let species, let count, let massPerUnitKg):
        print("Livestock \(species): \(count * massPerUnitKg) kg")
    }
}

let A = totalManifestMass

print("Total manifest mass:", A)
print("Unknown lines:", unknownCount)


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(
            name: name,
            deck: .medbay,
            oxygen: 100
        )
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(
            name: name,
            deck: .bridge,
            oxygen: 100
        )
    }
}


// 3.2
var crewRoster: [CrewSnapshot] = []

print("\n--- LEVEL 3.2: CREW ROSTER ---")

for record in crewData {
    if let deck = Deck(rawValue: record.deck) {
        let crew = CrewSnapshot(
            name: record.name,
            deck: deck,
            oxygen: record.oxygen
        )

        crewRoster.append(crew)

        print(
            "\(crew.name) - \(crew.deck.rawValue) - oxygen \(crew.oxygen)"
        )
    } else {
        print("WARNING: invalid deck for \(record.name): \(record.deck)")
    }
}


// 3.3
func breatheNormally(_ crew: CrewSnapshot) -> CrewSnapshot {
    var copy = crew
    copy.breathe(10)
    return copy
}

func breatheInout(_ crew: inout CrewSnapshot) {
    crew.breathe(10)
}

print("\n--- LEVEL 3.3: VALUE SEMANTICS ---")

var original = CrewSnapshot.rookie(named: "Test Crew")
var copied = original

print("Copy test BEFORE:")
print("Original oxygen:", original.oxygen)
print("Copy oxygen:", copied.oxygen)

copied.breathe(20)

print("Copy test AFTER:")
print("Original oxygen:", original.oxygen)
print("Copy oxygen:", copied.oxygen)


print("\nPlain parameter BEFORE:")
print("Original oxygen:", original.oxygen)

let changedCopy = breatheNormally(original)

print("Plain parameter AFTER:")
print("Original oxygen:", original.oxygen)
print("Returned copy oxygen:", changedCopy.oxygen)


print("\ninout BEFORE:")
print("Original oxygen:", original.oxygen)

breatheInout(&original)

print("inout AFTER:")
print("Original oxygen:", original.oxygen)


// Exercise other CrewSnapshot methods
var demoCrew = CrewSnapshot.rookie(named: "Aldiyar")

demoCrew.move(to: .engine)
print("Moved crew deck:", demoCrew.deck.rawValue)

demoCrew.reviveInMedbay()
print(
    "Revived crew:",
    demoCrew.deck.rawValue,
    "oxygen:",
    demoCrew.oxygen
)


// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // A class does not receive the same automatic memberwise
    // initializer that a struct receives.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil else {
            return false
        }

        guard chargeLevel >= 20 else {
            return false
        }

        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let crew = occupant else {
            return nil
        }

        chargeLevel -= 20
        occupant = nil

        return crew
    }
}


// 4.2
let pod = TeleportPod(id: "P-1", chargeLevel: 100)

let timur = crewRoster[0]
let dana = crewRoster[1]
let nurlan = crewRoster[3]

print("\n--- LEVEL 4.2: CHARGE LEDGER ---")

print("Starting charge:", pod.chargeLevel)

print("Load Timur:", pod.load(timur))
print("Charge after loading Timur:", pod.chargeLevel)

let firedTimur = pod.fire()
print("Timur fired:", firedTimur?.name ?? "none")
print("Charge after firing Timur:", pod.chargeLevel)


print("Load Dana:", pod.load(dana))
print("Charge after loading Dana:", pod.chargeLevel)

let firedDana = pod.fire()
print("Dana fired:", firedDana?.name ?? "none")
print("Charge after firing Dana:", pod.chargeLevel)


print("Load Nurlan:", pod.load(nurlan))
print("Charge after loading Nurlan:", pod.chargeLevel)

let firedNurlan = pod.fire()
print("Nurlan fired:", firedNurlan?.name ?? "none")
print("Charge after firing Nurlan:", pod.chargeLevel)


let emptyFire = pod.fire()
print("Empty fire result:", emptyFire?.name ?? "nil")
print("Charge after empty fire:", pod.chargeLevel)

let C = pod.chargeLevel


// 4.3
print("\n--- LEVEL 4.3: REFERENCE SEMANTICS ---")

let podReference = pod

print("Before change:")
print("pod charge:", pod.chargeLevel)
print("podReference charge:", podReference.chargeLevel)

podReference.chargeLevel = 35

print("After changing second reference:")
print("pod charge:", pod.chargeLevel)
print("podReference charge:", podReference.chargeLevel)


// Put it back because C must represent the charge
// immediately after the required sequence.
pod.chargeLevel = C


var snapshotOne = CrewSnapshot.rookie(named: "Value Test")
var snapshotTwo = snapshotOne

print("Struct before:")
print(snapshotOne.oxygen, snapshotTwo.oxygen)

snapshotTwo.oxygen = 30

print("Struct after:")
print(snapshotOne.oxygen, snapshotTwo.oxygen)

// Struct copies have independent values.
// Class variables can refer to the same object.


// MARK: Level 5 · Station Systems

// 5.1
final class Station {

    // Stored let property
    let callSign: String

    // Stored var property with observers
    var hullIntegrity: Int {
        willSet {
            print(
                "Hull integrity changing from \(hullIntegrity) to \(newValue)"
            )
        }

        didSet {
            hullIntegrity = min(max(hullIntegrity, 0), 100)
        }
    }

    // Stored property
    var oxygenByDeck: [Deck: Int]

    // Lazy stored property
    lazy var fullDiagnostics: String = {
        print("Running full scan...")

        return """
        Station \(callSign)
        Hull integrity: \(hullIntegrity)
        Total oxygen: \(totalOxygen)
        """
    }()

    // Computed read-only property
    var totalOxygen: Int {
        var total = 0

        for oxygen in oxygenByDeck.values {
            total += oxygen
        }

        return total
    }

    // Computed get + set property
    var averageOxygen: Int {
        get {
            guard !oxygenByDeck.isEmpty else {
                return 0
            }

            return totalOxygen / oxygenByDeck.count
        }

        set {
            let decks = Array(oxygenByDeck.keys)

            for deck in decks {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(
        callSign: String,
        hullIntegrity: Int,
        readings: [(deck: String, oxygen: Int)]
    ) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        self.oxygenByDeck = [:]

        for reading in readings {
            if let deck = Deck(rawValue: reading.deck) {
                self.oxygenByDeck[deck] = reading.oxygen
            } else {
                print("Skipping invalid deck reading:", reading.deck)
            }
        }
    }
}


print("\n--- LEVEL 5.1: STATION ---")

let station = Station(
    callSign: "ALMA-7",
    hullIntegrity: 85,
    readings: deckReadings
)

let B = station.averageOxygen

print("Station:", station.callSign)
print("Total oxygen:", station.totalOxygen)
print("Starting average oxygen:", B)

print("Diagnostics have not been accessed yet.")

print("First diagnostics access:")
print(station.fullDiagnostics)

print("Second diagnostics access:")
print(station.fullDiagnostics)


// 5.2
print("\n--- LEVEL 5.2: CLAMP TRAP ---")

station.hullIntegrity = 130
print("After setting 130:", station.hullIntegrity)

station.hullIntegrity = -40
print("After setting -40:", station.hullIntegrity)

station.hullIntegrity = 55
print("After setting 55:", station.hullIntegrity)

// Assigning hullIntegrity inside didSet does not call the
// observers recursively, so the clamp does not loop forever.


// MARK: Level 6 · Incident Reports

print("\n--- LEVEL 6: INCIDENT REPORTS ---")

/*
 REPORT 1

 Expected:
 The author expected every crew member in roster to lose
 10 oxygen.

 Actual:
 `member` is only a copy of each struct value from the array.
 Changing that copy does not change the array.

 Rule:
 CrewSnapshot is a struct and therefore has value semantics.

 FIX:
*/

var fixedRoster = crewRoster

print("Report 1 before:", fixedRoster[0].oxygen)

for index in fixedRoster.indices {
    fixedRoster[index].oxygen -= 10
}

print("Report 1 after:", fixedRoster[0].oxygen)


/*
 REPORT 2

 Expected:
 The author expected podA to stay at charge 100.

 Actual:
 podA and podB point to the same TeleportPod object.
 Changing podB therefore also changes podA.

 Rule:
 Classes have reference semantics.

 FIX:
 Create a separate TeleportPod when an independent object
 is required.
*/

let fixedPodA = TeleportPod(id: "A", chargeLevel: 100)
let fixedPodB = TeleportPod(id: "A-copy", chargeLevel: 100)

print("Report 2 before:", fixedPodA.chargeLevel)

fixedPodB.chargeLevel = 0

print("Report 2 podA:", fixedPodA.chargeLevel)
print("Report 2 podB:", fixedPodB.chargeLevel)


/*
 REPORT 3

 Expected:
 add() should append an entry.

 Actual:
 It does not compile because Logbook is a struct and add()
 attempts to modify a stored property.

 Rule:
 A struct method that changes self or one of its properties
 must be marked mutating.

 FIX:
*/

struct Logbook {
    var entries: [String] = []

    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}

var logbook = Logbook()

print("Report 3 before:", logbook.entries)

logbook.add("Teleporter checked")

print("Report 3 after:", logbook.entries)


/*
 REPORT 4

 let snapshot = CrewSnapshot.rookie(named: "Dana")
 snapshot.oxygen = 40

 This does NOT compile.

 CrewSnapshot is a struct. `let` freezes the entire value,
 so its stored properties cannot be changed.

 let pod = TeleportPod(id: "B", chargeLevel: 50)
 pod.chargeLevel = 10

 This DOES compile.

 TeleportPod is a class. `let` freezes the reference itself,
 not the mutable properties of the referenced object.

 FIX for snapshot:
 use `var` instead of `let`.
*/

var fixedSnapshot = CrewSnapshot.rookie(named: "Dana")

print("Report 4 snapshot before:", fixedSnapshot.oxygen)

fixedSnapshot.oxygen = 40

print("Report 4 snapshot after:", fixedSnapshot.oxygen)


let reportPod = TeleportPod(id: "B", chargeLevel: 50)

print("Report 4 pod before:", reportPod.chargeLevel)

reportPod.chargeLevel = 10

print("Report 4 pod after:", reportPod.chargeLevel)


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {

    // private blocks direct access to the real stored entry list.
    private var storedEntries: [String] = []

    // public allows outside code to read the sealed state,
    // while private(set) blocks outside code from changing it.
    public private(set) var isSealed: Bool = false

    // public allows outside code to read the number of entries.
    public var entryCount: Int {
        storedEntries.count
    }

    // public allows outside code to read a formatted transcript.
    public var transcript: String {
        var result = ""

        for entry in storedEntries {
            if result.isEmpty {
                result = entry
            } else {
                result += "\n\(entry)"
            }
        }

        return result
    }

    // public allows outside code to request a new entry.
    public func add(_ entry: String) {
        guard !isSealed else {
            return
        }

        storedEntries.append(entry)
    }

    // public allows outside code to permanently seal the recorder.
    public func seal() {
        isSealed = true
    }

    // fileprivate allows the free audit function in this file
    // to read the internal stored entries.
    fileprivate func entriesForAudit() -> [String] {
        storedEntries
    }
}


// A free function using the fileprivate helper.
func auditTranscript(of recorder: FlightRecorder) -> String {
    let entries = recorder.entriesForAudit()

    var result = "AUDIT"

    for entry in entries {
        result += "\n\(entry)"
    }

    return result
}


print("\n--- LEVEL 7: FLIGHT RECORDER ---")

let recorder = FlightRecorder()

print("Initial entry count:", recorder.entryCount)

recorder.add("ALMA-7 recorder started")
recorder.add("Teleport system checked")

print("Entry count:", recorder.entryCount)
print("Transcript:")
print(recorder.transcript)

recorder.seal()

print("Recorder sealed:", recorder.isSealed)

recorder.add("This must not be added")

print("Entry count after sealed add:", recorder.entryCount)

print(auditTranscript(of: recorder))

/*
 These attempts correctly fail to compile:

 recorder.isSealed = false
 Error: Cannot assign to property: 'isSealed' setter is inaccessible

 recorder.storedEntries.removeAll()
 Error: 'storedEntries' is inaccessible due to 'private'
*/


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue

let integrityCode = "\(A)-\(B)-\(C)-\(D)"

print("\n==============================")
print("INTEGRITY CODE: \(integrityCode)")
print("==============================")


/*
 MARK: - ================= DEFENSE QUESTIONS =================

 1. Why did CrewSnapshot get an initializer for free while
    TeleportPod did not?

 CrewSnapshot is a struct. Swift automatically creates a
 memberwise initializer for its stored properties.
 TeleportPod is a class, so I wrote its initializer myself.


 2. What does `mutating` do to self, and why do classes never
    need it?

 A struct is a value type. A mutating method is allowed to
 change its properties or replace self with a new value.
 Classes are reference types, so their methods can change
 mutable properties without the mutating keyword.


 3. In Report 4 both values are `let`. What exactly does `let`
    freeze for a struct, and what does it freeze for a class?

 For a struct, let makes the whole value immutable, so its
 variable properties cannot be changed.

 For a class, let makes the reference constant. The variable
 cannot point to another object, but mutable properties of the
 object can still change.


 4. Why must a lazy property be var? When does lazy change
    behaviour, not just performance?

 A lazy property does not receive its value until its first
 access. Because its value is assigned after initialization,
 it must be var.

 In this lab fullDiagnostics prints "Running full scan..."
 when it is created. If the property is never accessed, that
 code never runs. Therefore lazy changes program behaviour,
 not only performance.


 5. private vs fileprivate: where in FlightRecorder would
    private be too strict?

 storedEntries should be private because outside code must not
 change the history.

 The entriesForAudit() helper is fileprivate because
 auditTranscript(of:) is a free function outside the class
 but in the same Swift file. If that helper were private,
 the free function could not use it.
*/
