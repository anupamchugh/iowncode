//
//  ContentView.swift
//  PythonKitBasics
//
//  Created by Anupam Chugh on 24/08/20.
//  Copyright © 2020 Anupam Chugh. All rights reserved.
//

import SwiftUI
import PythonKit
import AVKit


struct VideoView: View {
    
    @State private var txt : String = ""
    @State private var videoPath : String? = ""
    
    var dirPath : String
    
    var body: some View {
    
        VStack{

            TextField("Enter the video link", text: $txt)
            
            Button(action: {
                self.downloadVideo(link: self.txt)
            }, label: {
                Text("Download Video")
            })
            
            //for iOS 14 and macOS 11+
            if let videoPath = videoPath{
                
                let url = URL(fileURLWithPath:dirPath+videoPath)
                VideoPlayer(player: AVPlayer(url: url))
            }
        }
    }
    
    func downloadVideo(link: String){
        let sys = Python.import("sys")
        sys.path.append(dirPath)
        let example = Python.import("sample")
        let response = example.downloadVideo(link, dirPath)
        videoPath = String(response)
    }
}

struct ContentView: View {
    @State var result : String = ""
    @State var swapA : Int = 2
    @State var swapB : Int = 3
    var dirPath = "/Users/anupamchugh/Desktop/workspace/"
    
    var body: some View {
        HStack{
            VStack{
                Button(action: {
                    self.runPythonCode()
                }, label: {
                    Text("Run Python Script")
                })
                Text("\(result)")
            }
            VStack{
                Button(action: {
                    self.swapNumbersInPython()
                }, label: {
                    Text("Swap Numbers")
                })
                HStack{
                    Text("\(swapA)")
                    Text("\(swapB)")
                }
            }
            
            VideoView(dirPath: dirPath)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    func runPythonCode(){
        let sys = Python.import("sys")
        sys.path.append(dirPath)
        let example = Python.import("sample")
        let response = example.hello()
        result = response.description
    }
    func swapNumbersInPython(){
        let sys = Python.import("sys")
        sys.path.append(dirPath)
        let example = Python.import("sample")
        let response = example.swap(swapA, swapB)
        let a : [Int] = Array(response)!
        swapA = a[0]
        swapB = a[1]
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


