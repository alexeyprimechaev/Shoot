//
//  ShootApp.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import SwiftUI

@main
struct ShootApp: App {
    var body: some Scene {
        WindowGroup {
            Text("")
                .withHostingWindow { window in
                    let reflectView =
                    ContentView().statusBar(hidden: true)
                    window?.rootViewController =
                    HideHomeIndicatorController(rootView: reflectView)
                }
        }
    }
}

class HideHomeIndicatorController<Content:View>: UIHostingController<Content> {
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
}

extension View {
    func withHostingWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        self.background(HostingWindowFinder(callback: callback))
    }
}

struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
