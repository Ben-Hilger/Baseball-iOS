//
//  PDFView.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 9/23/21.
//
import SwiftUI
import PDFKit

struct PDFViewUI : UIViewControllerRepresentable {
    
    @Binding var url : URL!
    
    func makeUIViewController(context: Context) -> PrintViewController {
        let controller = PrintViewController()
        controller.url = url
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: PrintViewController, context: Context) {}
    
    typealias UIViewControllerType = PrintViewController
}

class PrintViewController : UIViewController {
    
    var url : URL!
    
    override func viewDidLoad() {
        // UIPrintInteractionController presents a user interface and manages the printing
        let printController = UIPrintInteractionController.shared

        // UIPrintInfo contains information about the print job
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = url.absoluteString
        printInfo.duplex = .none
        printInfo.orientation = .portrait
        
        printController.printPageRenderer = nil
        printController.printingItems = nil
        printController.printingItem = url
        

        printController.printInfo = printInfo
        // Present print controller like usual view controller. Also completionHandler is available if needed.
        printController.present(animated: true)

    }
}

