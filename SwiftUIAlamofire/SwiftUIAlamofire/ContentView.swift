//
//  ContentView.swift
//  SwiftUIAlamofire
//
//  Created by Anupam Chugh on 06/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    @ObservedObject var observed = Observer()
    
    var body: some View {
        NavigationView{
            List(observed.jokes){ i in
                HStack{Text(i.joke)}
                }.navigationBarItems(
                  trailing: Button(action: addJoke, label: { Text("Add") }))
            .navigationBarTitle("SwiftUI Alamofire")
        }
    }
    
    func addJoke(){
        observed.getJokes(count: 1)
    }
}

struct JokesData : Identifiable{
    
    public var id: Int
    public var joke: String
}

class Observer : ObservableObject{
    @Published var jokes = [JokesData]()

    init() {
        getJokes()
    }
    
    func getJokes(count: Int = 5)
    {
        Alamofire.request("http://api.icndb.com/jokes/random/\(count)")
            .responseJSON{
                response in
                if let json = response.result.value {
                    if  (json as? [String : AnyObject]) != nil{
                        if let dictionaryArray = json as? Dictionary<String, AnyObject?> {
                            let jsonArray = dictionaryArray["value"]

                            if let jsonArray = jsonArray as? Array<Dictionary<String, AnyObject?>>{
                                for i in 0..<jsonArray.count{
                                    let json = jsonArray[i]
                                    if let id = json["id"] as? Int, let jokeString = json["joke"] as? String{
                                    self.jokes.append(JokesData(id: id, joke: jokeString))
                                    }
                                }
                            }
                        }
                    }
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
