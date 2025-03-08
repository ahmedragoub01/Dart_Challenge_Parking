import 'dart:io';
import 'dart:collection';

enum VehicleType { Car, Motorcycle, Truck }

class Vehicle {
  String plateNumber;
  VehicleType type;
  DateTime entryTime;

  Vehicle(this.plateNumber, this.type, this.entryTime);
}

class ParkingTicket {
  String id;
  Vehicle vehicle;
  DateTime exitTime;
  double fee;

  ParkingTicket(this.id, this.vehicle, this.exitTime, this.fee);
}

class ParkingLot {
  final int capacity;
  final List<Vehicle?> slots;
  final List<ParkingTicket> completedTickets = [];
  final Queue<String> logs = Queue();

  ParkingLot(this.capacity) : slots = List.filled(capacity, null);

  bool isFull() => slots.every((slot) => slot != null);
  bool isEmpty() => slots.every((slot) => slot == null);
  
  int getAvailableSlots() => slots.where((slot) => slot == null).length;

  void logEvent(String message) {
    String timestamp = DateTime.now().toString();
    logs.add("[$timestamp] $message");
    if (logs.length > 10) logs.removeFirst();
  }

  int? parkVehicle(Vehicle vehicle) {
    for (int i = 0; i < slots.length; i++) {
      if (slots[i] == null) {
        slots[i] = vehicle;
        logEvent("🚗 Vehicle ${vehicle.plateNumber} parked at slot ${i + 1}");
        return i;
      }
    }
    return null;
  }

  ParkingTicket? retrieveVehicle(String plateNumber) {
    for (int i = 0; i < slots.length; i++) {
      if (slots[i]?.plateNumber == plateNumber) {
        Vehicle vehicle = slots[i]!;
        slots[i] = null;
        DateTime exitTime = DateTime.now();
        double fee = calculateFee(vehicle.entryTime, exitTime, vehicle.type);
        ParkingTicket ticket = ParkingTicket("T${exitTime.millisecondsSinceEpoch}", vehicle, exitTime, fee);
        completedTickets.add(ticket);
        logEvent("✅ Vehicle ${vehicle.plateNumber} exited. Fee: \$$fee");
        return ticket;
      }
    }
    return null;
  }

  double calculateFee(DateTime entry, DateTime exit, VehicleType type) {
    double baseRate = type == VehicleType.Car ? 10.0 : (type == VehicleType.Motorcycle ? 5.0 : 15.0);
    int hours = exit.difference(entry).inHours + 1;
    return baseRate * hours;
  }

  void showParkingStatus() {
    print("\n=== 🅿️ PARKING STATUS ===");
    for (int i = 0; i < slots.length; i++) {
      print("Slot ${i + 1}: ${slots[i] == null ? "✅ AVAILABLE" : "🚗 ${slots[i]!.plateNumber}"}");
    }
    print("\nTotal Available Slots: ${getAvailableSlots()}/${capacity}\n");
  }

  void showTransactionLog() {
    print("\n=== 📜 TRANSACTION LOG ===");
    logs.forEach(print);
    print("\n=== 🧾 COMPLETED TICKETS ===");
    for (var ticket in completedTickets) {
      print(
          "Ticket ID: ${ticket.id}\nVehicle: ${ticket.vehicle.type} - ${ticket.vehicle.plateNumber}\nEntry: ${ticket.vehicle.entryTime}\nExit: ${ticket.exitTime}\nFee: \$${ticket.fee}\n-------------------");
    }
  }
}

void main() {
  ParkingLot parkingLot = ParkingLot(10);
  parkingLot.logEvent("🚀 Smart Parking System started");

  while (true) {
    print("\n🚗 Welcome to Smart Parking System! 🚗");
    print("=== SMART PARKING SYSTEM MENU ===");
    print("1. Park a vehicle");
    print("2. Check available slots");
    print("3. Retrieve a parked vehicle");
    print("4. View transaction log");
    print("5. Exit");
    stdout.write("Select an option: ");
    
    String? choice = stdin.readLineSync();
    
    switch (choice) {
      case "1":
        stdout.write("\nEnter vehicle plate number: ");
        String? plateNumber = stdin.readLineSync();
        print("Select vehicle type:\n1. Car\n2. Motorcycle\n3. Truck");
        stdout.write("Enter type (1/2/3): ");
        String? typeChoice = stdin.readLineSync();

        if (plateNumber == null || plateNumber.isEmpty || typeChoice == null) {
          print("Invalid input! Try again.");
          break;
        }

        VehicleType? type;
        switch (typeChoice) {
          case "1":
            type = VehicleType.Car;
            break;
          case "2":
            type = VehicleType.Motorcycle;
            break;
          case "3":
            type = VehicleType.Truck;
            break;
          default:
            print("Invalid vehicle type! Try again.");
            break;
        }

        if (type != null) {
          Vehicle vehicle = Vehicle(plateNumber, type, DateTime.now());
          int? slot = parkingLot.parkVehicle(vehicle);
          if (slot != null) {
            print("✅ Vehicle parked successfully! Slot Number: ${slot + 1}");
          } else {
            print("❌ Parking lot is full!");
          }
        }
        break;

      case "2":
        parkingLot.showParkingStatus();
        break;

      case "3":
        stdout.write("\nEnter vehicle plate number: ");
        String? exitPlateNumber = stdin.readLineSync();
        if (exitPlateNumber == null || exitPlateNumber.isEmpty) {
          print("Invalid input! Try again.");
          break;
        }

        ParkingTicket? ticket = parkingLot.retrieveVehicle(exitPlateNumber);
        if (ticket != null) {
          print("\n✅ Vehicle retrieved successfully!");
          print("==== 🧾 PARKING RECEIPT ====");
          print("Ticket ID: ${ticket.id}");
          print("Vehicle: ${ticket.vehicle.type} - ${ticket.vehicle.plateNumber}");
          print("Entry Time: ${ticket.vehicle.entryTime}");
          print("Exit Time: ${ticket.exitTime}");
          print("Total Fee: \$${ticket.fee}");
          print("=========================");
        } else {
          print("❌ Vehicle not found!");
        }
        break;

      case "4":
        parkingLot.showTransactionLog();
        break;

      case "5":
        print("\nThank you for using Smart Parking System! Goodbye! 👋");
        return;

      default:
        print("\n❌ Invalid option! Please select a valid choice.");
    }
  }
}
