//  Proyecto Integrador Swift
//  AlkeParking

// Exercise 1
// "Set" is used because each car is unique in our code, they cannot be repeated.
// Exercise 2
// 2) You cannot change the vehicle type over time, it must be set as constant.
// 3) Switch.
// Exercise 3
// It must be added in both places. In the protocol, configure whether the property can be obtained or modified. Automatically in the class that contains the protocol, it is necessary to add these properties.
// It is a variable of optional type.
// Exercise 4
// Computed properties.
// Exercise 7
// It must be converted to a function that mutates.
// Exercise 10
// It must be verified that the property is not null

import Foundation

protocol Parkable {
    var plate: String { get }
    var type: VehicleType { get }
    var checkInTime: Date { get set }
    var discountCard: String? { get set }
    var parkedTime: Int { get } // Minutes
}

struct Parking {
    var vehicles: Set<Vehicle> = []
    let maxVehicles: Int = 20
    var totalProfit: (amounts: Int,profit: Int) = (0,0)

    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish: (Bool) -> Void) {
        guard vehicles.count < maxVehicles && !vehicles.contains(vehicle) else {
            onFinish(false)
            return
        }
        vehicles.insert(vehicle)
        onFinish(true)
    }
    
    mutating func checkOutVehicle(_ plate: String?,
                         onSuccess: (Int)->Void,
                         onError: ()->Void) {
        guard let vehicle = vehicles.first( where: { $0.plate == plate }) else {
            onError()
            return
        }
        vehicles.remove(vehicle)
        let fee = calculateFee(vehicle.type, vehicle.parkedTime, hasDiscountCard: (vehicle.discountCard != nil))
        totalProfit.profit += fee
        totalProfit.amounts += 1
        onSuccess(fee)
    }
    
    func showTotalProfit() {
        print("\(totalProfit.amounts) vehicles have checked out and have earnings of $\(totalProfit.profit)")
    }
    
    func listVehicles() {
        vehicles.forEach { vehicle in
            print("Plate: \(vehicle.plate ?? "")")
        }
    }
}

extension Parking {
    func calculateFee(_ type: VehicleType,_ parkedTime: Int, hasDiscountCard: Bool) -> Int {
        let firstTwoHours: Int = 120
        var fee: Int = 0
        if parkedTime > firstTwoHours {
            let diff: Double = Double(parkedTime-firstTwoHours)
            fee = type.parkingValue + Int(ceil(diff/15.0)) * 5
        } else {
            fee = type.parkingValue
        }
        if hasDiscountCard {
            fee -= Int(Double(fee) * 0.15)
        }
        return fee
    }
}

struct Vehicle: Parkable, Hashable {
    let plate: String
    let type: VehicleType
    var checkInTime: Date
    var discountCard: String?
    var parkedTime: Int {
        get {
            return Calendar.current.dateComponents([.minute], from: checkInTime, to: Date()).minute ?? 0
        }
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
    static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.plate == rhs.plate
    }
}

enum VehicleType {
    case car, motorcycle, minibus, bus
    var parkingValue: Int {
        switch self {
        case .car:
            return 20
        case .motorcycle:
            return 15
        case .minibus:
            return 25
        case .bus:
            return 30
        }
    }
}

//  Instance
var alkeParking = Parking()
//  Tests
let vehicles = [ Vehicle(plate: "AA111AA", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_001"),
                 Vehicle(plate: "B222BBB", type: VehicleType.motorcycle, checkInTime: Date(), discountCard: nil),
                 Vehicle(plate: "CC333CC", type: VehicleType.minibus, checkInTime: Date(), discountCard: nil),
                 Vehicle(plate: "DD444DD", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_002"),
                 Vehicle(plate: "AA111BB", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_003"),
                 Vehicle(plate: "B222CCC", type: VehicleType.motorcycle, checkInTime: Date(), discountCard: "DISCOUNT_CARD_004"),
                 Vehicle(plate: "CC333DD", type: VehicleType.minibus, checkInTime: Date(), discountCard: nil),
                 Vehicle(plate: "DD444EE", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_005"),
                 Vehicle(plate: "AA111CC", type: VehicleType.car, checkInTime: Date(), discountCard: nil),
                 Vehicle(plate: "B222DDD", type: VehicleType.motorcycle, checkInTime: Date(), discountCard: nil),
                 Vehicle(plate: "CC333EE", type: VehicleType.minibus, checkInTime: Date(), discountCard: nil),
                 Vehicle(plate: "DD444GG", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_006"),
                 Vehicle(plate: "AA111DD", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_007"),
                 Vehicle(plate: "B222EEE", type: VehicleType.motorcycle, checkInTime: Date(), discountCard: nil),
                 Vehicle(plate: "CC333FF", type: VehicleType.minibus, checkInTime: Date(), discountCard: nil),
                 Vehicle(plate: "AA211AA", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_001"),
                 Vehicle(plate: "B232BBB", type: VehicleType.motorcycle, checkInTime: Date(), discountCard: nil),
                 Vehicle(plate: "CC433CC", type: VehicleType.car, checkInTime: Date(), discountCard: nil),
                 Vehicle(plate: "AA511BB", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_003"),
                 Vehicle(plate: "AA511BB", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_003"), // Repeat
                 Vehicle(plate: "AE511BB", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_003"),
                 Vehicle(plate: "ZA511BB", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_003")] // Nº 21
//  Adding vehicles to the parking, 20 correct, 1 repeated and 1 discarded because the parking is full.
vehicles.forEach { vehicle in
    alkeParking.checkInVehicle(vehicle) { result in
print(result ? "Welcome to AlkeParking!" : "Sorry, the check-in failed")
    }
}
//  One CheckOut
alkeParking.checkOutVehicle("CC433CC") { result in
    print("Your fee is $\(result). Come back soon!!")
    } onError: {
        print("Sorry, the check-out failed")
    }
//  Showing total profits
alkeParking.showTotalProfit()
//  Showing the list of the car plates
alkeParking.listVehicles()
