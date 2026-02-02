//
//  HelpView.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-04-15.
//

import SwiftUI

struct HelpView: View
{
    @Environment(\.dismiss) private var dismiss

    var body: some View
    {
        ScrollView(
                Axis.Set.vertical,
                showsIndicators: true,
                content:
                {
                    Text(LocalizedStringKey("HELP_TEXT"))
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


#Preview {
    HelpView()
}
