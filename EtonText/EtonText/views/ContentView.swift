//
//  ContentView.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-01-27.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View
{
    @Binding var text_files: [EtonTextDocument]
    @Binding var current_file_index: Int?
    @Binding var untitled_count: Int
    @Binding var history_records: [History]
    @Binding var errorWrapper: ErrorWrapper?


    @Environment(\.scenePhase) private var scene_phase

    @State private var is_open_presenting: Bool = false
    @State private var is_history_presenting: Bool = false
    @State private var is_support_presenting: Bool = false
    @State private var is_help_presenting: Bool = false


    var body: some View
    {
        VStack(
                content:
                {
                    if (self.text_files.isEmpty == true)
                    {
                        HomeView(
                                text_files: self.$text_files,
                                current_file_index: self.$current_file_index,
                                untitled_count: self.$untitled_count,
                                history_records: self.$history_records,
                                is_open_presenting: self.$is_open_presenting,
                                is_history_presenting: self.$is_history_presenting,
                                is_support_presenting: self.$is_support_presenting,
                                is_help_presenting: self.$is_help_presenting,
                                errorWrapper: self.$errorWrapper
                                )
                                .navigationTitle("EtonText")
                    }
                    else
                    {
                        EditorView(
                                text_files: self.$text_files,
                                current_file_index: self.$current_file_index,
                                untitled_count: self.$untitled_count,
                                history_records: self.$history_records,
                                is_open_presenting: self.$is_open_presenting,
                                is_history_presenting: self.$is_history_presenting,
                                is_support_presenting: self.$is_support_presenting,
                                is_help_presenting: self.$is_help_presenting,
                                errorWrapper: self.$errorWrapper
                                )
                                .navigationTitle("")
                                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
                    }
                }
                )
                .sheet(
                        isPresented: self.$is_history_presenting,
                        content:
                        {
                            NavigationView(
                                    content:
                                    {
                                        HistoryView(
                                                text_files: self.$text_files,
                                                current_file_index: self.$current_file_index,
                                                history_records: self.$history_records,
                                                errorWrapper: self.$errorWrapper
                                                )
                                                .navigationTitle(LocalizedStringKey("Recent"))
                                                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
                                    }
                                    )
                        }
                        )
                .sheet(
                        isPresented: self.$is_support_presenting,
                        content:
                        {
                            NavigationView(
                                    content:
                                    {
                                        SupportView()
                                                .navigationTitle(LocalizedStringKey("About"))
                                                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
                                    }
                                    )
                        }
                        )
                .sheet(
                        isPresented: self.$is_help_presenting,
                        content:
                        {
                            NavigationView(
                                    content:
                                    {
                                        HelpView()
                                                .navigationTitle(LocalizedStringKey("Help"))
                                                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
                                    }
                                    )
                        }
                        )
                .sheet(
                        item: self.$errorWrapper,
                        onDismiss:
                        {
                            self.history_records = []
                        },
                        content:
                        {
                            (wrapper) in

                            NavigationView(
                                    content:
                                    {
                                        ErrorView(errorWrapper: wrapper)
                                                .navigationTitle(LocalizedStringKey("Error"))
                                                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
                                    }
                                    )
                        }
                        )
                .fileImporter(
                        isPresented: self.$is_open_presenting,
                        allowedContentTypes: [UTType.text],
                        allowsMultipleSelection: true,
                        onCompletion: self.load_file
                        )
                .onChange(
                        of: self.scene_phase,
                        perform: self.on_scene_phase_inactive
                        )
                .task({await self.on_appear_task()})
    }


    private func load_file(result: Result<[URL], any Error>) -> Void
    {
        switch result
        {
            case .success(let urls):
                let urls_sorted = urls.sorted(
                        by:
                        {
                            (first, second) in

                            return first.lastPathComponent <
                                second.lastPathComponent
                        }
                        )

                for (count, url) in urls_sorted.enumerated()
                {
                    if let matched_index = self.text_files.firstIndex(
                            where:
                            {
                                (element) in

                                if (url.path == element.path)
                                {
                                    return true
                                }
                                else
                                {
                                    return false
                                }
                            }
                            )
                    {
                        //
                        // Already opened.
                        //
                        self.current_file_index = matched_index

                    }
                    else
                    {
                        //
                        // Not opened.
                        //
                        if (
                            (count == 0) &&
                            (self.text_files.count == 1) &&
                            (self.text_files[0].on_disk == false)
                        )
                        {
                            // Replace first untitled file.

                            do
                            {
                                self.text_files[0] =
                                        try EtonTextDocument(url: url)
                            }
                            catch
                            {
                                self.errorWrapper = ErrorWrapper(
                                        error: error,
                                        guidance: String(
                                                localized: "Try again later."
                                                )
                                        )

                                return
                            }

                            self.current_file_index = 0
                        }
                        else
                        {
                            // Append to text_files.

                            do
                            {
                                self.text_files.append(
                                        try EtonTextDocument(url: url)
                                        )
                            }
                            catch
                            {
                                self.errorWrapper = ErrorWrapper(
                                        error: error,
                                        guidance: String(
                                                localized: "Try again later."
                                                )
                                        )

                                return
                            }

                            self.current_file_index = self.text_files.count - 1
                        }
                    }


                    if let history_index = self.history_records.firstIndex(
                            where:
                            {
                                (element) in

                                if (
                                    (element.is_available == true) &&
                                    (url.path == element.path)
                                )
                                {
                                    return true
                                }
                                else
                                {
                                    return false
                                }
                            }
                            )
                    {
                        // Already recorded.

                        self.history_records.move(
                                fromOffsets: IndexSet(integer: history_index),
                                toOffset: self.history_records.count
                                )
                    }
                    else
                    {
                        // Not recorded.

                        do
                        {
                            self.history_records.append(try History(url: url))

                            if self.history_records.count ==
                                    EtonTextApp.history_limit
                            {
                                self.history_records.removeFirst()
                            }
                            else
                            {
                            }
                        }
                        catch
                        {
                            self.errorWrapper = ErrorWrapper(
                                    error: error,
                                    guidance: String(
                                            localized: "Try again later."
                                            )
                                    )
                        }
                    }
                }

            case .failure(let error):
                self.errorWrapper = ErrorWrapper(
                        error: error,
                        guidance: String(localized: "Import error.")
                        )
        }
    }


    private func on_scene_phase_inactive(new_value: ScenePhase) -> Void
    {
        if (new_value == ScenePhase.inactive)
        {
            Task(
                    operation:
                    {
                        do
                        {
                            let file_url = try FileManager.default.url(
                                    for: FileManager.SearchPathDirectory
                                            .documentDirectory,
                                    in: FileManager.SearchPathDomainMask
                                            .userDomainMask,
                                    appropriateFor: nil,
                                    create: false
                                    )
                            .appendingPathComponent("history.data")

                            let task = Task(
                                    operation:
                                    {
                                        let data = try JSONEncoder()
                                                .encode(self.history_records)
                                        let outfile = file_url
                                        try data.write(to: outfile)
                                    }
                                    )

                            _ = try await task.value
                        }
                        catch
                        {
                            self.errorWrapper = ErrorWrapper(
                                    error: error,
                                    guidance: String(
                                            localized: "Try again later."
                                            )
                                    )
                        }
                    }
                    )
        }
        else
        {
        }
    }


    private func on_appear_task() async -> Void
    {
        do
        {
            let file_url = try FileManager.default.url(
                    for: FileManager.SearchPathDirectory.documentDirectory,
                    in: FileManager.SearchPathDomainMask.userDomainMask,
                    appropriateFor: nil,
                    create: false
                    )
            .appendingPathComponent("history.data")

            let task = Task<[History], Error>(
                    operation:
                    {
                        guard let data = try? Data(contentsOf: file_url)
                        else
                        {
                            return []
                        }

                        return try JSONDecoder()
                                .decode([History].self, from: data)
                    }
                    )

            self.history_records = try await task.value
        }
        catch
        {
            self.errorWrapper = ErrorWrapper(
                    error: error,
                    guidance: String(
                            localized: "EtonText will load a blank recent files records."
                            )
                    )
        }
    }

}



#Preview
{
    ContentView(
            text_files: .constant(EtonTextDocument.sample_data),
            current_file_index: .constant(0),
            untitled_count: .constant(0),
            history_records: .constant(History.sample_data),
            errorWrapper: .constant(nil)
            )
}
