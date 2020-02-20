//
//  ContentView.swift
//  SwiftUIHNSentiments
//
//  Created by Anupam Chugh on 18/02/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI
import Combine


struct ContentView: View {
    @ObservedObject var hnFeed = HNStoriesFeed()
    
    var body: some View {
        NavigationView{
            List(hnFeed.storyItems){ articleItem in
                
                NavigationLink(destination: LazyView(CommentView(commentIds: articleItem.kids ?? []))){
                    StoryListItemView(article: articleItem)
                }
            }
            .navigationBarTitle("Hacker News Stories")
        }
    }
}


struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}


struct StoryListItemView: View {
    var article: StoryItem
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("\(article.title ?? "")")
                .font(.headline)
            Text("Author: \(article.by)")
                .font(.subheadline)
        }
    }
}


class HNStoriesFeed : ObservableObject{

    @Published var storyItems = [StoryItem]()
    var urlBase = "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"

    var cancellable : Set<AnyCancellable> = Set()
        
    private var topStoryIds = [Int]() {
        didSet {
            fetchStoryById(ids: topStoryIds.prefix(10))
        }
    }

    init() {
        fetchTopStories()
    }

    func fetchStoryById<S>(ids: S) where S: Sequence, S.Element == Int{

        Publishers.MergeMany(ids.map{FetchItem(id: $0)})
        .collect()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: {
            if case let .failure(error) = $0 {
                print(error)
            }
        }, receiveValue: {
            self.storyItems = self.storyItems + $0
        })
        .store(in: &cancellable)
        
    }
    
    func fetchTopStories(){

        URLSession.shared.dataTaskPublisher(for: URL(string: "\(urlBase)")!)
        .map{$0.data}
        .decode(type: [Int].self, decoder: JSONDecoder())
        .sink(receiveCompletion: { completion in
          switch completion {
          case .failure(let error):
            print("Something went wrong: \(error)")
          case .finished:
            print("Received Completion")
          }
        }, receiveValue: { value in
            self.topStoryIds = value
        })
        .store(in: &cancellable)

    }
}


struct FetchItem: Publisher {
    typealias Output = StoryItem
    typealias Failure = Error

    let id: Int

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let request = URLRequest(url: URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!)
        URLSession.DataTaskPublisher(request: request, session: URLSession.shared)
            .map { $0.0 }
            .decode(type: StoryItem.self, decoder: JSONDecoder())
            .receive(subscriber: subscriber)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension Float {
    func round(to places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
