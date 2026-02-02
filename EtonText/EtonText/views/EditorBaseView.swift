//
//  EditorBaseView.swift
//  EtonText
//
//  Created by FENG Jian-Chao on 2024-03-05.
//

import SwiftUI

struct EditorBaseView: UIViewRepresentable
{
    @Binding var text: String

    func makeCoordinator() -> Coordinator
    {
        return Coordinator()
    }


    func makeUIView(context: Context) -> UITextView
    {
        return context.coordinator.uikit_text_view
    }


    func updateUIView(_ uikit_text_view: UITextView, context: Context)
    {
        // Record where the cursor is
        var cursorOffset: Int?
        if let selectedRange = uikit_text_view.selectedTextRange
        {
            cursorOffset = uikit_text_view.offset(
                    from: uikit_text_view.beginningOfDocument,
                    to: selectedRange.start
                    )
        }
        else
        {
        }

        // Update the field - this will displace the cursor
        uikit_text_view.text = self.text

        // Put the cursor back
        if let offset = cursorOffset,
            let position = uikit_text_view.position(
                    from: uikit_text_view.beginningOfDocument,
                    offset: offset
                    )
        {
            uikit_text_view.selectedTextRange = uikit_text_view.textRange(
                    from: position,
                     to: position
                     )

            uikit_text_view.scrollRangeToVisible(uikit_text_view.selectedRange)
        }
        else
        {
        }

        // we don't usually pass bindings in to the coordinator and instead
        // use closures.
        // we have to set a new closure because the binding might be different.
        context.coordinator.update_text =
        {
            (text) in

            self.text = text
        }
    }


    class Coordinator: NSObject, UITextViewDelegate
    {

        lazy var uikit_text_view: UITextView =
        {
            let text_view = UITextView()
            text_view.font = UIFont.monospacedSystemFont(
                    ofSize: UIFont.preferredFont(
                            forTextStyle: UIFont.TextStyle.body
                            )
                            .pointSize,
                    weight: UIFont.Weight.regular
                    )
            text_view.delegate = self

            //
            // Accessory
            //
            let doneToolbar: UIToolbar = UIToolbar(
                    frame: CGRect.init(
                            x: 0, y: 0,
                             width: UIScreen.main.bounds.width,
                             height: 50
                             )
                    )
            doneToolbar.barStyle = UIBarStyle.default

            let item_flexSpace: UIBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: UIBarButtonItem.SystemItem
                            .flexibleSpace,
                    target: nil,
                    action: nil
                    )
            let item_done: UIBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                    target: self,
                    action: #selector(self.doneButtonAction)
                    )

            doneToolbar.items = [
                    item_flexSpace,
                    item_done
                    ]
            doneToolbar.sizeToFit()

            text_view.inputAccessoryView = doneToolbar

            return text_view
        }()

        var update_text: ((String) -> Void)?


        func textViewDidChange(_ uikit_text_view: UITextView)
        {
            self.update_text?(uikit_text_view.text)
        }


        @objc func doneButtonAction()
        {
            self.uikit_text_view.resignFirstResponder()
        }


//        func textViewDidEndEditing(_ uikit_text_view: UITextView)
//        {
//          // Handle text view ending editing (optional)
//        }
    }
}
