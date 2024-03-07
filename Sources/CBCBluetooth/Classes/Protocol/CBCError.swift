//
//  CBCError.swift
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
