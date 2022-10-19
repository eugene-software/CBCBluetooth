//
//  Error+ext.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation

extension Error {
    
    var cbcError: CBCError {
        return self as? CBCError ?? .unspecified
    }
}
