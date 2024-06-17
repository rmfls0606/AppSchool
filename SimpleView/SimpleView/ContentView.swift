//
//  ContentView.swift
//  SimpleView
//
//  Created by 이상민 on 6/17/24.
//

import SwiftUI

struct ContentView: View {
    @State private var text = ""
    
    var body: some View {
        List{
            Label("Hello World", systemImage: "globe")
            HStack{
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(Color.accentColor)
                Text("Hello, world!")
            }
            .font(.system(.body, design: .monospaced))
            TextField("TextField", text: $text)
            Button("Tap me"){
                self.text = "You Tapped Me!"
            }
        }
    }
}

#Preview {
    ContentView()
}
