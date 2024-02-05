//
//  Peripheral.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation
import Combine

public protocol CBCPeripheral {
    
    /// The signal power value. value is represented in dB
    ///
    var rssi: NSNumber? { get }
    
    /// Peripheral name
    ///
    var name: String { get }
    
    /// Peripheral UUID
    ///
    var uuid: UUID { get }
    
    /// Peripheral connection state. Can throw an error if isn't reachable
    ///
    var connectionState: CurrentValueSubject<Bool, CBCError> { get }
    
    /// Start connection to peripheral
    /// - Returns: publisher that passes connected `CBCPeripheral`
    ///
    func connect() -> AnyPublisher<CBCPeripheral, CBCError>
    
    /// Stops connection to peripheral
    /// - Returns: empty publisher
    ///
    func disconnect() -> AnyPublisher<Void, CBCError>
    
    /// Starts discovering particular service UUIDs. `nil` can be passed to discovering all possible services
    /// - Parameters:
    ///   - uuids: UUID strings for particular services
    /// - Returns: Publisher that passes found `CBCService`
    ///
    func discoverServices(with uuids: [UUID]?) -> AnyPublisher<CBCService, CBCError>
    
    /// Starts observing RSSI of peripheral.
    /// - Parameters:
    /// - Returns: Publisher that passes `NSNumber` in dB
    ///
    func observeRSSI() -> AnyPublisher<NSNumber, CBCError>
}
