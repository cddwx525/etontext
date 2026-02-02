//
//  EtonTextDocument.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-01-27.
//

import SwiftUI
import UniformTypeIdentifiers


struct EtonTextDocument: FileDocument, Identifiable
{
    static var readableContentTypes: [UTType]
    {
        [UTType.text]
    }

    let id: UUID

    var url: URL
    var basename: String
    var path: String

    var encoding: String
    var type: String
    var on_disk: Bool

    var content: String = String()
    var modified: Bool = false
    var copied_content: String = String()

    var size: String
    {
        if (self.on_disk == true)
        {
            do
            {
                return String(try self.get_attributes().fileSize())
            }
            catch
            {
                return "Exception"
            }
        }
        else
        {
            return "NULL"
        }
    }

    var create_date: String
    {
        if (self.on_disk == true)
        {
            do
            {
                return (try self.get_attributes().fileCreationDate())!
                        .formatted()
            }
            catch
            {
                return "Exception"
            }
        }
        else
        {
            return "NULL"
        }
    }

    var modified_date: String
    {
        if (self.on_disk == true)
        {
            do
            {
                return (try self.get_attributes().fileModificationDate())!
                        .formatted()
            }
            catch
            {
                return "Exception"
            }
        }
        else
        {
            return "NULL"
        }
    }

    static let sample_data: [EtonTextDocument] = [
            EtonTextDocument(
                    basename: "很长长长长长长长长长长长长1111111111.txt",
                    content: "11111111111"
                    ),
            EtonTextDocument(
                    basename: "2.json",
                    content: "22222222222"
                    ),
            EtonTextDocument(
                    basename: "3.md",
                    content: "33333333333"
                    )
            ]


    init(id: UUID = UUID())
    {
        self.id = id
        self.basename = String("Untitled")
        self.url = FileManager.default.urls(
                for: FileManager.SearchPathDirectory.documentDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask
                )
                .first!
                .appendingPathComponent(
                        self.basename,
                        conformingTo: UTType.text
                        )
        self.path = String("NULL")
        self.type = String("NULL")
        self.encoding = String("NULL")
        self.on_disk = false
    }


    init(id: UUID = UUID(), increase: Int)
    {
        self.id = id
        self.basename = String("Untitled") + String("_") + String(increase)
        self.url = FileManager.default.urls(
                for: FileManager.SearchPathDirectory.documentDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask
                )
                .first!
                .appendingPathComponent(
                        self.basename,
                        conformingTo: UTType.text
                        )
        self.path = String("NULL")
        self.type = String("NULL")
        self.encoding = String("NULL")
        self.on_disk = false
    }


    init(id: UUID = UUID(), basename: String, content: String)
    {
        self.id = id
        self.basename = basename
        self.content = content
        self.url = FileManager.default.urls(
                for: FileManager.SearchPathDirectory.documentDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask
                )
                .first!
                .appendingPathComponent(
                        self.basename,
                        conformingTo: UTType.text
                        )
        self.path = self.url.path
        self.type = String("NULL")
        self.encoding = String("NULL")
        self.on_disk = false
    }


    init(id: UUID = UUID(), url: URL) throws
    {
        self.id = id
        self.url = url
        self.basename = url.lastPathComponent

        if let mimeType = UTType(filenameExtension: url.pathExtension)?
                .preferredMIMEType
        {
            self.type = mimeType
        }
        else
        {
            self.type = String("application/octet-stream")
        }

        self.path = url.path

        let ret = self.url.startAccessingSecurityScopedResource()
        if (ret == false)
        {
            throw CocoaError(CocoaError.fileReadNoPermission)
        }
        else
        {
            var data: Data? = nil
            do
            {
                data = try Data(contentsOf: url)
                url.stopAccessingSecurityScopedResource()
            }
            catch
            {
                self.url.stopAccessingSecurityScopedResource()
                throw CocoaError(CocoaError.fileReadCorruptFile)
            }

            let encoding = NSString.stringEncoding(
                    for: data!,
                    encodingOptions: nil,
                    convertedString: nil,
                    usedLossyConversion: nil
                    )
            self.encoding = NSString.localizedName(of: encoding)

            let string = String(
                    data: data!,
                    encoding: String.Encoding(rawValue: encoding)
                    )
            if (string == nil)
            {
                throw CocoaError(CocoaError.coderReadCorrupt)
            }
            else
            {
                self.content = string!
                self.copied_content = self.content
                self.on_disk = true
                self.modified = false
            }
        }
    }

    init(configuration: ReadConfiguration) throws
    {
        self.id = UUID()

        let file_wrapper = configuration.file
        self.basename = file_wrapper.filename!

        let data = file_wrapper.regularFileContents
        if (data == nil)
        {
            throw CocoaError(CocoaError.fileReadCorruptFile)
        }
        else
        {
            let string = String(data: data!, encoding: .utf8)
            if (string == nil)
            {
                throw CocoaError(CocoaError.coderReadCorrupt)
            }
            else
            {
                self.content = string!
                self.copied_content = self.content

                //
                // TODO:
                //     Can not get url from ReadConfiguration
                // , so below just for init.
                //
                self.url = FileManager.default.urls(
                        for: FileManager.SearchPathDirectory.documentDirectory,
                        in: FileManager.SearchPathDomainMask.userDomainMask
                        )
                        .first!
                        .appendingPathComponent(
                                self.basename,
                                conformingTo: UTType.text
                                )
                self.path = String("NULL")
                self.type = String("NULL")
                self.encoding = String("NULL")
                self.on_disk = false
            }
        }
    }


    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        let data = self.content.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }


    mutating func save() throws -> Void
    {
        //
        // Simple method.
        //
        let ret = self.url.startAccessingSecurityScopedResource()
        if (ret == false)
        {
            throw CocoaError(CocoaError.fileReadNoPermission)
        }
        else
        {
            do
            {
                try self.content.write(
                        to: self.url,
                        atomically: true,
                        encoding: String.Encoding.utf8
                        )
                self.url.stopAccessingSecurityScopedResource()
            }
            catch
            {
                self.url.stopAccessingSecurityScopedResource()
                throw CocoaError(CocoaError.fileWriteUnknown)
            }

            self.modified = false
            self.copied_content = self.content
        }

//        //
//        // Use FileWrapper.
//        //
//        guard let data = self.content.data(using: .utf8)
//        else
//        {
//            print("Failed convert to data.")
//            return
//        }
//
//        let file_wrapper = FileWrapper(regularFileWithContents: data)
//        do
//        {
//            try file_wrapper.write(
//                    to: self.url!,
//                    originalContentsURL: self.url!
//                    )
//        }
//        catch
//        {
//            print("Failed write.")
//        }
    }

    mutating func rename(new_name: String) throws -> Void
    {
        let directory = self.url.deletingLastPathComponent()
        let new_url = directory.appendingPathComponent(new_name)

        do
        {
            try FileManager.default.moveItem(at: self.url, to: new_url)
        }
        catch
        {
            throw CocoaError(CocoaError.fileWriteUnknown)
        }

        self.url = new_url
        self.path = self.url.path
        self.basename = url.lastPathComponent
    }


    private func get_attributes() throws -> NSDictionary
    {
        if (self.on_disk == true)
        {
            let ret = self.url.startAccessingSecurityScopedResource()
            if (ret == false)
            {
                throw CocoaError(.fileReadNoPermission)
            }
            else
            {
                var attrs: [FileAttributeKey: Any]? = nil
                do
                {
                    attrs = try FileManager.default.attributesOfItem(
                            atPath: self.url.path
                            )
                    self.url.stopAccessingSecurityScopedResource()
                }
                catch
                {
                    self.url.stopAccessingSecurityScopedResource()
                    throw CocoaError(.fileReadUnknown)
                }
                return NSDictionary(dictionary: attrs!)
            }
        }
        else
        {
            return [:]
        }
    }
}
