//
//  ErrorView.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-03-08.
//

import SwiftUI

struct ErrorView: View
{
    let errorWrapper: ErrorWrapper

    @Environment(\.dismiss) private var dismiss
    
    var body: some View
    {
        VStack(
                content:
                {
                    Text(LocalizedStringKey("An error has occurred!"))
                        .font(.title)
                        .padding(.bottom)
                    Text(errorWrapper.error.localizedDescription)
                        .font(.headline)
                    Text(LocalizedStringKey(errorWrapper.guidance))
                        .font(.caption)
                        .padding(.top)
                    Spacer()
                }
                )
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .toolbar(
                        content:
                        {
                            ToolbarItem(
                                    placement: .navigationBarTrailing,
                                    content:
                                    {
                                        Button(LocalizedStringKey("Done"))
                                        {
                                            dismiss()
                                        }
                                    }
                                    )
                        }
                        )
    }
}


#Preview
{
    ErrorView(errorWrapper: ErrorWrapper.smaple_data[0])
}
