//
//  Service.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation
import Combine

public protocol CBCService {
    
    /// Starts discovering particular characteristics UUIDs. `nil` can be passed to discovering all possible characteristics
    /// - Parameters:
    ///   - characteristicsIds: ID strings for particular characteristics
    /// - Returns: Publisher that passes found `CBCCharacteristic`
    ///
    func discoverCharacteristics(with characteristicsIds: [String]?) -> AnyPublisher<CBCCharacteristic, CBCError>
}
