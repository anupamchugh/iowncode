//
//  ContentView.swift
//  SwiftUICombineURLSession
//
//  Created by Anupam Chugh on 15/02/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI
import Combine


struct ContentView: View {
    @ObservedObject var hnFeed = HackerNewsFeed()
    
    var body: some View {
        NavigationView{
            List(hnFeed.hnItems){ articleItem in
                
                NewsListItemView(article: articleItem)
                    .onAppear(perform: {
                        
                        if !self.hnFeed.endOfList{
                            if self.hnFeed.shouldLoadMore(articleItem: articleItem){
                                self.hnFeed.fetchStories()
                            }
                        }
                    })
            }
            .alert(isPresented: $hnFeed.endOfList) {
                Alert(title: Text("Oops"), message: Text("No more results"), dismissButton: .default(Text("OK")))
            }
            .navigationBarTitle("Hacker News Stories")
        }
    }
}

struct NewsListItemView: View {
    var article: HNItem
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("\(article.title)")
                .font(.headline)
            Text("Author: \(article.author)")
                .font(.subheadline)
        }
    }
}

struct HNResponse: Codable {
    var hits: [HNItem]
    var exhaustiveNbHits : Bool
    var parseError = false
    
    private enum CodingKeys: String, CodingKey {
        case hits, exhaustiveNbHits
    }
}


struct HNItem : Identifiable, Codable{
    var id = UUID()
    
    public var title: String
    public var author: String
    
    private enum CodingKeys: String, CodingKey {
        case title, author
    }
}

class HackerNewsFeed : ObservableObject{
    
    @Published var hnItems = [HNItem]()
    
    var pageStatus = PageStatus.ready(nextPage: 0)
    var urlBase = "https://hn.algolia.com/api/v1/search_by_date?tags=story&hitsPerPage=10&page="
    @Published var endOfList = false
    
    var cancellable : Set<AnyCancellable> = Set()
    
    init() {
        fetchStories()
    }
    
    func shouldLoadMore(articleItem : HNItem) -> Bool{
        
        if let lastId = hnItems.last?.id{
            if articleItem.id == lastId{
                return true
            }
            else{
                return false
            }
        }
        
        return false
    }
    
    func fetchStories()
    {
        guard case let .ready(page) = pageStatus else {
            return
        }
        
        pageStatus = .loading(page: page)
        
        URLSession.shared.dataTaskPublisher(for: URL(string: "\(urlBase)\(page)")!)
            
            .tryMap { output in
                guard let _ = output.response as? HTTPURLResponse else {
                    throw MyError.httpError
                }
                return output.data
                
            }
            .decode(type: HNResponse.self, decoder: JSONDecoder())
            .replaceError(with: HNResponse(hits: [], exhaustiveNbHits: false, parseError: true))
            .eraseToAnyPublisher()
            .tryFilter{
                if $0.exhaustiveNbHits
                {
                    throw MyError.limitError
                }
                else if $0.parseError{
                    throw MyError.parseError
                }
                
                return true
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
            
            switch completion {
            case .finished:
                print("completed")
                break
            case .failure(let error):
                
                self.endOfList = true
                self.pageStatus = .done
                
                switch error {
                case MyError.limitError:
                    print("handle limit error")
                case MyError.httpError:
                    print("handle http error")
                case MyError.parseError:
                    print("handle http error")
                default:
                    print("handle default error")
                }
                
            }
        }) { post in
            
            if post.hits.count == 0{
                self.pageStatus = .done
            }
            else{
                self.pageStatus = .ready(nextPage: page + 1)
                self.hnItems.append(contentsOf: post.hits)
            }
        }
        .store(in: &cancellable)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum MyError: Error {
    case limitError
    case httpError
    case parseError
}

enum PageStatus {
    case ready (nextPage: Int)
    case loading (page: Int)
    case done
}
