//
//  CBCCharacteristic.swift
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
import Combine

/// A Bluetooth characteristic object that could be only related to particular service and cannot exist on it's own.
///
public protocol CBCCharacteristic {
    
    /// Unique ID string of characteristic
    ///
    var identifier: String { get }
    
    /// Send a request to read value regardless `setNotifyValue` setting
    /// - Parameters:
    /// - Returns: Publisher that passes found `CBCCharacteristicData`
    ///
    func readValue() -> AnyPublisher<CBCCharacteristicData, CBCError>
    
    /// Unlike `readValue()` Send a request to set notify value by using `setNotifyValue` of CBPeripheral.
    /// Instantly receives a value if it exist.
    /// - Returns: Publisher that passes found `CBCCharacteristicData`
    ///
    func observeValue() -> AnyPublisher<CBCCharacteristicData, CBCError>
    
    /// Starts observing of `notifyValue` parameter of particular characteristic
    /// - Returns: Publisher that passes `CBCPeripheral`
    ///
    func observeNotificationState() -> AnyPublisher<CBCPeripheral, CBCError>
    
    /// Instantly write a data to particular characteristic.
    /// - Parameters:
    ///   - data: Data value to be written to characteristic
    /// - Returns: empty Publisher
    ///
    func writeValue(_ data: Data) -> AnyPublisher<Never, CBCError>
}
