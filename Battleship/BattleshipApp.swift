//
//  BattleshipApp.swift
//  Battleship
//
//  Created by Marilyne LEAM on 15/07/2024.
//

import SwiftUI

//Définit la classe AppState pour gérer l'état global de l'application

class AppState: ObservableObject {
	@Published var shouldResetGame: Bool = false
	
	// Initialise l'état de l'application
	init() {
		shouldResetGame = true
	}
	
	
	// Fonction pour réinitialiser le jeu
	func resetGame() {
		shouldResetGame = false
	}
}


// Début de l'application
@main
struct BattleshipApp: App {
	@StateObject private var appState = AppState()
	
	// Définit la structure de l'interface de l'application
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(appState)
		}
	}
}
