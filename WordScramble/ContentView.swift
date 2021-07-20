//
//  ContentView.swift
//  WordScramble
//
//  Created by 山崎宏哉 on 2021/07/03.
//

import SwiftUI
import Foundation
import CoreServices

struct ContentView: View {
  @State private var usedWordsWithDefinition: [String:String] = [:]
  @State private var rootWord = ""
  @State private var newWord = ""

  @State private var errorTitle = ""
  @State private var errorMessage = ""
  @State private var showingError = false

  @State private var score: Int = 0
  @State private var highestScore: Int = 0

  static let highestScoreKey = "highestScore"

  var body: some View {
    NavigationView {
      VStack {
        TextField("Enter your word", text: $newWord, onCommit: addNewWord)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .autocapitalization(.none)
          .padding()
          .disabled(rootWord.isEmpty)
        List(usedWordsWithDefinition.keys.map{$0}, id: \.self) { word in
          HStack {
            Image(systemName: "\(word.count).circle")
            NavigationLink(word, destination: WordDefinition(definition: usedWordsWithDefinition[word]!))
          }
          .accessibilityElement(children: .ignore)
          .accessibility(label: Text("\(word), \(word.count) letters"))
        }
        Section {
          Text("Score: \(score)")
          Text("Highest Score: \(getHighestScore)")
        }
        .font(.title3)
        .foregroundColor(.primary)
        .padding(.bottom, 40)
      }
      .navigationBarTitle(rootWord.isEmpty ? "Word Scramble" : rootWord)
      .navigationBarItems(
        leading:
          Button(action: {
            usedWordsWithDefinition = [:]
            score = 0
            startGame()
          }, label: {
            Text("Start New Game")
          })
      )
//      .onAppear(perform: startGame)
      .alert(isPresented: $showingError) {
        Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
      }
    }
  }

  var getHighestScore: Int {
    UserDefaults.standard.integer(forKey: ContentView.highestScoreKey)
  }

  func addNewWord() {
    let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

    guard answer.count > 0 else {
      return
    }

    guard isOriginal(word: answer) else {
      wordError(title: "Word used already", message: "Be more original")
      return
    }

    guard isPossible(word: answer) else {
      wordError(title: "Word not recognized", message: "you can't just make them up, you know!")
      return
    }

    guard isReal(word: answer) else {
      wordError(title: "Word not possible", message: "That isn't a real word")
      return
    }

    // extra validation to come
    let definition = getDefinition(from: answer)
    usedWordsWithDefinition[answer] = definition
    score += answer.count
    if highestScore < score {
      UserDefaults.standard.set(score, forKey: "highestScore")
    }
    newWord = ""
  }

  func getDefinition(from word: String) -> String {
    var defineStr: String = ""
    if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word) {
      let ref = UIReferenceLibraryViewController(term: word)
      let defValue = ref.value(forKeyPath: "_definitionValues") as! NSArray
      let define = (defValue[0] as AnyObject).value(forKey: "_definition")
      defineStr = (define as AnyObject).value(forKey: "string") as! String
      
//      let defineArray = defineStr.components(separatedBy: "\n")

    } else {
      defineStr = "Definition not found."
    }
    return defineStr
  }

  func startGame() {
    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
      if let startWords = try? String(contentsOf: startWordsURL) {
        let allWords = startWords.components(separatedBy: "\n")
        rootWord = allWords.randomElement() ?? "silkworm"
        return
      }
    }

    fatalError("Could not load start.txt from bundle.")
  }

  func isOriginal(word: String) -> Bool {
    !usedWordsWithDefinition.keys.contains(word)
  }

  func isPossible(word: String) -> Bool {
    var tempWord = rootWord.lowercased()

    if word.count == 1 {
      return false
    }

    for letter in word {
      if let pos = tempWord.firstIndex(of: letter) {
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
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .previewDevice("iPhone 12")
  }
}
