//
//  CommentView.swift
//  SwiftUIHNSentiments
//
//  Created by Anupam Chugh on 20/02/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI
import Combine
import NaturalLanguage


struct CommentView : View{
    
    @ObservedObject var commentFeed = HNCommentFeed()
    
    var body: some View {
    
        List(commentFeed.comments){ item in
    
            Text(item.sentimentScore)
                .background(((item.sentimentScore as NSString).floatValue >= 0.0) ? Color.green : Color.red)
                .frame(alignment: .trailing)
            
            Text(item.text ?? "")
            
        }
        .navigationBarTitle("Comment Score \(commentFeed.sentimentAvg)")
        .navigationBarItems(trailing: (((commentFeed.sentimentAvg as NSString).floatValue >= 0.0) ? Image(systemName: "smiley.fill").foregroundColor(Color.green) : Image(systemName: "smiley.fill").foregroundColor(Color.red)))
    }

    init(commentIds: [Int]) {
        commentFeed.getIds(ids: commentIds)
    }
}


class HNCommentFeed : ObservableObject{
    
    let nlTagger = NLTagger(tagSchemes: [.sentimentScore])
    let didChange = PassthroughSubject<Void, Never>()
    var cancellable : Set<AnyCancellable> = Set()
    
    @Published var sentimentAvg : String = ""
    
    var comments = [CommentItem](){
        didSet {
            
            var sumSentiments : Float = 0.0
            
            for item in comments{
                let floatValue = (item.sentimentScore as NSString).floatValue
                sumSentiments += floatValue
            }
            
            let  ave = (sumSentiments) / Float(comments.count)
            sentimentAvg = String(format: "%.2f", ave)
            didChange.send()
        }
    }
    
    private var commentIds = [Int]() {
        didSet {
            fetchComments(ids: commentIds.prefix(10))
        }
    }
    
    func fetchComments<S>(ids: S) where S: Sequence, S.Element == Int{

        Publishers.MergeMany(ids.map{FetchComment(id: $0, nlTagger: nlTagger)})
        .collect()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: {
            if case let .failure(error) = $0 {
                print(error)
            }
        }, receiveValue: {

            self.comments = self.comments + $0
        })
        .store(in: &cancellable)
    }

    func getIds(ids: [Int]){
        self.commentIds = ids
    }
}

struct FetchComment: Publisher {
    typealias Output = CommentItem
    typealias Failure = Error

    let id: Int
    let nlTagger: NLTagger

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let request = URLRequest(url: URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!)
        URLSession.DataTaskPublisher(request: request, session: URLSession.shared)
            .map { $0.data }
            .decode(type: CommentItem.self, decoder: JSONDecoder())
            .map{
                commentItem in
 
                let data = Data(commentItem.text?.utf8 ?? "".utf8)
                var commentString = commentItem.text
                
                
                if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                    commentString = attributedString.string
                }
                
                self.nlTagger.string = commentString

                var sentimentScore = ""
                if let string = self.nlTagger.string{

                    let (sentiment,_) = self.nlTagger.tag(at: string.startIndex, unit: .paragraph, scheme: .sentimentScore)
                    sentimentScore = sentiment?.rawValue ?? ""
                }

                let result = CommentItem(id: commentItem.id, text: commentString, sentimentScore: sentimentScore)
                return result
            }
            .print()
            .receive(subscriber: subscriber)
    }
}

