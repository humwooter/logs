//
//  PreviewViewController.swift
//  ThemeThumbnailPreview
//
//  Created by Katyayani G. Raman on 8/18/24.
//

import UIKit
import QuickLook

class PreviewViewController: UIViewController, QLPreviewingController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    /*
    func preparePreviewOfSearchableItem(identifier: String, queryString: String?) async throws {
        // Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.

        // Perform any setup necessary in order to prepare the view.
        // Quick Look will display a loading spinner until this returns.
    }
    */

    func preparePreviewOfFile(at url: URL) async throws {
        // Add the supported content types to the QLSupportedContentTypes array in the Info.plist of the extension.

        // Perform any setup necessary in order to prepare the view.

        // Quick Look will display a loading spinner until this returns.
    }

}
