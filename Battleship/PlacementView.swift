//
//  PlacementView.swift
//  Battleship
//
//  Created by Marilyne LEAM on 15/07/2024.
//

import SwiftUI

// Vue pour le placement des navires
struct PlacementView: View {
	// ObservedObject pour observer les changements dans le modèle de jeu
	@ObservedObject var gameModel: GameModel
	// Binding pour accéder et modifier l'état du jeu
	@Binding var gameState: GameState
	// État local pour le type de navire sélectionné
	@State private var selectedShipType: ShipType?
	// État local pour l'orientation du navire (horizontal ou vertical)
	@State private var isHorizontal = true
	// État local pour suivre les navires placés
	@State private var placedShips: [ShipType: Bool] = [:]
	
	var body: some View {
		VStack {
			Text("Placez vos navires")
				.font(.largeTitle)
			
			// Boucle ForEach pour afficher des boutons pour chaque type de navire
			ForEach(ShipType.allCases, id: \.self) { shipType in
				Button(action: {
					// Action à effectuer lorsque le bouton est cliqué
					selectedShipType = shipType
				}) {
					// Texte du bouton affichant le nom et la taille du navire
					Text("\(shipType.rawValue) (\(shipType.size) cases)")
				}
				// Désactiver le bouton si le navire est déjà placé
				.disabled(placedShips[shipType] == true)
			}
			
			// Toggle pour sélectionner l'orientation du navire
			Toggle("Horizontal", isOn: $isHorizontal)
				.padding()
			
			// Vue de la grille pour placer les navires
			GridView(grid: gameModel.player1Grid) { x, y, state in
				Button(action: {
					if let shipType = selectedShipType {
						// Placer le navire si un type de navire est sélectionné
						if gameModel.placeShip(for: 1, type: shipType, at: (x, y), isHorizontal: isHorizontal) {
							// Marquer le navire comme placé
							placedShips[shipType] = true
							// Désélectionner le type de navire
							selectedShipType = nil
							// Si tous les navires sont placés, passer à l'état de tir
							if placedShips.count == ShipType.allCases.count {
								// Placer les navires de l'ordinateur
								gameModel.placeComputerShips()
								// Changer l'état du jeu à "shooting"
								gameState = .shooting
							}
						}
					}
				}) {
					// Contenu de la cellule en fonction de son état
					cellContent(for: state)
				}
			}
		}
		.padding()
	}
	
	// Fonction pour déterminer le contenu de la cellule en fonction de son état
	func cellContent(for state: CellState) -> some View {
		ZStack {
			// Arrière-plan de la cellule
			Rectangle()
				.frame(width: 50, height: 50)
			
			// Contenu de la cellule en fonction de son état
			switch state {
				case .empty:
					EmptyView()
				case .ship:
					Rectangle()
						.fill(Color.blue)
				case .hit, .miss, .sunk:
					EmptyView()
			}
		}
	}
}
