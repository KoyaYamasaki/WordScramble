//
//  DictionaryView.swift
//  WordScramble
//
//  Created by 山崎宏哉 on 2021/07/20.
//

import SwiftUI

struct DictionaryView: UIViewControllerRepresentable {
    let word: String

    func makeUIViewController(context: Context) -> UIReferenceLibraryViewController {      
      return UIReferenceLibraryViewController(term: word)
    }

    func updateUIViewController(_ uiViewController: UIReferenceLibraryViewController, context: Context) {
    }

  
}

struct DictionaryView_Previews: PreviewProvider {
    static var previews: some View {
      DictionaryView(word: "word")
    }
}
