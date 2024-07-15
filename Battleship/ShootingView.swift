//
//  ShootingView.swift
//  Battleship
//
//  Created by Marilyne LEAM on 15/07/2024.
//

import SwiftUI

struct ShootingView: View {
	// Observer les changements dans le modèle de jeu
	@ObservedObject var gameModel: GameModel
	// Binding pour accéder et modifier l'état du jeu
	@Binding var gameState: GameState
	// État local pour suivre le joueur actuel
	@State private var currentPlayer: Player = .player1
	// État local pour afficher un message de résultat
	@State private var message: String = ""
	
	// Enumération pour représenter les joueurs
	enum Player {
		case player1, player2
	}
	
	var body: some View {
		VStack {
			// Affiche un texte indiquant quel joueur doit attaquer
			Text("Joueur \(currentPlayer == .player1 ? "1" : "2"), Attaquez votre adversaire !")
				.font(.title)
				.padding()
			
			// Affiche le message de résultat
			Text(message)
				.font(.headline)
				.padding()
			
			// Affiche la grille pour le joueur actuel
			GridView(grid: currentPlayer == .player1 ? gameModel.player2Grid : gameModel.player1Grid) { x, y, state in
				Button(action: {
					let (hit, sunk) = shoot(at: (x, y))
					updateMessage(hit: hit, sunk: sunk)
					if gameModel.checkGameEnd() {
						gameState = .score
					} else {
						currentPlayer = currentPlayer == .player1 ? .player2 : .player1
						if currentPlayer == .player2 {
							DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
								computerMove()
							}
						}
					}
				}) {
					cellContent(for: state)
				}
				.disabled(currentPlayer == .player2 || state != .empty && state != .ship)
			}
		}
	}
	
	// Fonction pour gérer les tirs
	func shoot(at position: (Int, Int)) -> (hit: Bool, sunk: Bool) {
		if currentPlayer == .player1 {
			let result = gameModel.shoot(at: position.0, position.1, on: &gameModel.player2Grid, ships: &gameModel.player2Ships)
			if result.hit {
				gameModel.playerHits += 1
			}
			return result
		} else {
			let result = gameModel.shoot(at: position.0, position.1, on: &gameModel.player1Grid, ships: &gameModel.player1Ships)
			if result.hit {
				gameModel.computerHits += 1
			}
			return result
		}
	}
	
	// Fonction pour mettre à jour le message de résultat
	func updateMessage(hit: Bool, sunk: Bool) {
		if hit {
			message = sunk ? "Touché-coulé !" : "Touché !"
		} else {
			message = "À l'eau !"
		}
	}
	
	// Fonction pour déterminer le contenu de la cellule en fonction de son état
	func cellContent(for state: CellState) -> some View {
		ZStack {
			Rectangle()
				.fill(backgroundColor(for: state))
				.frame(width: 50, height: 50)
			
			switch state {
				case .empty:
					EmptyView()
				case .miss:
					Text("O")
						.foregroundColor(.blue)
						.font(.system(size: 30, weight: .bold))
				case .hit:
					Text("X")
						.foregroundColor(.red)
						.font(.system(size: 30, weight: .bold))
				case .sunk:
					ZStack {
						Circle()
							.stroke(Color.red, lineWidth: 2)
							.frame(width: 40, height: 40)
						Text("X")
							.foregroundColor(.red)
							.font(.system(size: 30, weight: .bold))
					}
				case .ship:
					if currentPlayer == .player2 {
						Rectangle()
							.fill(Color.blue)
							.frame(width: 42, height: 42)
					} else {
						EmptyView()
					}
			}
		}
	}
	
	// Fonction pour déterminer la couleur de fond de la cellule en fonction de son état
	func backgroundColor(for state: CellState) -> Color {
		switch state {
			case .empty:
				return Color.white
			case .miss, .hit, .sunk:
				return Color.green
			case .ship:
				return currentPlayer == .player2 ? Color.blue : Color.white
		}
	}
	
	// Fonction pour gérer le tour de l'ordinateur
	func computerMove() {
		var shotTaken = false
		while !shotTaken {
			let x = Int.random(in: 0..<10)
			let y = Int.random(in: 0..<10)
			if gameModel.player1Grid[y][x] == .empty || gameModel.player1Grid[y][x] == .ship {
				let (hit, sunk) = shoot(at: (y, x))
				updateMessage(hit: hit, sunk: sunk)
				shotTaken = true
				
				if gameModel.checkGameEnd() {
					gameState = .score
				} else {
					currentPlayer = .player1
				}
			}
		}
	}
}
