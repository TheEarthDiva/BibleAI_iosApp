//
//  ContentView.swift
//  BibleAI
//
//  Created by Maria Green on 1/14/23.
//

import OpenAISwift
import SwiftUI

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "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")
    }
    
    func send(text: String,
              completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text,
                               maxTokens: 400,
                               completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                completion(output)
            case .failure:
                break
            }
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    var body: some View {
        VStack {
            Image("betterbyDailogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250)
            VStack(alignment: .leading) {
                ScrollView {
                    ForEach(models, id: \.self) { string in
                        Text(string)
                    }
                }
                Spacer()
                HStack {
                    TextField("What should your devotion be about?", text: $text)
                    Button("Go") {
                        send()
                    }
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.setup()
        }
        .padding()
    }
    
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        models.removeAll()
        let concText = "Write a religious devotional about " + text + ". Then reference some bible verses about " + text + ". Then create 3 journaling prompts about " + text + "."
        models.append("You requested a devotion about \(text)")
        viewModel.send(text: concText) { response in
            DispatchQueue.main.async {
                self.models.append(response)
                self.text = ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
