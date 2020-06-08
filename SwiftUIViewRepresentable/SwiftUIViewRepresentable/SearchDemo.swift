//
//  SearchView.swift
//  SwiftUIViewRepresentable
//
//  Created by Anupam Chugh on 07/05/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI

struct SearchDemo: View {
    let weeks = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @State private var searchText : String = ""

    var body: some View {
        NavigationView {
            VStack {
                SearchBarView(text: $searchText, placeholder: "Type here")
                List {
                    ForEach(self.weeks.filter {
                        self.searchText.isEmpty ? true : $0.lowercased().contains(self.searchText.lowercased())
                    }, id: \.self) { day in
                        Text(day)
                    }
                }.navigationBarTitle(Text("DaysOfAWeek"))
            }
        }
    }
}


struct SearchBarView: UIViewRepresentable {

    @Binding var text: String
    var placeholder: String

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar,
                      context: Context) {
        uiView.text = text
    }
}

class Coordinator: NSObject, UISearchBarDelegate {

    @Binding var text: String

    init(text: Binding<String>) {
        _text = text
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        text = searchText
    }
}

struct SearchDemo_Previews: PreviewProvider {
    static var previews: some View {
        SearchDemo()
    }
}
