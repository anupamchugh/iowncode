//
//  ContentView.swift
//  SwiftUIGestures
//
//  Created by Anupam Chugh on 04/12/19.
//  Copyright © 2019 iowncode. All rights reserved.



import SwiftUI

struct ContentView : View {

    @EnvironmentObject var observer : SwipeObserver
    
    var body : some View{
        
        GeometryReader{geo in
            
            ZStack{
                
                ForEach(self.observer.cards){card in
                    
                    
                    Rectangle()
                        .foregroundColor(card.color)
                        .cornerRadius(20)
                        .frame(width: geo.size.width-40, height: geo.size.height - 80, alignment: .center)
                        .gesture(DragGesture()
                            
                            .onChanged({ (value) in
                                
                                if value.translation.width > 0{
                                    
                                    if value.translation.width > 30{
                                        self.observer.update(id: card, value: value.translation.width, degree: 12)
                                    }
                                    else{
                                        self.observer.update(id: card, value: value.translation.width, degree: 0)
                                    }
                                }
                                else{
                                    
                                    if value.translation.width < -30{
                                        self.observer.update(id: card, value: value.translation.width, degree: -12)
                                    }
                                    else{
                                        self.observer.update(id: card, value: value.translation.width, degree: 0)
                                    }
                                }
                                
                            }).onEnded({ (value) in
                                
                                if card.drag > 0{

                                    if card.drag > geo.size.width / 2 - 40{
                                        self.observer.update(id: card, value: 500, degree: 0)
                                    }
                                    else{
                                        self.observer.update(id: card, value: 0, degree: 0)
                                    }
                                }
                                else{

                                    if -card.drag > geo.size.width / 2 - 40{
                                        self.observer.update(id: card, value: -500, degree: 0)
                                    }
                                    else{

                                        self.observer.update(id: card, value: 0, degree: 0)
                                    }
                                }
                                
                            })
                    ).offset(x: card.drag)
                        .scaleEffect(abs(card.drag) > 80 ? 0.8 : 1)
                        .rotationEffect(.init(degrees:card.degree))
                        .animation(.spring())
                    
                }
            }
        }
    }
}


class SwipeObserver : ObservableObject{
    
    @Published var cards = [Cards]()
    @Published var last = -1
    
    init() {
        
        self.cards.append(Cards(id: 0, drag: 0, degree: 0, color: Color.purple))
        self.cards.append(Cards(id: 1, drag: 0, degree: 0, color: Color.green))
        self.cards.append(Cards(id: 2, drag: 0, degree: 0, color: Color.yellow))
        self.cards.append(Cards(id: 3, drag: 0, degree: 0, color: Color.red))
        self.cards.append(Cards(id: 4, drag: 0, degree: 0, color: Color.blue))
        self.cards.append(Cards(id: 5, drag: 0, degree: 0, color: Color.orange))
        
    }
    
    func update(id : Cards,value : CGFloat,degree : Double){
        
        for i in 0..<self.cards.count{
            
            if self.cards[i].id == id.id{
                
                self.cards[i].drag = value
                self.cards[i].degree = degree
                self.last = i
            }
        }
    }
}

struct Cards : Identifiable {
    
    var id : Int
    var drag : CGFloat
    var degree : Double
    var color : Color
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


