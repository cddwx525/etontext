//
//  FileListView.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-02-20.
//

import SwiftUI

struct FileListView: View
{
    @Binding var text_files: [EtonTextDocument]
    @Binding var current_file_index: Int?
    @Binding var untitled_count : Int


    @Environment(\.dismiss) private var dismiss

    @State private var is_close_presenting: Bool = false
    @State private var is_close_selected_presenting: Bool = false
    @State private var selected_index_set: IndexSet = []
    @State private var edit_mode: EditMode = EditMode.inactive


    var body: some View
    {
        List(
                content:
                {
                    ForEach(
                            self.$text_files,
                            id: \.id,
                            content:
                            {
                                ($text_file) in

                                let file_index = self.get_current_file_index(text_file: text_file)

                                HStack(
                                        content:
                                        {
                                            if (file_index == self.current_file_index)
                                            {
                                                if (text_file.modified == true)
                                                {
                                                    Image(systemName: "doc.fill.badge.ellipsis").imageScale(Image.Scale.large)
                                                }
                                                else
                                                {
                                                    Image(systemName: "doc.fill").imageScale(Image.Scale.large)
                                                }
                                            }
                                            else
                                            {
                                                if (text_file.modified == true)
                                                {
                                                    Image(systemName: "doc.badge.ellipsis").imageScale(Image.Scale.large)
                                                }
                                                else
                                                {
                                                    Image(systemName: "doc").imageScale(Image.Scale.large)
                                                }
                                            }
                                            VStack(
                                                    alignment: HorizontalAlignment.leading,
                                                    content:
                                                    {
                                                        HStack(
                                                                content:
                                                                {
                                                                    if (file_index == self.current_file_index)
                                                                    {
                                                                        Text(text_file.basename).font(Font.body.weight(Font.Weight.bold))
                                                                    }
                                                                    else
                                                                    {
                                                                        Text(text_file.basename)
                                                                    }
                                                                }
                                                                )
                                                                .foregroundStyle(HierarchicalShapeStyle.primary)
                                                        HStack(
                                                                content:
                                                                {
                                                                    Text(text_file.type)
                                                                    Text(text_file.encoding)
                                                                    Text(text_file.size)
                                                                    Text(LocalizedStringKey("bytes"))
                                                                        .padding(Edge.Set.leading, -5)
                                                                }
                                                                )
                                                                .font(Font.footnote)
                                                                .foregroundStyle(HierarchicalShapeStyle.secondary)
                                                    }
                                                    )
                                            Spacer()
                                            if (file_index == self.current_file_index)
                                            {
                                                Image(systemName: "checkmark")
                                            }
                                            else
                                            {
                                            }
                                        }
                                        )
                                        .padding(Edge.Set.vertical, 5)
                                        .contentShape(Rectangle())
                                        .onTapGesture(
                                                perform:
                                                {
                                                    dismiss()

                                                    self.current_file_index = file_index
                                                }
                                                )
                            }
                            )
                            .onMove(
                                    perform: self.on_move
                                    )
                            .onDelete(
                                    perform: self.on_delete
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
                                    action:
                                    {
                                        self.remove_selected(index_set: self.selected_index_set)
                                    },
                                    label:
                                    {
                                        Text(LocalizedStringKey("Discard changes"))
                                    }
                                    )
                        }
                        )
                .confirmationDialog(
                        Text(LocalizedStringKey("One or more files is not saved")),
                        isPresented: self.$is_close_selected_presenting,
                        titleVisibility: Visibility.visible,
                        actions:
                        {
                            Button(
                                    role: ButtonRole.destructive,
                                    action:
                                    {
                                        self.remove_selected(index_set: self.selected_index_set)
                                    },
                                    label:
                                    {
                                        Text(LocalizedStringKey("Discard all changes"))
                                    }
                                    )
                        }
                        )
                .toolbar(
                        content:
                        {
                            ToolbarItem(
                                    placement: ToolbarItemPlacement.cancellationAction,
                                    content:
                                    {
                                        if (self.edit_mode == EditMode.inactive)
                                        {
                                                Button(
                                                    action:
                                                    {
                                                        dismiss()
                                                    },
                                                    label: { Text(LocalizedStringKey("Cancel")) }
                                                    )
                                        }
                                        else
                                        {
                                        }
                                    }
                                    )
                            ToolbarItem(
                                    placement: ToolbarItemPlacement.primaryAction,
                                    content:
                                    {
                                        EditButton()
                                    }
                                    )
                        }
                        )
                .environment(\.editMode, self.$edit_mode)
    }





    private func get_current_file_index(text_file: EtonTextDocument) -> Int
    {
        return self.text_files.firstIndex(
                where:
                {
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
            )!
    }


    private func on_move(index_set: IndexSet, new_offset: Int) -> Void
    {
        guard let index = self.current_file_index
        else
        {
            return
        }

        let current_file = self.text_files[index]

        self.text_files.move(fromOffsets: index_set, toOffset: new_offset)

        self.current_file_index = self.get_current_file_index(
                text_file: current_file
                )
    }




    private func on_delete(index_set: IndexSet) -> Void
    {
        var is_modified = false
        for index in index_set
        {
            if (self.text_files[index].modified == true)
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
            self.selected_index_set = index_set

            if (index_set.count > 1)
            {
                self.is_close_selected_presenting = true
            }
            else
            {
                self.is_close_presenting = true
            }

        }
        else
        {
            self.remove_selected(index_set: index_set)
        }
    }




    private func remove_selected(index_set: IndexSet) -> Void
    {
        guard let index = self.current_file_index
        else
        {
            return
        }

        if (index_set.contains(index))
        {
            // Current file will be removed.

            if (index_set.count < self.text_files.count)
            {
                // Part of files will be removed.

                let is_at_end = index_set.max()! == (self.text_files.count - 1)
                let is_continuous = (index_set.max()! - index_set.min()!) ==
                        (index_set.count - 1)

                if ((is_at_end == true) && (is_continuous == true))
                {
                    // Delted at the end of array.

                    self.text_files.remove(atOffsets: index_set)
                    self.current_file_index = self.text_files.count - 1

                }
                else
                {
                    // Other situations.

                    self.text_files.remove(atOffsets: index_set)
                    self.current_file_index = index_set.min()!
                }
            }
            else
            {
                // All files will be removed.

                self.text_files.removeAll()
                self.current_file_index = nil
                self.untitled_count = 0
            }
        }
        else
        {
            // Current file will not be removed.

            let current_file = self.text_files[index]

            self.text_files.remove(atOffsets: index_set)

            self.current_file_index = self.get_current_file_index(
                    text_file: current_file
                    )
        }
    }
}



#Preview
{
    FileListView(
            text_files: .constant(EtonTextDocument.sample_data),
            current_file_index: .constant(0),
            untitled_count: .constant(1)
            )
}
