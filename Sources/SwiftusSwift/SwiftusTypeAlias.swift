//
//  File.swift
//  
//
//  Created by L7 Mobile on 06/04/2024.
//

import Foundation
import SwiftUI

public typealias VoidComplete = () -> Void
public typealias BoolComplete = (Bool) -> Void
public typealias StringComplete = (String) -> Void
public typealias UrlComplete = (URL) -> Void
public typealias DoubleComplete = (Double) -> Void
public typealias ColorComplete = (SwiftUI.Color) -> Void

public typealias SwiftusComplete<T> = (T) -> Void

