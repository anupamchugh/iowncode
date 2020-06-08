//
//  ContentView.swift
//  SwiftUIContactSearch
//
//  Created by Anupam Chugh on 08/06/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI
import Contacts

struct ContentView: View {
    
    @EnvironmentObject var store: ContactStore
    @State private var searchText : String = ""

    var body: some View {
        NavigationView {
            VStack {
                SearchBarView(text: $searchText, placeholder: "Type here")
                List{
                    
                    ForEach(self.store.contacts.filter{
                        self.searchText.isEmpty ? true : $0.givenName.lowercased().contains(self.searchText.lowercased())
                    }, id: \.self.name) {
                        (contact: CNContact) in
                        
                        VStack(alignment: .leading){
                            Text(contact.name).font(.headline)
                            Text(contact.phoneNumbers.first?.value.stringValue ?? "").font(.subheadline)
                        }
                        
                    }
                }.onAppear{
                    DispatchQueue.main.async {
                        self.store.fetchContacts()
                    }
                }
                .navigationBarTitle(Text("SwiftUI Contacts"))
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
        searchBar.showsCancelButton = true
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ContactStore())
    }
}



class ContactStore: ObservableObject {
    
    @Published var contacts: [CNContact] = []
    @Published var error: Error? = nil
    
     func fetchContacts() {
        
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            
            if granted {

                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                request.sortOrder = .givenName
                
                do {

                    var contactsArray = [CNContact]()
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        if (contact.phoneNumbers.first?.value.stringValue) != nil{
                            contactsArray.append(contact)
                        }
                    })
                    
                    self.contacts = contactsArray
                    
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }
}


extension CNContact: Identifiable {
    var name: String {
        return [givenName, familyName].filter{ $0.count > 0}.joined(separator: " ")
    }
}

