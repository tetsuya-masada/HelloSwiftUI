//
//  ContentView.swift
//  HelloSwiftUI
//
//  Created by 正田哲也 on 2024/06/09.
//

import SwiftUI

// ユーザの選択肢
enum UserChoice: String, CaseIterable {
    case rock = "rock-red"
    case paper = "paper-red"
    case scissors = "scissors-red"
}

// PCの選択肢
enum ComputerChoice: String, CaseIterable {
    case rock = "rock-green"
    case paper = "paper-green"
    case scissors = "scissors-green"
}

struct ContentView: View {
    @State var computerChoice: ComputerChoice = .rock
    @State var showLabel: Bool = false
    @State var isTextVisible: Bool = true
    @State var totalGames: Int = 0  // プレイしたゲームの総数を追跡
    @State var lostGames: Int = 0  // 負けたゲームの数を追跡
    @State var isWaiting: Bool = false  // 待機中かどうかを追跡するための変数
    @State var waitCount: Int = 0  // 表示するメッセージを決定するためのカウンタ
    @State var selectedChoice: UserChoice?  // ユーザーが選択した選択肢を追跡
    @State var wonGames: Int = 0  // 勝ったゲームの数を追跡
    @State var message: String = "" // 勝敗結果のメッセージを追跡
    
    var waitMessage: String {  // 追加: 待機中に表示するメッセージを計算するプロパティ
        switch waitCount {
        case 0: return "Rock,Paper,Scissors,"
        case 1: return "Rock,Paper,Scissors, one..."
        case 2: return "Rock,Paper,Scissors, one, two..."
        case 3: return "Rock,Paper,Scissors, one, two, three!"
        default: return "three"
        }
    }
    
    var body: some View {
        VStack {
            Text("")
                .onAppear{
                    Task{
                        isWaiting = true
                        // 選択後に3秒待つ。その間は、"rock", "paper", "scissors", "one", "two", "three"のメッセージを順に表示
                        for i in 0..<4 {
                            waitCount = i
                            do {
                                try await Task.sleep(nanoseconds: UInt64(1_000_000_000))  // 0.5秒待つ
                            }
                        }
                    }
                }
            HStack {
                ForEach(UserChoice.allCases,id:\.self) { choice in
                    Button {
                        selectedChoice = choice  // ユーザーが選択した事を記録
                        showLabel = false
                        Task {
                            
                            // コンピュータがランダムに手を選ぶ
                            let choices = ComputerChoice.allCases
                            let randomIndex = Int.random(in: 0..<choices.count)
                            computerChoice = choices[randomIndex]
                            
                            totalGames += 1
                            
                            // 勝敗判断
                            if (computerChoice.rawValue == "rock-green" && choice.rawValue == "scissors-red") ||
                                (computerChoice.rawValue == "scissors-green" && choice.rawValue == "paper-red") ||
                                (computerChoice.rawValue == "paper-green" && choice.rawValue == "rock-red") {
                                message = "You are Loser."
                                lostGames += 1
                            } else if computerChoice.rawValue.prefix(4) == choice.rawValue.prefix(4) { // 同じ手を出した場合
                                message = "It's a Draw."
                            } else {
                                message = "You are Winner."
                                wonGames += 1
                            }
                            
                            try? await Task.sleep(nanoseconds: UInt64(100_000_000))  // 一瞬待つ
                            isWaiting = false
                            showLabel = true
                        }
                    } label: {
                        Image(choice.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding()
                            .background(
                                Rectangle()
                                    .stroke(choice == selectedChoice ? Color.red : Color.clear, lineWidth: 3)  // 選択された選択肢に赤い縁取りを追加
                            )
                    }
                }
            }
            
            if isWaiting {
                Text(waitMessage)  // 追加: 待機中に表示するメッセージ
                    .font(.largeTitle)
                    .foregroundColor(.blue)
            }
            if showLabel {
                VStack {
                    Text("The computer chose \(computerChoice)")
                    Image(computerChoice.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Text(message)
                        .font(.system(size: 30))
                        .foregroundColor(.red)
                    Text("\(totalGames) games played.")
                    Text("\(wonGames) games won.")
                    Text("\(lostGames) games lost.")
                    Text("\(totalGames - wonGames - lostGames) games draw.")
                    Text("")
                    Button{
                        showLabel = false
                        selectedChoice = nil
                        Task {
                            isWaiting = true
                            // 選択後に3秒待つ。その間は、"rock", "paper", "scissors", "one", "two", "three"のメッセージを順に表示
                            for i in 0..<4 {
                                waitCount = i
                                do {
                                    try await Task.sleep(nanoseconds: UInt64(1_000_000_000))  // 0.5秒待つ
                                }
                            }
                        }
                    }label: {
                        Text("　Re Start!!　")
                            .font(.system(size: 20))
                    }
                    .border(Color.blue, width: 2)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
