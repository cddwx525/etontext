//
//  EtonTextApp.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-01-27.
//

import SwiftUI

@main
struct EtonTextApp: App
{
    @State private var text_files: [EtonTextDocument] = []
    @State private var current_file_index: Int?
    @State private var untitled_count: Int = 0
    @State private var history_records: [History] = []
    static let history_limit: Int = 50
    static let home_history_limit: Int = 5
    @State private var errorWrapper: ErrorWrapper?

    var body: some Scene
    {
        WindowGroup(
            content:
            {
                NavigationView(
                    content:
                    {
                        ContentView(
                            text_files: self.$text_files,
                            current_file_index: self.$current_file_index,
                            untitled_count: self.$untitled_count,
                            history_records: self.$history_records,
                            errorWrapper: self.$errorWrapper
                        )
                    }
                )
            }
        )
    }
}


#Preview
{
    NavigationView(
        content:
        {
            ContentView(
                text_files: .constant(EtonTextDocument.sample_data),
                current_file_index: .constant(0),
                untitled_count: .constant(0),
                history_records: .constant(History.sample_data),
                errorWrapper: .constant(nil)
            )
        }
    )
}
