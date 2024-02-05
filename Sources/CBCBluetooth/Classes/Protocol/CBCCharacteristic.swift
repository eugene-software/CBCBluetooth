//
//  Characteristic.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation
import Combine

/// A Bluetooth characteristic object that could be only related to particular service and cannot exist on it's own.
///
public protocol CBCCharacteristic {
    
    /// Unique UUID string of characteristic
    ///
    var identifier: UUID { get }
    
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
