//
//  DrPhos_Chem_HelperApp.swift
//  DrPhos Chem Helper
//
//  Created by Monte Helm on 1/24/24.
//

import SwiftUI

@main
struct DrPhos_Chem_HelperApp: App {

    init() {
        let reviewRequestPolicy = ReviewRequestPolicy()
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-ResetReviewRequestState") {
            reviewRequestPolicy.reset()
        }
#endif
        reviewRequestPolicy.recordLaunch()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                
        }
    }
}
