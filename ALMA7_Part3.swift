// =============================================================
// Station ALMA-7, Part III: The Repair Fleet
// iOS Mobile Development · Module 5 · Lab Assignment
// =============================================================

// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================
// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Power Cell

// A class gives PowerCell reference semantics, so a shared cell is one mutable object.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = max(0, min(100, charge))
    }

    func level() -> Int { charge }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, charge >= amount else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(100, charge + amount)
    }
}

// Encapsulation proof: leave the attempted direct access commented out.
// let cell = PowerCell(charge: 50)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level

// MARK: Level 2 · The Fleet

class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }
    var statusLine: String { "\(id): \(cell.level())% \(cell.level().powerBar)" }
    func performTask() -> Int { 0 }

    // final keeps the common spend-first procedure unchanged in every subclass.
    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id): seam welded" }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder": return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo": return CargoDrone(id: id, cell: cell)
    default: return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Warning: unknown drone kind '\(record.kind)' for \(record.id); skipped.")
    }
}

// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    guard rounds > 0 else { return total }
    for _ in 0..<rounds {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)
var B = 0
var C = 0
for drone in fleet {
    print(drone.statusLine)
    B += drone.cell.level()
    if drone.cell.level() >= drone.powerCost { C += 1 }
}
print("Drones ready for another task: \(C)")

// MARK: Level 4 · Diagnostics

protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// A class uses reference semantics, so this method does not need `mutating`.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { Self.healthCode(for: cell.level()) }
    func recharge(by amount: Int) { cell.recharge(by: amount) }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { Self.healthCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(100, chargeLevel + amount)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

// [Drone] cannot hold sensors because SensorModule is a struct, not a Drone subclass.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components {
        lines.append(component.diagnose())
    }
    return lines.joined(separator: "\n")
}

var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }
print("Diagnostics before beacon:\n\(diagnosticsReport(components))")

// MARK: Level 5 · Shared Behaviour

extension Diagnosable {
    func diagnose() -> String { "\(componentID): code \(statusCode)" }

    // The Health Rule is implemented exactly once here.
    static func healthCode(for charge: Int) -> Int {
        if charge < 20 { return 2 }
        if charge < 50 { return 1 }
        return 0
    }
}

extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { Self.healthCode(for: signalStrength) }
    func diagnose() -> String { "LEGACY BEACON \(componentID): code \(statusCode)" }
}

components.append(beacon)
print("Diagnostics with beacon:\n\(diagnosticsReport(components))")

var D = 0
for component in components { D += component.statusCode }

extension Int {
    var powerBar: String {
        let bars = Swift.max(0, Swift.min(10, self / 10))
        return String(repeating: "#", count: bars)
            + String(repeating: ".", count: 10 - bars)
    }
}

// MARK: Level 6 · Incident Reports

/*
Report 1 — Does not compile:
Expected: PatchDrone performs 30 units of work.
Actual: Swift reports that performTask() requires the override keyword.
Rule: a subclass method matching an overridable superclass method must use `override`.
Fix: override func performTask() -> Int { 30 }

Report 2 — Does not compile:
Expected: HeavyWelder changes runOnce() to return 999.
Actual: WelderDrone is final and cannot be subclassed; runOnce() is also final.
Rule: `final` prevents subclassing or overriding.
Fix: create a separate Drone subclass, override performTask() and powerCost,
and let inherited final runOnce() handle spending energy.

Report 3 — Does not compile:
Expected: first.weldSeam() works because the object is a WelderDrone.
Actual: first is statically typed as Drone, which has no weldSeam() method.
Rule: subclass-only methods are not available through a superclass reference.
Fix:
if let welder = first as? WelderDrone { print(welder.weldSeam()) }
`as?` is optional because the object might not be a WelderDrone.

Report 4 — Compiles, but prints the wrong label:
Expected: "thruster T-1".
Actual: "generic component".
Rule: a method provided only in a protocol extension uses static dispatch
when called through a protocol-typed value.
Fix: add `func label() -> String` to the Labelled protocol requirements,
so the conforming Thruster implementation is dynamically dispatched.
*/

// MARK: Finale · Mission Code
let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")

// MARK: Bonus
/*
One runtime guard: Drone.init could call precondition(type(of: self) != Drone.self).
One compile-time design: expose only concrete drone initializers, keep the
base implementation private inside a module, or use a protocol instead.
A protocol-based design makes WelderDrone a struct conforming to DroneProtocol,
with shared default methods in an extension. Protocols are more flexible across
value and reference types; a class hierarchy is useful for shared reference state.
*/

// MARK: - ================= DEFENSE QUESTIONS =================
/*
1. A class has reference semantics: its methods can change instance state
   without `mutating`. A struct has value semantics and must mark a method
   `mutating` when it changes stored properties.

2. Inheritance shares stored properties and an initializer from a base class.
   Protocols can unite unrelated classes and structs under one interface.

3. `final` prevents overriding a method or inheriting from a final class.
   On runOnce(), it prevents subclasses from skipping the battery check.

4. `label()` is defined only in the protocol extension, not required by
   Labelled. A protocol-typed value therefore calls the extension's method.
   Adding label() as a protocol requirement uses the Thruster implementation.
*/
