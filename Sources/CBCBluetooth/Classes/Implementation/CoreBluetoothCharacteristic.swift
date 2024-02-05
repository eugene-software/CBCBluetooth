//
//  CoreBluetoothCharacteristic.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

struct CoreBluetoothCharacteristic: CBCCharacteristic {
    
    var identifier: UUID
    
    private let characteristic: CBCharacteristic
    private let peripheral: CoreBluetoothPeripheral
    
    init(characteristic: CBCharacteristic, peripheral: CoreBluetoothPeripheral) {
        self.characteristic = characteristic
        self.peripheral = peripheral
        self.identifier = UUID(uuidString: characteristic.uuid.uuidString)!
    }
    
    func readValue() -> AnyPublisher<CBCCharacteristicData, CBCError> {
        return peripheral.readValue(for: characteristic)
    }
    
    func observeValue() -> AnyPublisher<CBCCharacteristicData, CBCError> {
        return peripheral.observeValue(for: characteristic)
    }
    
    func observeNotificationState() -> AnyPublisher<CBCPeripheral, CBCError> {
        return peripheral.observeNotificationState(for: characteristic)
    }
    
    func writeValue(_ data: Data) -> AnyPublisher<Never, CBCError> {
        return peripheral.write(data: data, for: self.characteristic, type: .withResponse)
    }
}
