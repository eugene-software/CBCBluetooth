//
//  CoreBluetoothPeripheralDelegate.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//
//  Copyright (c) 2022 Eugene Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
