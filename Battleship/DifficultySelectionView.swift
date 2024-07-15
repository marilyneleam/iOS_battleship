//
//  DifficultySelectionView.swift
//  Battleship
//
//  Created by Marilyne LEAM on 15/07/2024.
//

import SwiftUI

// Vue pour la sélection de la difficulté
struct DifficultySelectionView: View {
	// Binding pour accéder et modifier la difficulté sélectionnée
	@Binding var selectedDifficulty: Difficulty
	// État local pour activer ou désactiver des éléments de l'interface
	@State private var isEnable = false
	
	var body: some View {
		VStack {
			// Titre de la vue
			Text("Sélectionnez la difficulté")
				.font(.largeTitle)
				.padding()
			
			// Boucle ForEach pour afficher un bouton pour chaque niveau de difficulté
			ForEach(Difficulty.allCases, id: \.self) { difficulty in
				Button(action: {
					// Action à effectuer lorsque le bouton est cliqué
					selectedDifficulty = difficulty
					isEnable = true
				}) {
					// Texte du bouton affichant le nom de la difficulté
					Text(difficulty.rawValue)
						.padding()
						.frame(maxWidth: .infinity)
					// Change la couleur de fond du bouton en fonction de la difficulté sélectionnée
						.background(selectedDifficulty == difficulty ? Color.indigo : Color.gray.opacity(0.3))
						.foregroundColor(.white)
						.cornerRadius(10)
				}
				.padding(.horizontal)
			}
		}
	}
}

// Enumération pour représenter les différents niveaux de difficulté
enum Difficulty: String, CaseIterable {
	case easy = "Facile"
	case medium = "Moyen"
	case hard = "Difficile"
}

