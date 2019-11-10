//
//  ContentView.swift
//  iOSNLPRottenTomatoes
//
//  Created by Anupam Chugh on 10/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import SwiftUI
import NaturalLanguage

struct ContentView: View {
    
    var reviews : [Reviews] = [Reviews(review: "For all its flash-back/flash-forward tricksiness, The Irishman rarely seems disjointed or thematically fractured."),
                               Reviews(review: "Edgy and intriguing, reminding younger generations what happened more than 70 years ago."),
                               Reviews(review: "The emotional impact of Two Days, One Night is overwhelming, a tearful experience.")]
    
    @State var nlModelResult: String = ""
    @State var nlpResult : String = ""
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    
    var body: some View {
        
        NavigationView{
            List(reviews){
                i in
                NavigationLink(destination: ReviewDetail(review: i.review)) {
                    Text(i.review)
                }
            }
        }.navigationBarTitle("NLP And Core ML")
            
        
    }
}

struct Reviews: Identifiable{
    var id = UUID()
    var review : String
}

struct ReviewDetail: View {
    var review: String
    
    @State var mlPrediction = ""
    @State var nlpResult = ""
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    
    var reviewPredictor : NLModel?
    
    var body: some View {
        
        return VStack{
            Text(review)
            Button(action:{
                
                self.tagger.string = self.review
                if let string = self.tagger.string{
                    let (sentiment,_) = self.tagger.tag(at: string.startIndex, unit: .paragraph, scheme: .sentimentScore)
                    
                    self.nlpResult = "\(sentiment?.rawValue ?? "")"
                }
                
            }){
                Text("Run Sentiment Analysis")
            }.padding()
            Text(self.nlpResult)
            Button(action:{
                self.runPrediction()
                
            }){
                Text("Run Core ML Prediction")
            }.padding()
            Text(self.mlPrediction)
        }
    }
    
    func runPrediction(){
        do{
            let reviewPredictor = try NLModel(mlModel: ReviewTextClassifier().model)
            let label = reviewPredictor.predictedLabel(for: self.review)
            
            self.mlPrediction = label ?? ""
            
        }catch(let error){
            print("error is \(error.localizedDescription)")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct NLPBuiltInSentimentView: View {
    
    
    @State var name: String = ""
    @State var nlpResult = ""
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    
    var body: some View {
        
        VStack{
            
            TextField("Enter here", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .multilineTextAlignment(.center)
            
            Text(self.nlpResult)
            
            Button(action: {
                
                self.tagger.string = self.name
                let (sentiment, _) = self.tagger.tag(at: self.name.startIndex, unit: .paragraph, scheme: .sentimentScore)
                
                if let sentiment = sentiment?.rawValue{
                    self.nlpResult = "\(sentiment)"
                }
                
            }){
                Text("Process NLP")
            }
        }
        
    }
}
