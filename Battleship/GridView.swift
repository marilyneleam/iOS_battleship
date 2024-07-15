//
//  GridView.swift
//  Battleship
//
//  Created by Marilyne LEAM on 15/07/2024.
//

import SwiftUI

// Vue pour afficher une grille
struct GridView<Content: View>: View {
	// Propriété pour stocker l'état de la grille (un tableau 2D)
	let grid: [[CellState]]
	// Closure pour générer le contenu de chaque cellule de la grille
	let content: (Int, Int, CellState) -> Content
	
	var body: some View {
		VStack(spacing: 0) {
			// Boucle ForEach pour créer les lignes de la grille
			ForEach(0..<grid.count, id: \.self) { row in
				HStack(spacing: 0) {
					// Boucle ForEach pour créer les colonnes de la grille
					ForEach(0..<grid[row].count, id: \.self) { column in
						// Utilise la closure pour générer le contenu de chaque cellule
						content(row, column, grid[row][column])
							.frame(width: 50, height: 50)  // Définir la taille de chaque cellule
							.border(Color.black, width: 1)  // Ajouter une bordure noire autour de chaque cellule
					}
				}
			}
		}
		.padding()  // Ajouter du padding autour de la grille
	}
}
