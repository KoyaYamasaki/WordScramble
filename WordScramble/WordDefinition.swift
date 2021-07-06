//
//  WordDefinition.swift
//  WordScramble
//
//  Created by 山崎宏哉 on 2021/07/03.
//

import SwiftUI

struct WordDefinition: View {
  let definition: String

  var body: some View {
    ScrollView {
      Text(definition as! String)
    }
  }
}

struct WordDefinition_Previews: PreviewProvider {
  static var previews: some View {
    WordDefinition(definition: "Test")
  }
}
