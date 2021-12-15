//
//  ContentView.swift
//  SwiftUIMenuBar
//

import SwiftUI
import LaunchAtLogin

struct ContentView: View {
    let delegate = NSApplication.shared.delegate as! AppDelegate
    @State var quantity: Double = 0
    
    var body: some View {
        VStack (alignment: .center, spacing: 20) {
            Stepper("Seconds to clip: \(Int(quantity))", value: $quantity, in: 1...120)
            LaunchAtLogin.Toggle()
            Button(
                action: {
                    delegate.clipper.openClipDir()
                },
                label: { Text("Show All Clips") }
            )
            Button(
                action: {
                    NSApplication.shared.terminate(self)
                },
                label: { Text("Quit App") }
            )
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: quantity) { _ in
                // Whenever the clip seconds are changed,
                // propagate that change to the clipper (and UserDefaults)
                self.delegate.clipper.updateClipSeconds(quantity: quantity)
            }
            .onAppear {
                // Get quantity from clipper
                // on init
                quantity = self.delegate.clipper.clipSeconds
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

