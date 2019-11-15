//
//  ContentView.swift
//  CoreMLRecommender
//
//  Created by Anupam Chugh on 15/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import SwiftUI
import Combine
import CoreML


struct ContentView: View {
    @ObservedObject var topRecommendations = Recommender()
    
    var body: some View {
        NavigationView {
            List(topRecommendations.movies) { movie in
                VStack (alignment: .leading) {
                    Text(movie.name)
                    Text("\(movie.score)")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
                }
            }.navigationBarTitle("CoreMLRecommender", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



public class Recommender: ObservableObject {
    
    @Published var movies = [Movie]()
    
    init(){
        load()
    }
    
    func load() {
        do{
            let recommender = MovieRecommender()
            
            let ratings : [String: Double] = ["Home Alone": 3.0, "Titanic": 3.5]
            let input = MovieRecommenderInput(items: ratings, k: 5, restrict_: [], exclude: [])
            
            let result = try recommender.prediction(input: input)
            var tempMovies = [Movie]()
            
            for str in result.recommendations{
                let score = result.scores[str] ?? 0
                tempMovies.append(Movie(name: "\(str)", score: score))
            }
            self.movies = tempMovies
            
        }catch(let error){
            print("error is \(error.localizedDescription)")
        }
        
    }
}

struct Movie: Identifiable {
    public var id = UUID()
    public var name: String
    public var score: Double
    
}
