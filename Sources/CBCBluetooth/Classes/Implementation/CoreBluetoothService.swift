//
//  CoreBluetoothService.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine


struct CoreBluetoothService: CBCService {
    
    private let service: CBService
    private let peripheral: CoreBluetoothPeripheral
    
    init(service: CBService, peripheral: CoreBluetoothPeripheral) {
       self.service = service
       self.peripheral = peripheral
    }
    
    func discoverCharacteristics(with characteristicsIds: [String]?) -> AnyPublisher<CBCCharacteristic, CBCError> {
        return peripheral.discoverCharacteristics(with: characteristicsIds, for: service)
    }
}
