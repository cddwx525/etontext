//
//  History.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-03-07.
//

import SwiftUI
import UniformTypeIdentifiers

struct History: Identifiable, Codable
{
    let id: UUID
    var url: URL
    var bookmark: Data
    var basename: String
    var path: String
    var is_available: Bool = true


    static let dir: URL = FileManager.default.urls(
            for: FileManager.SearchPathDirectory.documentDirectory,
            in: FileManager.SearchPathDomainMask.userDomainMask
            )
            .first!

    static let sample_data: [History] = [
        History(dir: History.dir, basename: "111.txt"),
        History(dir: History.dir, basename: "222.txt"),
        History(dir: History.dir, basename: "3333.txt"),
        History(dir: History.dir, basename: "44444.txt"),
        History(dir: History.dir, basename: "55555.txt"),
        History(dir: History.dir, basename: "66666.txt"),
    ]


    init(id: UUID = UUID(), dir: URL, basename: String)
    {
        self.id = id
        self.url = dir.appendingPathComponent(
                basename,
                conformingTo: UTType.text
                )
        self.bookmark = Data()
        self.path = self.url.path
        self.basename = self.url.lastPathComponent
    }


    init(id: UUID = UUID(), url: URL) throws
    {
        self.id = id
        self.url = url

        guard url.startAccessingSecurityScopedResource()
        else
        {
            throw CocoaError(CocoaError.fileReadNoPermission)
        }

        do
        {
            self.bookmark = try url.bookmarkData(
                    options: [.withoutImplicitSecurityScope]
                    )

            url.stopAccessingSecurityScopedResource()
        }
        catch
        {
            url.stopAccessingSecurityScopedResource()

            throw CocoaError(CocoaError.coderInvalidValue)
        }

        self.path = self.url.path
        self.basename = self.url.lastPathComponent
    }


    mutating func set_availability() -> Void
    {
        if (self.url.path != self.path)
        {
            self.is_available = false
        }
        else
        {
            self.is_available = true
        }
    }


    mutating func set_url() throws -> Void
    {
        var stale = false

        do
        {
            self.url = try URL(
                    resolvingBookmarkData: self.bookmark,
                    options: [.withoutImplicitStartAccessing],
                    relativeTo: nil,
                    bookmarkDataIsStale: &stale
                    )

            if stale == true
            {
                try self.make_bookmark()
            }
            else
            {
            }
        }
        catch
        {
            throw CocoaError(CocoaError.coderInvalidValue)
        }
    }



    private mutating func make_bookmark() throws -> Void
    {
        guard self.url.startAccessingSecurityScopedResource()
        else
        {
            throw CocoaError(CocoaError.fileReadNoPermission)
        }

        do
        {
            self.bookmark = try self.url.bookmarkData(
                    options: [.withoutImplicitSecurityScope]
                    )

            self.url.stopAccessingSecurityScopedResource()
        }
        catch
        {
            self.url.stopAccessingSecurityScopedResource()

            throw CocoaError(CocoaError.coderInvalidValue)
        }
    }

}
