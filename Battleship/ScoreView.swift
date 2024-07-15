//
//  ScoreView.swift
//  Battleship
//
//  Created by Marilyne LEAM on 15/07/2024.
//

import SwiftUI

// Vue pour afficher le score à la fin de la partie
struct ScoreView: View {
	// Observer les changements dans le modèle de jeu
	@ObservedObject var gameModel: GameModel
	// Binding pour accéder et modifier l'état du jeu
	@Binding var gameState: GameState
	
	var body: some View {
		VStack {
			Text("Fin de partie")
				.font(.largeTitle)
				.padding()
			
			// Affiche le score du joueur 1
			Text("Score du Joueur 1 : \(gameModel.playerHits)")
				.font(.title)
				.padding()
			
			// Affiche le score du joueur 2
			Text("Score du Joueur 2 : \(gameModel.computerHits)")
				.font(.title)
				.padding()
			
			// Affiche le gagnant en fonction des scores
			if gameModel.playerHits == 17 {
				Text("Le joueur 1 a gagné")
					.font(.title)
					.padding()
			} else {
				Text("Le joueur 2 a gagné")
					.font(.title)
					.padding()
			}
			
			// Bouton pour rejouer la partie
			Button("Rejouer") {
				// Réinitialise le modèle de jeu
				gameModel.resetGame()
				// Revient à l'état de sélection de la difficulté
				gameState = .difficulty
			}
			.padding()
		}
	}
}
