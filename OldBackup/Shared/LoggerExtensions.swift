//
//  LoggerExtensions.swift
//  Padel Watch App
//
//  Created by Roland Kajatin on 12/10/2023.
//

import OSLog

extension Logger {
    private static let appIdentifier = Bundle.main.bundleIdentifier!
#if os(watchOS)
    static let shared = Logger(subsystem: appIdentifier, category: "PadelProWatch")
#else
    static let shared = Logger(subsystem: appIdentifier, category: "PadelPro")
#endif
}
