//
//  CoreBluetoothCharacteristic.swift
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

struct CoreBluetoothCharacteristic: CBCCharacteristic {
    
    var identifier: String
    
    private let characteristic: CBCharacteristic
    private let peripheral: CoreBluetoothPeripheral
    
    init(characteristic: CBCharacteristic, peripheral: CoreBluetoothPeripheral) {
        self.characteristic = characteristic
        self.peripheral = peripheral
        self.identifier = characteristic.uuid.uuidString
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
