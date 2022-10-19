//
//  CoreBluetoothPeripheralDelegate.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

final class CoreBluetoothPeripheralDelegate: NSObject {

    struct ReadRSSIEvent {
        let peripheral: CBPeripheral
        let rssi: NSNumber
        let error: Error?
    }
    
    struct CharacteristicValueEvent {
        let peripheral: CBPeripheral
        let characteristic: CBCharacteristic
        let error: Error?
    }
    
    struct ServiceCharacteristicsDiscoverEvent {
        let peripheral: CBPeripheral
        let service: CBService
        let error: Error?
    }
    
    struct DiscoverServicesEvent {
        let peripheral: CBPeripheral
        let error: Error?
    }
    
    let discoverServices: PassthroughSubject<DiscoverServicesEvent, Error> = PassthroughSubject()
    let discoverCharacteristicsForService: PassthroughSubject<ServiceCharacteristicsDiscoverEvent, Error> = PassthroughSubject()
    let readRSSI: PassthroughSubject<ReadRSSIEvent, Error> = .init()
    let writeValueForCharacteristic: PassthroughSubject<CharacteristicValueEvent, Error> = PassthroughSubject()
    let updateValueForCharacteristic: PassthroughSubject<CharacteristicValueEvent, Error> = PassthroughSubject()
    let updateNotificationStateForCharacteristic: PassthroughSubject<CharacteristicValueEvent, Error> = PassthroughSubject()
}

extension CoreBluetoothPeripheralDelegate: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        readRSSI.send(.init(peripheral: peripheral, rssi: RSSI, error: error))
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        discoverServices.send(.init(peripheral: peripheral, error: error))
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        discoverCharacteristicsForService.send(.init(peripheral: peripheral, service: service, error: error))
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        updateValueForCharacteristic.send(.init(peripheral: peripheral, characteristic: characteristic, error: error))
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        writeValueForCharacteristic.send(.init(peripheral: peripheral, characteristic: characteristic, error: error))
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        updateNotificationStateForCharacteristic.send(.init(peripheral: peripheral, characteristic: characteristic, error: error))
    }
}
