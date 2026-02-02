//
//  SupportView.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-03-08.
//

import SwiftUI

struct SupportView: View
{
    @Environment(\.dismiss) private var dismiss

    var body: some View
    {
        List(
                content:
                {
                    Section(
                            content:
                            {
                                HStack(
                                        content:
                                        {
                                            Text(LocalizedStringKey("Name"))
                                            Spacer()
                                            Text("EtonText").foregroundColor(Color.secondary)
                                        }
                                        )
                                HStack(
                                        content:
                                        {
                                            Text(LocalizedStringKey("Description"))
                                            Spacer()
                                            Text("Text editor with tab pages").foregroundColor(Color.secondary)
                                        }
                                        )
                                HStack(
                                        content:
                                        {
                                            Text(LocalizedStringKey("Version"))
                                            Spacer()
                                            Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A").foregroundColor(Color.secondary)
                                        }
                                        )
                            },
                            header:
                            {
                                Text(LocalizedStringKey("App info"))
                            },
                            footer:
                            {
                            }
                            )
                    Section(
                            content:
                            {
                                HStack(
                                        content:
                                        {
                                            Text(LocalizedStringKey("China mainland"))
                                            Spacer()
                                            Link(
                                                    "豫ICP备2024069750号-1A",
                                                    destination: URL(string: "https://beian.miit.gov.cn/")!
                                                    )
                                        }
                                        )
                            },
                            header:
                            {
                                Text(LocalizedStringKey("Legal & Regulatory"))
                            },
                            footer:
                            {
                            }
                            )
                    Section(
                            content:
                            {
                                HStack(
                                        content:
                                        {
                                            Text(LocalizedStringKey("Email"))
                                            Spacer()
                                            Text("fjc-525@qq.com").foregroundColor(Color.secondary)
                                        }
                                        )
                            },
                            header:
                            {
                                Text(LocalizedStringKey("Feedback and suggestions"))
                            },
                            footer:
                            {
        //                        Text(LocalizedStringKey("Please feel free to contact me."))
                            }
                            )
                }
                )
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
    SupportView(
            )
}
