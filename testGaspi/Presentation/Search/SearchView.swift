//
//  SearchView.swift
//  testGaspi
//
//  Created by José Guadalupe Martínez Lugo on 18/08/26.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("Buscar productos")
            .searchable(text: $viewModel.queryText, prompt: "Buscar productos")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            historyList
        case .loading:
            ProgressView("Buscando...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let products):
            resultsList(products)
        case .empty:
            ContentUnavailableFallbackView(
                message: "No se encontraron productos para \u{201C}\(viewModel.queryText)\u{201D}.",
                systemImage: "magnifyingglass"
            )
        case .error(let message):
            ContentUnavailableFallbackView(message: message, systemImage: "exclamationmark.triangle")
        }
    }

    @ViewBuilder
    private var historyList: some View {
        if viewModel.history.isEmpty {
            ContentUnavailableFallbackView(
                message: "Escribe para buscar productos.",
                systemImage: "magnifyingglass"
            )
        } else {
            List {
                Section("Búsquedas recientes") {
                    ForEach(viewModel.history) { term in
                        Button {
                            viewModel.selectHistory(term)
                        } label: {
                            Label(term.query, systemImage: "clock")
                        }
                        .foregroundColor(.primary)
                    }
                }
                Button("Borrar historial", role: .destructive) {
                    viewModel.clearHistory()
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    private func resultsList(_ products: [Product]) -> some View {
        List(products) { product in
            Button {
                viewModel.didSelect(product)
            } label: {
                ProductRowView(product: product)
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }
}
