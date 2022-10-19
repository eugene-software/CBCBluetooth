# CBCBluetooth

[![Version](https://img.shields.io/cocoapods/v/CBCBluetooth.svg?style=flat-square)](https://cocoapods.org/pods/CBCBluetooth)
[![License](https://img.shields.io/cocoapods/l/CBCBluetooth.svg?style=flat-square)](https://cocoapods.org/pods/CBCBluetooth)
[![Platform](https://img.shields.io/cocoapods/p/CBCBluetooth.svg?style=flat-square)](https://cocoapods.org/pods/CBCBluetooth)

## Requirements 

- iOS 13 and above

## Usage Example

Import dependenices:

```swift
import Combine
import CoreBluetooth
import CBCBluetooth
```

- Scanning and receiving single value from public services:

```swift

let manager = CBCCentralManagerFactory.create()

let service = "SOME-SERVICE-UUID-STRING"
let characteristic = "SOME-CHARACTERISTIC-UUID-STRING"

manager.startScan(with: [service])
    .flatMap {
        $0.discoverServices(with: [service])
    }
    .flatMap {
        $0.discoverCharacteristics(with: [characteristic])
    }
    .flatMap {
        $0.readValue()
    }
    .sink { completion in
        print(completion)
    } receiveValue: { response in
        print(response.data)
    }
    .store(in: &cancellables)
```

- Connecting to particular peripheral by UUID:

```swift
let manager = CBCCentralManagerFactory.create()
let peripheralUUID = UUID(uuidString: "SOME-PERIPHERAL-UUID-STRING")!

manager.getPeripherals(with: [peripheralUUID])
    .first()
    .flatMap {
        $0.connect()
    }
    .sink { completion in
        print(completion)
    } receiveValue: { peripheral in
        print(peripheral)
    }
    .store(in: &cancellables)
```

- Observe RSSI:

```swift
let manager = CBCCentralManagerFactory.create()
let peripheralUUID = UUID(uuidString: "SOME-PERIPHERAL-UUID-STRING")!

manager.getPeripherals(with: [peripheralUUID])
    .first()
    .flatMap {
        $0.connect()
    }
    .flatMap {
        $0.observeRSSI()
    }
    .sink { completion in
        print(completion)
    } receiveValue: { rssi in
        print(rssi)
    }
    .store(in: &cancellables)
```

## Installation

### Cocoapods
CBCBluetooth is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CBCBluetooth'
```

### Swift Package Manager
1. Right click in the Project Navigator
2. Select "Add Packages..."
3. Search for ```https://github.com/eugene-software/CBCBluetooth.git```

## Author

Eugene Software

## License

CBCBluetooth is available under the MIT license. See the LICENSE file for more info.
