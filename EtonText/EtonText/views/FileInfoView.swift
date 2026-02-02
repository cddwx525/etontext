//
//  FileInfoView.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-03-05.
//

import SwiftUI

struct FileInfoView: View
{
    var text_file: EtonTextDocument?

    @Environment(\.dismiss) private var dismiss

    var body: some View
    {
        VStack(
                content:
                {
                    HStack(
                            content:
                            {
                                Text(self.text_file?.basename ?? "").font(Font.title).padding(Edge.Set.horizontal)
                                Spacer()
                            }
                            )
                    List(
                            content:
                            {
                                HStack(
                                        content:
                                        {
                                            Text(LocalizedStringKey("Type"))
                                                    .foregroundColor(Color.secondary)
                                                    .font(Font.subheadline)
                                            Spacer()
                                            Text(self.text_file?.type ?? "")
                                        }
                                        )
                                HStack(
                                        content:
                                        {
                                            Text(LocalizedStringKey("Encoding"))
                                                    .foregroundColor(Color.secondary)
                                                    .font(Font.subheadline)
                                            Spacer()
                                            Text(self.text_file?.encoding ?? "")
                                        }
                                        )
                                HStack(
                                        content:
                                        {
                                            Text(LocalizedStringKey("Size"))
                                                    .foregroundColor(Color.secondary)
                                                    .font(Font.subheadline)
                                            Spacer()
                                            Text(self.text_file?.size ?? "")
                                            Text(LocalizedStringKey("bytes"))
                                        }
                                        )
                                HStack(
                                        content:
                                        {
                                            Text(LocalizedStringKey("Created"))
                                                    .foregroundColor(Color.secondary)
                                                    .font(Font.subheadline)
                                            Spacer()
                                            Text(self.text_file?.create_date ?? "")
                                        }
                                        )
                                HStack(
                                        content:
                                        {
                                            Text(LocalizedStringKey("Modified"))
                                                    .foregroundColor(Color.secondary)
                                                    .font(Font.subheadline)
                                            Spacer()
                                            Text(self.text_file?.modified_date ?? "")
                                        }
                                        )
                                HStack(
                                        content:
                                        {
                                            Text(LocalizedStringKey("Path"))
                                                    .foregroundColor(Color.secondary)
                                                    .font(Font.subheadline)
                                            Spacer()
                                            Text(self.text_file?.path ?? "")
                                        }
                                        )
                            }
                            )
                            .listStyle(PlainListStyle())
                }
                )
                .padding()
                .toolbar(
                        content:
                        {
                            ToolbarItem(
                                    placement: ToolbarItemPlacement.confirmationAction,
                                    content:
                                    {
                                        Button(
                                                action:
                                                {
                                                    dismiss()
                                                },
                                                label: { Text(LocalizedStringKey("Done")) }
                                                )
                                    }
                                    )
                        }
                        )
    }
}


#Preview
{
    FileInfoView(
            text_file: EtonTextDocument.sample_data[0]
            )
}
