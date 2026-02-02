//
//  EditorView.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-03-10.
//

import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View
{
    @Binding var text_files: [EtonTextDocument]
    @Binding var current_file_index: Int?
    @Binding var untitled_count: Int
    @Binding var history_records: [History]
    @Binding var is_open_presenting: Bool
    @Binding var is_history_presenting: Bool
    @Binding var is_support_presenting: Bool
    @Binding var is_help_presenting: Bool
    @Binding var errorWrapper: ErrorWrapper?


    @State private var is_save_presenting: Bool = false
    @State private var is_close_presenting: Bool = false
    @State private var is_close_all_presenting: Bool = false
    @State private var is_list_presenting: Bool = false
    @State private var is_info_presenting: Bool = false

    // TODO: Cannot define here as State or will raise error out of range, why?
    //     I want preview the ContentView with a variable current_file_index,
    //     When use Binding, I must pass a constant to preview.
    //@State private var current_file_index: Int = 0

    private var current_file: EtonTextDocument?
    {
        get
        {
            if (self.text_files.isEmpty == true)
            {
                return nil
            }
            else
            {
                return self.text_files[self.current_file_index!]
            }
        }
    }


    var body: some View
    {
        TabView(
                selection: self.$current_file_index,
                content:
                {
//                        TODO: Can NOT work.
//                        ForEach(
//                            Array(self.text_files.enumerated()),
//                            id: \.element.id,
//                            content:
//                            {
//                                (text_file_enumerated) in
//
//                                VStack(
//                                    content:
//                                    {
//                                        TextEditorView(text: self.$text_files[text_file_enumerated.offset].content)
//                                            .font(Font.body.monospaced())
//                                    }
//                                )
//                                    .tag(text_file_enumerated.offset)
//                            }
//                        )

                    ForEach(
                            self.$text_files,
                            content:
                            {
                                ($text_file) in

                                VStack(
                                        content:
                                        {
                                            EditorBaseView(
                                                    text: $text_file.content
                                                    )
                                        }
                                        )
                                        .tag(self.get_tag(text_file: text_file))
                            }
                            )
                }
                )
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: PageTabViewStyle.IndexDisplayMode.never))
                .padding(Edge.Set.horizontal)
                .fileExporter(
                        isPresented: self.$is_save_presenting,
                        document: self.current_file,
                        contentType: UTType.text,
                        defaultFilename: self.current_file?.basename,
                        onCompletion: self.write_file
                        )
                .sheet(
                        isPresented: self.$is_list_presenting,
                        content:
                        {
                            NavigationView(
                                    content:
                                    {
                                        FileListView(
                                                text_files: self.$text_files,
                                                current_file_index: self.$current_file_index,
                                                untitled_count: self.$untitled_count
                                                )
                                                .navigationTitle(LocalizedStringKey("List"))
                                                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
                                    }
                                    )
                        }
                        )
                .sheet(
                        isPresented: self.$is_info_presenting,
                        content:
                        {
                            NavigationView(
                                    content:
                                    {
                                        FileInfoView(
                                                text_file: self.current_file
                                                )
                                                .navigationTitle(LocalizedStringKey("Info"))
                                                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
                                    }
                                    )
                        }
                        )
                .confirmationDialog(
                        Text(LocalizedStringKey("The file is not saved")),
                        isPresented: self.$is_close_presenting,
                        titleVisibility: Visibility.visible,
                        actions:
                        {
                            Button(
                                    role: ButtonRole.destructive,
                                    action: self.close,
                                    label: { Text(LocalizedStringKey("Discard changes")) }
                                    )
                        }
                        )
                .confirmationDialog(
                        Text(LocalizedStringKey("One or more files is not saved")),
                        isPresented: self.$is_close_all_presenting,
                        titleVisibility: Visibility.visible,
                        actions:
                        {
                            Button(
                                    role: ButtonRole.destructive,
                                    action: self.close_all,
                                    label: { Text(LocalizedStringKey("Discard all changes")) }
                                    )
                        }
                        )
                .toolbar(
                        content:
                        {
                            ToolbarItem(
                                    placement: ToolbarItemPlacement.principal,
                                    content:
                                    {
                                        Menu(
                                                content:
                                                {
                                                    Button(
                                                            action: {self.is_info_presenting = true},
                                                            label: {Label(LocalizedStringKey("Get info"), systemImage: "info.circle")}
                                                            )
                                                    Divider()
                                                    Button(
                                                            role: ButtonRole.destructive,
                                                            action: self.close_with_dialog,
                                                            label: {Label(LocalizedStringKey("Close"), systemImage: "minus")}
                                                            )
                                                },
                                                label:
                                                {
                                                    HStack(
                                                            spacing: 0,
                                                            content:
                                                            {
                                                                if let index = self.current_file_index
                                                                {
                                                                    if (self.text_files[index].modified == true)
                                                                    {
                                                                        Image(systemName: "asterisk")
                                                                                .imageScale(Image.Scale.small)
                                                                                .scaleEffect(0.7)
                                                                                .foregroundStyle(ForegroundStyle())
                                                                    }
                                                                    else
                                                                    {
                                                                    }

                                                                    Text(self.text_files[index].basename)
                                                                            .font(Font.headline)
                                                                            .lineLimit(1)
                                                                            .truncationMode(Text.TruncationMode.middle)
                                                                            .frame(maxWidth: 160)
                                                                            .foregroundStyle(ForegroundStyle())
                                                                    Image(systemName: "chevron.down.circle.fill")
                                                                            .imageScale(Image.Scale.medium)
                                                                }
                                                                else
                                                                {
                                                                }
                                                            }
                                                            )
                                                }
                                                )
                                    }
                                    )
                            ToolbarItem(
                                    placement: ToolbarItemPlacement.topBarLeading,
                                    content:
                                    {
                                        Button(
                                                action: { self.is_list_presenting = true },
                                                label: { Label(LocalizedStringKey("Save"), systemImage: "list.bullet") }
                                                )
                                    }
                                    )
                            ToolbarItem(
                                    placement: ToolbarItemPlacement.primaryAction,
                                    content:
                                    {
                                        Menu(
                                                content:
                                                {
                                                    Button(
                                                            action: self.add_file,
                                                            label: { Label(LocalizedStringKey("New"), systemImage: "plus") }
                                                            )
                                                    Button(
                                                            action: { self.is_open_presenting = true },
                                                            label: { Label(LocalizedStringKey("Open"), systemImage: "doc") }
                                                            )
                                                    Button(
                                                            action: { self.is_history_presenting = true },
                                                            label: { Label(LocalizedStringKey("Recent"), systemImage: "clock") }
                                                            )
                                                    Divider()
                                                    Button(
                                                            role: ButtonRole.destructive,
                                                            action: self.close_all_with_dialog,
                                                            label: { Label(LocalizedStringKey("Close all"), systemImage: "xmark") }
                                                            )
                                                    Divider()
                                                    Button(
                                                            action: { self.is_help_presenting = true },
                                                            label: { Label(LocalizedStringKey("Help"), systemImage: "questionmark.circle") }
                                                            )
                                                    Button(
                                                            action: { self.is_support_presenting = true },
                                                            label: { Label(LocalizedStringKey("About"), systemImage: "message") }
                                                            )
                                                },
                                                label:
                                                {
                                                    Label(LocalizedStringKey("Menu"), systemImage: "ellipsis.circle")
                                                }
                                                )
                                    }
                                    )
                            ToolbarItem(
                                    placement: ToolbarItemPlacement.topBarTrailing,
                                    content:
                                    {
                                        Button(
                                                action: self.save_file,
                                                label: { Label(LocalizedStringKey("Save"), systemImage: "square.and.arrow.down") }
                                                )
                                    }
                                    )
                            }
                        )
                .onChange(
                        of: self.current_file?.content ?? "",
                        perform: self.on_content_change
                        )
    }







    private func get_tag(text_file: EtonTextDocument) -> Int?
    {
        return self.text_files.firstIndex(
                where: {
                    (element) in

                    if (text_file.id == element.id)
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                }
                )
    }



    private func write_file(result: Result<URL, any Error>) -> Void
    {
        switch result
        {
            case .success(let url):
                guard let index = self.current_file_index
                else
                {
                    return
                }

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
                    // Already opened.

                    self.text_files.remove(at: index)

                    if (index > matched_index)
                    {
                        self.current_file_index = self.text_files.count - 1
                    }
                    else
                    {
                    }
                }
                else
                {
                    // Not opened.

                    do
                    {
                        self.text_files[index] = try EtonTextDocument(url: url)
                    }
                    catch
                    {
                        self.errorWrapper = ErrorWrapper(
                                error: error,
                                guidance: String(localized: "Try again later.")
                                )

                        return
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
                                guidance: String(localized: "Try again later.")
                                )
                    }
                }

            case .failure(let error):
                self.errorWrapper = ErrorWrapper(
                        error: error,
                        guidance: String(localized: "Export error.")
                        )
        }
    }



    private func add_file() -> Void
    {
        if (self.untitled_count == 0)
        {
            self.text_files.append(EtonTextDocument())
        }
        else
        {
            self.text_files.append(
                    EtonTextDocument(increase: self.untitled_count)
                    )
        }

        self.current_file_index = self.text_files.count - 1
        self.untitled_count += 1
    }




    private func save_file() -> Void
    {
        guard let index = self.current_file_index
        else
        {
            return
        }

        if (self.text_files[index].on_disk == false)
        {
            self.is_save_presenting = true
        }
        else
        {
            if (self.text_files[index].modified == true)
            {
                do
                {
                    try self.text_files[index].save()
                }
                catch
                {
                    self.errorWrapper = ErrorWrapper(
                            error: error,
                            guidance: String(localized: "Try again later.")
                            )
                }
            }
            else
            {
            }
        }
    }



    private func close() -> Void
    {
        guard let index = self.current_file_index
        else
        {
            return
        }

        UIApplication.shared.connectedScenes.compactMap(
                {
                    ($0 as? UIWindowScene)?.keyWindow
                }
                )
        .last?.endEditing(true)

        if (self.text_files.count > 1)
        {
            //
            // Part of files will be removed.
            //
            let is_at_end = (index == (self.text_files.count - 1))
            if (is_at_end == true)
            {
                // Delted at the end of array.

                self.text_files.remove(at: index)
                self.current_file_index = self.text_files.count - 1
            }
            else
            {
                // Other situations

                self.text_files.remove(at: index)
            }
        }
        else
        {
            //
            // All files will be removed.
            //
            self.text_files.removeAll()
            self.current_file_index = nil
            self.untitled_count = 0
        }
    }


    private func close_with_dialog() -> Void
    {
        guard let index = self.current_file_index
        else
        {
            return
        }

        if (self.text_files[index].modified == true)
        {
            self.is_close_presenting = true
        }
        else
        {
            self.close()
        }
    }




    private func close_all() -> Void
    {
        UIApplication.shared.connectedScenes.compactMap(
                {
                    ($0 as? UIWindowScene)?.keyWindow
                }
                )
        .last?.endEditing(true)

        self.text_files.removeAll()
        self.current_file_index = nil
        self.untitled_count = 0
    }


    private func close_all_with_dialog() -> Void
    {
        var is_modified: Bool = false
        for text_file in self.text_files
        {
            if (text_file.modified == true)
            {
                is_modified = true
                break
            }
            else
            {
            }
        }

        if (is_modified == true)
        {
            self.is_close_all_presenting = true
        }
        else
        {
            self.close_all()
        }
    }



    private func on_content_change(new_value: String) -> Void
    {
        guard let index = self.current_file_index
        else
        {
            return
        }

        if (self.text_files[index].modified == false)
        {
            // When modified flag is false, check the content to see whether
            // need change it.

            if (self.text_files[index].copied_content != new_value)
            {
                self.text_files[index].modified = true
            }
            else
            {
            }
        }
        else
        {
            // When modified flag is true, no need to change it.
        }
    }
}

#Preview
{
    EditorView(
            text_files: .constant(EtonTextDocument.sample_data),
            current_file_index: .constant(0),
            untitled_count: .constant(0),
            history_records: .constant(History.sample_data),
            is_open_presenting: .constant(false),
            is_history_presenting: .constant(false),
            is_support_presenting: .constant(false),
            is_help_presenting: .constant(false),
            errorWrapper: .constant(nil)
            )
}
