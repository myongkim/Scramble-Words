//
//  ContentView.swift
//  Scramble
//
//  Created by Isaac Kim on 4/8/22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            //sf symbol has a 1.circle and so and so for
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
                
            }
            .navigationTitle(rootWord)
            // modifier for the textField
            .onSubmit {
                addNewWord()
            }
            .toolbar(content: {
                Button("Reset Words") {
                    startGame()
                  
                }
            })
            .safeAreaInset(edge: .bottom) {
                Text("Score: \(score)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .font(.title)
                    
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button(errorTitle, role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            
            
        }
       
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        guard longerThan(word: answer) else {
            wordError(title: "Need more than 3 letters", message: "Type more than 3 letters")
            return
        }
        guard sameWordCheck(word: answer) else {
            wordError(title: "Same word Error", message: "Need to use different words")
            return
        }
        
        // Extra validation to come
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        // can give animation with withAnimation
        withAnimation {
            usedWords.insert(answer, at: 0)
            score += newWord.count
            
            newWord = ""
        }
    }
    
    func startGame() {
        
        newWord = ""
        usedWords.removeAll()
        score = 0
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                //                print("this is startwords: \(startWords)")
                
                //compoentns sepratedBy: "\(n)" will make line of word into array
                let allWords = startWords.components(separatedBy: "\n")
                
                //                print("this is all words \(allWords)")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                print("this is pos: \(pos)")
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func longerThan(word: String) -> Bool {
        word.count > 2
    }
    func sameWordCheck(word: String) -> Bool {
       word != rootWord
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
