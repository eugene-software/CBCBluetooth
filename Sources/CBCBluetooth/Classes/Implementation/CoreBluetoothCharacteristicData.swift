//
//  CharacteristicData.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation

struct CoreBluetoothCharacteristicData: CBCCharacteristicData {

    let data: Data
    let peripheral: CBCPeripheral
    let identifier: UUID
}
