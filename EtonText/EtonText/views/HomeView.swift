//
//  HomeView.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-03-10.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View
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

    @State private var is_alter_presenting: Bool = false
    @State private var alter_title: String = String()


    var body: some View
    {
        List(
                content:
                {
                    Section(
                            content:
                            {
                                Button(
                                        action:
                                        {
                                            self.text_files.append(EtonTextDocument())
                                            self.current_file_index = self.text_files.count - 1
                                            self.untitled_count += 1
                                        },
                                        label: { Label(LocalizedStringKey("New"), systemImage: "plus") }
                                        )
                                Button(
                                        action: { self.is_open_presenting = true },
                                        label: { Label(LocalizedStringKey("Open"), systemImage: "doc") }
                                        )
                            },
                            header:
                            {
                                Text(LocalizedStringKey("Actions"))
                            }
                            )
                    Section(
                            content:
                            {
                                ForEach(
                                        Array(self.history_records.suffix(EtonTextApp.home_history_limit).reversed().enumerated()),
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
                                                                                .lineLimit(1)
                                                                                .truncationMode(.head)
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

                                if (self.history_records.count > EtonTextApp.home_history_limit)
                                {
                                    HStack(
                                            content:
                                            {
                                                Spacer()
                                                Button(
                                                        action:
                                                        {
                                                            self.is_history_presenting = true
                                                        },
                                                        label:
                                                        {
                                                            Label(LocalizedStringKey("More"), systemImage: "ellipsis")
                                                                    .labelStyle(.iconOnly)
                                                        }
                                                        )
                                                Spacer()
                                            }
                                            )
                                }
                                else
                                {
                                }
                            },
                            header:
                            {
                                Text(LocalizedStringKey("Recent files"))
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
                                    placement: ToolbarItemPlacement.primaryAction,
                                    content:
                                    {
                                        Menu(
                                                content:
                                                {
                                                    Button(
                                                            action:
                                                            {
                                                                self.text_files.append(EtonTextDocument())
                                                                self.current_file_index = self.text_files.count - 1
                                                                self.untitled_count += 1
                                                            },
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
                                                            action: { self.is_help_presenting = true },
                                                            label: { Label(LocalizedStringKey("Help"), systemImage: "questionmark.circle") }
                                                            )
                                                    Button(
                                                            action: { self.is_support_presenting = true },
                                                            label: { Label(LocalizedStringKey("About"), systemImage: "message") }
                                                            )
                                                },
                                                label: { Label(LocalizedStringKey("Menu"), systemImage: "ellipsis.circle") }
                                                )
                                    }
                                    )
                        }
                        )
    }


    private func on_tap(offset: Int) -> Void
    {
        let index = self.history_records.count - offset - 1

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


        do
        {
            self.text_files.append(
                    try EtonTextDocument(url: self.history_records[index].url)
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

        self.history_records.move(
                fromOffsets: IndexSet(integer: index),
                toOffset: self.history_records.count
            )
    }

}



#Preview
{
    HomeView(
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
