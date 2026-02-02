//
//  HistoryView.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-03-06.
//

import SwiftUI

struct HistoryView: View
{
    @Binding var text_files: [EtonTextDocument]
    @Binding var current_file_index: Int?
    @Binding var history_records: [History]
    @Binding var errorWrapper: ErrorWrapper?


    @Environment(\.dismiss) private var dismiss

    @State private var is_alter_presenting: Bool = false
    @State private var alter_title: String = String()

    @State private var edit_mode: EditMode = EditMode.inactive


    var body: some View
    {
        List(
                content:
                {
                    ForEach(
                            Array(self.history_records.reversed().enumerated()),
                            id: \.element.id,
                            content:
                            {
                                (history_enumerated) in

                                HStack(
                                        content:
                                        {
                                            if (history_enumerated.element.is_available == false)
                                            {
                                                Image(systemName: "clock.badge.exclamationmark").imageScale(Image.Scale.large)
                                            }
                                            else
                                            {
                                                Image(systemName: "clock").imageScale(Image.Scale.large)
                                            }

                                            VStack(
                                                    alignment: HorizontalAlignment.leading,
                                                    content:
                                                    {
                                                        HStack(
                                                                content:
                                                                {
                                                                    Text(history_enumerated.element.basename)
                                                                }
                                                                )
                                                                .font(Font.headline)
                                                                .foregroundStyle(HierarchicalShapeStyle.primary)
                                                        HStack(
                                                                content:
                                                                {
                                                                    Text(history_enumerated.element.path)
                                                                    //.lineLimit(1)
                                                                    //.truncationMode(.head)
                                                                }
                                                                )
                                                                .font(Font.footnote)
                                                                .foregroundStyle(HierarchicalShapeStyle.secondary)
                                                    }
                                                    )
                                            Spacer()
                                        }
                                        )
                                        .padding(Edge.Set.vertical, 5)
                                        .contentShape(Rectangle())
                                        .onTapGesture(
                                                perform:
                                                {
                                                    self.on_tap(offset: history_enumerated.offset)
                                                }
                                                )
                            }
                            )
                            .onDelete(
                                    perform:
                                    {
                                        (index_set) in

                                        //self.history_records.remove(atOffsets: index_set)
                                        let new_index_set = IndexSet(
                                                index_set.map(
                                                    {
                                                        (index) in

                                                        self.history_records.count - index - 1
                                                    }
                                                )
                                            )
                                        self.history_records.remove(atOffsets: new_index_set)
                                    }
                                    )
                }
                )
                .alert(
                        Text(LocalizedStringKey(self.alter_title)),
                        isPresented: self.$is_alter_presenting,
                        actions:
                        {
                        },
                        message:
                        {
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


    private func on_tap(offset: Int) -> Void
    {
        let index = history_records.count - offset - 1

        do
        {
            try self.history_records[index].set_url()
        }
        catch
        {
            self.alter_title = String(localized: "File not found.")
            self.is_alter_presenting = true

            return
        }

        self.history_records[index].set_availability()

        guard self.history_records[index].is_available == true
        else
        {
            self.alter_title = String(localized: "File not available.")
            self.is_alter_presenting = true

            return
        }


        if let file_index = self.text_files.firstIndex(
                    where:
                    {
                        (element) in

                        if self.history_records[index].url.path == element.path
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

            self.current_file_index = file_index
        }
        else
        {
            // Not opened.

            if (
                (self.text_files.count == 1) &&
                (self.text_files[0].on_disk == false)
            )
            {
                // Replace first untitled file.

                do
                {
                    self.text_files[0] = try EtonTextDocument(
                            url: self.history_records[index].url
                            )
                }
                catch
                {
                    self.errorWrapper = ErrorWrapper(
                            error: error,
                            guidance: String(localized: "Try again later.")
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
                            try EtonTextDocument(
                                    url: self.history_records[index].url
                                    )
                            )
                }
                catch
                {
                    self.errorWrapper = ErrorWrapper(
                            error: error,
                            guidance: String(localized: "Try again later.")
                        )

                    return
                }

                self.current_file_index = self.text_files.count - 1
            }
        }

        self.history_records.move(
                fromOffsets: IndexSet(integer: index),
                toOffset: self.history_records.count - 1
                )

        dismiss()
    }
}



#Preview
{
    HistoryView(
            text_files: .constant(EtonTextDocument.sample_data),
            current_file_index: .constant(0),
            history_records: .constant(History.sample_data),
            errorWrapper: .constant(nil)
            )
}
