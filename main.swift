// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

/// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, text) = splitOnce(raw, by: ":"),
          !sensor.isEmpty,
          let value = Int(text),
          value >= 0 || sensor == "TEMP"
    else {
        return nil
    }

    return (sensor: sensor, value: value)
}

// Tests
print(parseReading("O2:87") as Any)
print(parseReading("TEMP:-12") as Any)
print(parseReading("RAD:-1") as Any)
print(parseReading(":55") as Any)


// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0

    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }

    return (valid, invalidCount)
}

// Tests
let logResult = parseLog(rawLog)

print("Valid readings:", logResult.valid)
print("Invalid count:", logResult.invalidCount)

let A = logResult.invalidCount
print("A =", A)


// MARK: Level 2 · Analysis

// 2.1
func select(
    _ readings: [Reading],
    where isIncluded: (Reading) -> Bool
) -> [Reading] {

    var result: [Reading] = []

    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }

    return result
}


func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []

    for reading in readings {
        result.append(reading.value)
    }

    return result
}


// Get all O2 readings using trailing closure and $0
let o2Readings = select(logResult.valid) {
    $0.sensor == "O2"
}

let o2Values = values(of: o2Readings)

print("O2 readings:", o2Readings)
print("O2 values:", o2Values)

// Extra tests
let tempReadings = select(logResult.valid) {
    $0.sensor == "TEMP"
}

print("TEMP readings:", tempReadings)


// 2.2
func stats(of values: [Int])
    -> (min: Int, max: Int, average: Double)? {

    guard let first = values.first else {
        return nil
    }

    var minimum = first
    var maximum = first
    var total = 0

    for value in values {
        if value < minimum {
            minimum = value
        }

        if value > maximum {
            maximum = value
        }

        total += value
    }

    let average = Double(total) / Double(values.count)

    return (
        min: minimum,
        max: maximum,
        average: average
    )
}


func stats(_ values: Int...)
    -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}


// Tests
print("Stats 3,8,1:", stats(3, 8, 1) as Any)
print("Empty stats:", stats() as Any)

let o2Stats = stats(of: o2Values)

let B = Int(o2Stats?.average ?? 0)

print("B =", B)


// 2.3 · The Closure Ladder

// 1. Full closure syntax
let sorted1 = logResult.valid.sorted(
    by: { (a: Reading, b: Reading) -> Bool in
        return a.value > b.value
    }
)

// 2. Types inferred
let sorted2 = logResult.valid.sorted(
    by: { a, b in
        return a.value > b.value
    }
)

// 3. Implicit return
let sorted3 = logResult.valid.sorted(
    by: { a, b in
        a.value > b.value
    }
)

// 4. Shorthand arguments
let sorted4 = logResult.valid.sorted(
    by: {
        $0.value > $1.value
    }
)

// 5. Trailing closure
let sorted5 = logResult.valid.sorted {
    $0.value > $1.value
}


// Reading is a tuple, so compare the values manually.
func sameReadings(_ a: [Reading], _ b: [Reading]) -> Bool {
    guard a.count == b.count else {
        return false
    }

    for index in 0..<a.count {
        if a[index].sensor != b[index].sensor ||
            a[index].value != b[index].value {
            return false
        }
    }

    return true
}

let allSortsMatch =
    sameReadings(sorted1, sorted2) &&
    sameReadings(sorted2, sorted3) &&
    sameReadings(sorted3, sorted4) &&
    sameReadings(sorted4, sorted5)

print("All sorts match:", allSortsMatch)


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int {
    t + 5
}

func coolDown(_ t: Int) -> Int {
    t - 3
}

func hold(_ t: Int) -> Int {
    t
}


func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}


// Tests
print("Heat:", heatUp(10))
print("Cool:", coolDown(30))
print("Hold:", hold(20))

print("Protocol for 10:", chooseProtocol(for: 10)(10))
print("Protocol for 30:", chooseProtocol(for: 30)(30))


// 3.2
func runUntilStable(
    from start: Int,
    maxSteps: Int = 10
) -> (finalTemp: Int, steps: Int, isStable: Bool) {

    var temperature = start
    var steps = 0

    while (temperature < 18 || temperature > 24)
            && steps < maxSteps {

        let protocolFunction = chooseProtocol(for: temperature)

        temperature = protocolFunction(temperature)
        steps += 1
    }

    let stable = temperature >= 18 && temperature <= 24

    return (
        finalTemp: temperature,
        steps: steps,
        isStable: stable
    )
}


// Tests
print("Stable from 31:", runUntilStable(from: 31))
print(
    "Stable from -100:",
    runUntilStable(from: -100, maxSteps: 5)
)


// Find TEMP readings using our select function
let temperatureReadings = select(logResult.valid) {
    $0.sensor == "TEMP"
}

let temperatureValues = values(of: temperatureReadings)

let temperatureStats = stats(of: temperatureValues)

var C = 0

if let lowestTemperature = temperatureStats?.min {
    C = runUntilStable(from: lowestTemperature).steps
}

print("C =", C)


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}


// Tests
print("Timur oxygen:", oxygenLevel(of: crew[0]) as Any)
print("Dana oxygen:", oxygenLevel(of: crew[1]) as Any)


// 4.2
func status(of member: CrewMember) -> String {

    guard let level = oxygenLevel(of: member) else {
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }

    if level < 20 {
        return "\(member.name): \(level)% CRITICAL"
    } else {
        return "\(member.name): \(level)% OK"
    }
}


// Print status of whole crew
for member in crew {
    print(status(of: member))
}


// Extra tests
print(status(of: crew[0]))
print(status(of: crew[2]))


// 4.3
@discardableResult
func transferOxygen(
    from source: inout Int,
    to target: inout Int,
    amount: Int
) -> Int {

    if amount < 0 {
        return 0
    }

    let available = source
    let freeSpace = 100 - target

    var transferred = amount

    if transferred > available {
        transferred = available
    }

    if transferred > freeSpace {
        transferred = freeSpace
    }

    source -= transferred
    target += transferred

    return transferred
}


// Simple tests
var testSource = 50
var testTarget = 80

print(
    "Transferred:",
    transferOxygen(
        from: &testSource,
        to: &testTarget,
        amount: 30
    )
)

print(
    "After test:",
    testSource,
    testTarget
)


// Transfer 30 from Lab to Hab WITHOUT force unwrap
if let labTank = lab.oxygenTank,
   let habTank = hab.oxygenTank {

    let transferred = transferOxygen(
        from: &labTank.level,
        to: &habTank.level,
        amount: 30
    )

    print("Lab -> Hab transferred:", transferred)
}

let D = hab.oxygenTank?.level ?? 0

print("D =", D)


// 4.4
func evacuationOrder(
    _ names: String...,
    roster: [String: CrewMember]
) -> [String] {

    var found: [CrewMember] = []

    for name in names {

        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }

        found.append(member)
    }

    found.sort {
        $0.priority < $1.priority
    }

    var result: [String] = []

    for member in found {
        result.append(member.name)
    }

    return result
}


// Tests
let order1 = evacuationOrder(
    "Dana",
    "Ghost",
    "Aigerim",
    "Timur",
    roster: roster
)

print("Evacuation:", order1)

let order2 = evacuationOrder(
    "Nurlan",
    "Timur",
    roster: roster
)

print("Evacuation 2:", order2)


// MARK: Level 5 · The Saboteur's Logbook

/*
 ORIGINAL PROBLEM 1:

 let tank = member.module!.oxygenTank!

 If member.module is nil (for example Nurlan),
 the program crashes.

 If the member has a module but oxygenTank is nil
 (for example Dana in Dock), the program also crashes.
*/


func reportOxygen(for member: CrewMember) -> String {

    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no oxygen data"
    }

    return "\(member.name): \(level)%"
}


/*
 ORIGINAL PROBLEM 2:

 if oxygenLevel(of: member)! < 20

 oxygenLevel can return nil.
 For Dana or Nurlan this would crash.


 ORIGINAL PROBLEM 3:

 result starts as nil.

 If nobody is critical, return result!
 would crash.


 LOGIC BUG:

 The loop does not stop after finding the first
 critical crew member.

 It keeps searching and replaces result.

 Therefore it actually returns the LAST critical
 member, not the FIRST one.
*/


func firstCritical(in crew: [CrewMember]) -> String? {

    for member in crew {

        if let level = oxygenLevel(of: member),
           level < 20 {

            return member.name
        }
    }

    return nil
}


// Tests
print("Timur report:", reportOxygen(for: crew[0]))
print("Dana report:", reportOxygen(for: crew[1]))

print("First critical:", firstCritical(in: crew) as Any)


// Test proving the logic bug is fixed.
// Two critical members: the function must return the FIRST.
let testModule1 = Module(
    name: "Test1",
    oxygenTank: Tank(level: 10)
)

let testModule2 = Module(
    name: "Test2",
    oxygenTank: Tank(level: 5)
)

let firstPerson = CrewMember(
    name: "First",
    role: "Test",
    priority: 1,
    module: testModule1
)

let secondPerson = CrewMember(
    name: "Second",
    role: "Test",
    priority: 2,
    module: testModule2
)

let criticalTest = [firstPerson, secondPerson]

print(
    "Logic bug test:",
    firstCritical(in: criticalTest) as Any
)


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"

print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {

    var count = 0

    return { oxygenLevel in

        if oxygenLevel < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }

        return false
    }
}


let alarm = makeAlarm(threshold: 20)

print(alarm(12))
print(alarm(40))
print(alarm(5))


// MARK: - ================= DEFENSE QUESTIONS =================

/*

1. guard let vs if let beyond syntax:

guard let is useful when the function cannot continue
without a value. It handles the bad case first and exits.

Example:

guard let value = Int(text) else {
    return nil
}

After guard, value can be used in the rest of the function.

With if let, more code would have to be placed inside
the if block, which can create unnecessary nesting.


2. Why can't you pass [Int] to stats(_ values: Int...)?

Int... is a variadic parameter.
The function expects separate Int arguments, for example:

stats(3, 8, 1)

An [Int] is one array value, not separate Int arguments.

For an array we use:

stats(of: someArray)


3. Why doesn't
transferOxygen(from: &x, to: &x, amount: 5)
compile?

Both inout parameters would try to modify the same
variable at the same time.

Swift prevents overlapping access to the same memory.
This prevents conflicting changes to x.


4. Why doesn't
oxygenLevel(of: dana) ?? "no data"
compile?

oxygenLevel returns Int?.

The left side of ?? contains an Int, but "no data"
is a String.

The types do not match.

For example, this works:

oxygenLevel(of: member) ?? 0


5. Full type of chooseProtocol and how to read it:

(Int) -> ((Int) -> Int)

It means chooseProtocol receives an Int
and returns another function.

The returned function receives an Int
and returns an Int.


Bonus. Where does the alarm counter live after
makeAlarm returns?

The returned closure captures the count variable.

The captured variable continues to exist with the closure
even after makeAlarm has finished.

That is why the first alarm prints Alarm #1
and the next triggered alarm prints Alarm #2.

*/
