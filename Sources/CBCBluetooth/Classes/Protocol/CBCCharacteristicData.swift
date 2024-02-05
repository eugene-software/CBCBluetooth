//
//  CharacteristicData.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation

public protocol CBCCharacteristicData {

    /// Read characteristic data
    ///
    var data: Data { get }
    
    /// Characteristic ID string
    ///
    var identifier: String { get }
    
    /// Peripgeral that owns this characteristic
    ///
    var peripheral: CBCPeripheral { get }
}
