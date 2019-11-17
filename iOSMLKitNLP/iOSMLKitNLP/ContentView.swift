//
//  ContentView.swift
//  iOSMLKitNLP
//
//  Created by Anupam Chugh on 16/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import SwiftUI
import FirebaseMLNaturalLanguage
import FirebaseMLNLSmartReply
import FirebaseMLNLTranslate

struct ContentView: View {
    
    @State var inputText: String = ""
    @State var languageIdentified: String = ""
    @State var smartReplyInOriginalLanguage: String = ""

    var body: some View {
        
        VStack(alignment: .center, spacing: 20){
            TextField("Enter some text", text: $inputText)
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
            Text(smartReplyInOriginalLanguage)

            Button(action: identifyLanguage, label: {
                Text("Smart Reply").foregroundColor(.blue)
            })
        }
    }
    
    
    func identifyLanguage(){
        let languageId = NaturalLanguage.naturalLanguage().languageIdentification()
        
        languageId.identifyLanguage(for: inputText) { (languageCode, error) in
            if let error = error {
                print("Failed with error: \(error)")
                return
            }
            if let languageCode = languageCode, languageCode != "und" {
                self.languageIdentified = languageCode
                self.identifyLanguageCode()
                
            } else {
                self.smartReplyInOriginalLanguage = "No language was identified"
            }
        }
    }
    
    func identifyLanguageCode(){
        
        let allLanguages = TranslateLanguage.allLanguages()
        var languageCode = TranslateLanguage.en.rawValue
        
        for number in allLanguages{
                
                let language = TranslateLanguage(rawValue: UInt(truncating: number))
                
                if let code = language?.toLanguageCode(){
                    if self.languageIdentified == code{
                        languageCode = UInt(truncating: number)
                        break
                    }
                }
        }
        
        translateToEnglish(languageCode: languageCode)

    }
    
    func translateToEnglish(languageCode: UInt)
    {
        let options = TranslatorOptions(sourceLanguage: TranslateLanguage(rawValue: languageCode)!, targetLanguage: .en)
        let translator = NaturalLanguage.naturalLanguage().translator(options: options)
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: true,
            allowsBackgroundDownloading: true
        )
        translator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
            
            translator.translate(self.inputText){
                (translatedText, error) in

                guard error == nil,
                    let translatedText = translatedText
                    else {return }
                
                self.generateEnSmartReply(text: translatedText){
                    englishReply in
                    
                    self.translateToIdentifiedLanguage(languageCode: languageCode, englishSmartReply: englishReply)
                }
            }
        }
    }
    

    func generateEnSmartReply(text: String,  completionHandler: @escaping (String) -> Void)
    {
        var conversation: [TextMessage] = []
        let message = TextMessage(
            text: text,
            timestamp: Date().timeIntervalSince1970,
            userID: "userId",
            isLocalUser: false)
        conversation.append(message)
        
        let naturalLanguage = NaturalLanguage.naturalLanguage()
        naturalLanguage.smartReply().suggestReplies(for: conversation) { result, error in
            guard error == nil, let result = result else {
                return
            }
            if (result.status == .notSupportedLanguage) {
                completionHandler("Language Not Supported")
            } else if (result.status == .success) {
                
                completionHandler(result.suggestions[0].text)
            }
            else if result.status == .noReply{
                completionHandler("Offensive text. No Reply")
            }
        }
    }
    
    func translateToIdentifiedLanguage(languageCode: UInt, englishSmartReply: String){

        let options = TranslatorOptions(sourceLanguage: .en, targetLanguage: TranslateLanguage(rawValue: languageCode)!)
        let translator = NaturalLanguage.naturalLanguage().translator(options: options)
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: true,
            allowsBackgroundDownloading: true
        )
        translator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
            
            translator.translate(englishSmartReply){
                (translatedText, error) in

                guard error == nil,
                    let translatedText = translatedText
                    else {return }
                self.smartReplyInOriginalLanguage = translatedText
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
