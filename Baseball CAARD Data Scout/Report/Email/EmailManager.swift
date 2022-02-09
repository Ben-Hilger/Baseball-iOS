//
//  EmailManager.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/21/21.
//

import Foundation
import UIKit
import SwiftUI
import MessageUI


struct MailView: UIViewControllerRepresentable {

    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?

    @Binding var pdfURL: URL!
    var subject: String
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(isShowing: Binding<Bool>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                isShowing = false
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing,
                           result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(subject)
        vc.setToRecipients(["hilgerbj@miamioh.edu"])
        if let data = NSData(contentsOfFile: pdfURL.absoluteString) {
            vc.addAttachmentData(Data(data), mimeType: "application/pdf",
                                 fileName: "PitchingChart.pdf")
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
