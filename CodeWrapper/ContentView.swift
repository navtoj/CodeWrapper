//
//  ContentView.swift
//  CodeWrapper
//
//  Created by Navtoj Chahal on 2024-09-22.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			VStack(alignment: .leading) {
				Text("Code Wrapper")
					.font(.largeTitle)
					.padding(.bottom, 5)
				if let link = URL(string: "https://github.com/navtoj/codewrapper") {
					Link("Navtoj Chahal", destination: link)
				}
			}
			VStack(alignment: .leading) {
				Text("How to Install")
					.font(.title)
					.padding(.bottom, 20)
				VStack(alignment: .leading, spacing: 5) {
					Text("- Open System Preferences")
					Text("- Select 'Extensions'")
					Text("- Select 'Xcode Source Editor'")
					Text("- Enable 'Code Wrapper'")
				}
			}
			VStack(alignment: .leading) {
				Text("How to Use")
					.font(.title)
					.padding(.bottom, 20)
				VStack(alignment: .leading, spacing: 5) {
					Text("- Open Xcode and start editing a source file")
					Text("- Highlight the line that you want to wrap")
					Text("- Choose '#if DEBUG' from the menu under Editor -> Code Wrapper")
				}
			}
		}
		.padding()
	}
}

#Preview {
	ContentView()
}
