//
//  ContentView.swift
//  Battleship
//
//  Created by Marilyne LEAM on 15/07/2024.
//

import SwiftUI

// Définit les différents états du jeu
enum GameState {
	case difficulty, placement, shooting, score
}

// Vue principale de l'application
struct ContentView: View {
	// Création d'une instance de GameModel en tant qu'objet d'état
	@StateObject private var gameModel = GameModel()
	// État actuel du jeu
	@State private var gameState: GameState = .difficulty
	// Difficulté sélectionnée par l'utilisateur
	@State private var selectedDifficulty: Difficulty = .medium
	
	var body: some View {
		NavigationView {
			VStack {
				// Affiche différentes vues en fonction de l'état du jeu
				switch gameState {
					case .difficulty:
						DifficultySelectionView(selectedDifficulty: $selectedDifficulty)
							.onDisappear {
								// Met à jour la difficulté du jeu dans le modèle de jeu lorsque la vue disparaît
								gameModel.setDifficulty(selectedDifficulty)
							}
					case .placement:
						// Vue pour placer les navires sur la grille
						PlacementView(gameModel: gameModel, gameState: $gameState)
					case .shooting:
						// Vue pour gérer les tirs pendant le jeu
						ShootingView(gameModel: gameModel, gameState: $gameState)
					case .score:
						// Vue pour afficher le score à la fin du jeu
						ScoreView(gameModel: gameModel, gameState: $gameState)
				}
				
				// Bouton pour commencer le jeu
				if gameState == .difficulty {
					Button("Commencer") {
						// Change l'état du jeu à 'placement' pour commencer le placement des navires
						gameState = .placement
					}
					.padding()
				}
			}
		}
		// Cache le bouton de retour de la barre de navigation
		.navigationBarBackButtonHidden(true)
	}
}
