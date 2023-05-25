//
//  StrengthExerciseView.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 24/05/2023.
//

import SwiftUI
import UIKit

class StrengthExerciseViewDataModel: ObservableObject {
    @Published var isAnimating = false
}

struct StrengthExerciseView: View {
    
    @ObservedObject var model: StrengthExerciseViewDataModel
    var waveColor: Color
    var amplify: CGFloat
    var backgroundColor: Color
    
    var body: some View {
        Group {
            if model.isAnimating {
                WaveForm(color: waveColor, amplify: amplify, isReversed: false, isAnimating: model.isAnimating)
            }
        }
        .background(backgroundColor)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct StrengthExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        StrengthExerciseView(model: StrengthExerciseViewDataModel(), waveColor: .purple, amplify: 300, backgroundColor: .yellow)
    }
}
