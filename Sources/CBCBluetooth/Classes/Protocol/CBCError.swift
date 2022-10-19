//
//  BluetoothError.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Error enum that reflects any possible failures of CBCBluetooth
///
public enum CBCError: Error {
    
    /// Unknown error
    ///
    case unspecified
    
    /// Thrown if object is deallocated before request is received by sender
    ///
    case objectDeallocated
    
    /// Thrown if characteristic value is `nil`
    ///
    case invalidData
    
    /// Thrown if user declines pairing process
    ///
    case pairing
    
    /// Connection error
    ///
    case connection(Error?)
    
    /// Discovering services error
    ///
    case service(Error?)
    
    /// Discovering characteristics error
    ///
    case characteristic(Error?)
    
    /// Thrown if write data to characteristic is restricted or failed
    ///
    case write(Error?)
}
