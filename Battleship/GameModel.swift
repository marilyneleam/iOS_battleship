//
//  GameModel.swift
//  Battleship
//
//  Created by Marilyne LEAM on 15/07/2024.
//

import SwiftUI

// Définit les types de navires
enum ShipType: String, CaseIterable {
	case carrier = "Porte-Avion"
	case battleship = "Croiseur"
	case submarine1 = "Sous-Marin 1"
	case submarine2 = "Sous-Marin 2"
	case destroyer = "Torpilleur"
	
	// Retourne la taille de chaque type de navire
	var size: Int {
		switch self {
			case .carrier: return 5
			case .battleship: return 4
			case .submarine1, .submarine2: return 3
			case .destroyer: return 2
		}
	}
}

// Définit les états possibles d'une cellule de la grille
enum CellState {
	case empty, ship, hit, miss, sunk
}

// Structure d'un navire
struct Ship: Identifiable {
	let id = UUID() // Identifiant unique pour chaque navire
	let type: ShipType // Type de navire
	var positions: [(Int, Int)] // Positions occupées par le navire
	var hits: Int = 0 // Nombre de fois où le navire a été touché
	
	// Vérifie si le navire est coulé
	var isSunk: Bool {
		hits >= type.size
	}
}

// Modèle du jeu
class GameModel: ObservableObject {
	
	// Propriétés du jeu
	@Published var player1Grid: [[CellState]] = Array(repeating: Array(repeating: .empty, count: 10), count: 10)
	@Published var player2Grid: [[CellState]] = Array(repeating: Array(repeating: .empty, count: 10), count: 10)
	@Published var player1Ships: [Ship] = []
	@Published var player2Ships: [Ship] = []
	@Published var playerHits = 0
	@Published var computerHits = 0
	@Published var difficulty: Difficulty = .medium
	
	// Fonction pour définir la difficulté du jeu
	func setDifficulty(_ difficulty: Difficulty) {
		self.difficulty = difficulty
	}
	
	// Fonction pour gérer le placement des navires
	func placeShip(for player: Int, type: ShipType, at position: (Int, Int), isHorizontal: Bool) -> Bool {
		// Obtient les positions du navire en fonction du type, de la position de départ et de l'orientation
		let positions = getShipPositions(for: type, at: position, isHorizontal: isHorizontal)
		
		// Vérifie si les positions sont valides
		if !arePositionsValid(positions, for: player) {
			return false
		}
		
		// Met à jour la grille avec les positions du navire
		updateGrid(with: positions, for: player)
		// Ajoute le navire au joueur
		addShipToPlayer(type: type, positions: positions, for: player)
		
		return true
	}
	
	// Fonction pour obtenir les positions du navire en fonction du type, de la position de départ et de l'orientation
	private func getShipPositions(for type: ShipType, at position: (Int, Int), isHorizontal: Bool) -> [(Int, Int)] {
		let (startRow, startCol) = position
		return (0..<type.size).map { i in
			isHorizontal ? (startRow, startCol + i) : (startRow + i, startCol)
		}
	}
	
	// Fonction pour vérifier si les positions sont valides
	private func arePositionsValid(_ positions: [(Int, Int)], for player: Int) -> Bool {
		for pos in positions {
			if pos.0 >= 10 || pos.1 >= 10 || !isCellEmpty(at: pos, for: player) {
				return false
			}
			
			// Vérifie les cellules adjacentes pour éviter que les navires se touchent
			for dx in -1...1 {
				for dy in -1...1 {
					let checkPos = (pos.0 + dx, pos.1 + dy)
					if checkPos.0 >= 0 && checkPos.0 < 10 && checkPos.1 >= 0 && checkPos.1 < 10 {
						if !isCellEmpty(at: checkPos, for: player) && !positions.contains(where: { $0 == checkPos }) {
							return false
						}
					}
				}
			}
		}
		return true
	}
	
	// Fonction pour mettre à jour la grille avec les positions du navire
	private func updateGrid(with positions: [(Int, Int)], for player: Int) {
		for pos in positions {
			if player == 1 {
				player1Grid[pos.0][pos.1] = .ship
			} else {
				player2Grid[pos.0][pos.1] = .ship
			}
		}
	}
	
	// Fonction pour ajouter le navire au joueur
	private func addShipToPlayer(type: ShipType, positions: [(Int, Int)], for player: Int) {
		let ship = Ship(type: type, positions: positions)
		if player == 1 {
			player1Ships.append(ship)
		} else {
			player2Ships.append(ship)
		}
	}
	
	// Fonction pour vérifier si une cellule est vide
	func isCellEmpty(at pos: (Int, Int), for player: Int) -> Bool {
		let grid = player == 1 ? player1Grid : player2Grid
		return grid[pos.0][pos.1] == .empty
	}
	
	// Fonction pour gérer les tirs sur une grille
	func shoot(at row: Int, _ col: Int, on grid: inout [[CellState]], ships: inout [Ship]) -> (hit: Bool, sunk: Bool) {
		if grid[row][col] == .ship {
			grid[row][col] = .hit
			if let index = ships.firstIndex(where: { $0.positions.contains(where: { $0 == (row, col) }) }) {
				ships[index].hits += 1
				if ships[index].isSunk {
					for pos in ships[index].positions {
						grid[pos.0][pos.1] = .sunk
					}
					return (true, true)  // Touché et coulé
				}
				return (true, false)  // Touché mais pas coulé
			}
		} else if grid[row][col] == .empty {
			grid[row][col] = .miss
		}
		return (false, false)  // Manqué
	}
	
	// Fonction pour vérifier si le jeu est terminé
	func checkGameEnd() -> Bool {
		let player1SunkShips = player1Ships.filter { $0.isSunk }.count
		let player2SunkShips = player2Ships.filter { $0.isSunk }.count
		return player1SunkShips == player1Ships.count || player2SunkShips == player2Ships.count
	}
	
	// Fonction pour réinitialiser le jeu
	func resetGame() {
		player1Grid = Array(repeating: Array(repeating: .empty, count: 10), count: 10)
		player2Grid = Array(repeating: Array(repeating: .empty, count: 10), count: 10)
		player1Ships = []
		player2Ships = []
		playerHits = 0
		computerHits = 0
	}
	
	// Fonction pour placer aléatoirement les navires de l'ordinateur
	func placeComputerShips() {
		for shipType in ShipType.allCases {
			var placed = false
			while !placed {
				let row = Int.random(in: 0..<10)
				let col = Int.random(in: 0..<10)
				let isHorizontal = Bool.random()
				if placeShip(for: 2, type: shipType, at: (row, col), isHorizontal: isHorizontal) {
					placed = true
				}
			}
		}
	}
}
