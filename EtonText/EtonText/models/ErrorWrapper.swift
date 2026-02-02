//
//  ErrorWrapper.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-03-08.
//

import Foundation

struct ErrorWrapper: Identifiable
{
    let id: UUID
    let error: Error
    let guidance: String

    enum SampleError: Error
    {
        case errorRequired
    }

    static let smaple_data: [ErrorWrapper] = [
        ErrorWrapper(
            error: SampleError.errorRequired,
            guidance: String(localized: "You can safely ignore this error.")
            )
    ]


    init(id: UUID = UUID(), error: Error, guidance: String)
    {
        self.id = id
        self.error = error
        self.guidance = guidance
    }
}
