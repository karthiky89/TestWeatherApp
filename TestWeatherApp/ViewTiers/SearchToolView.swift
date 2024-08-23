//
//  SearchToolView.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/20/24.
//

import SwiftUI

struct SearchToolView: View {
    @Binding var isShowingSearchOptions: Bool
    @State private var searchText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    let isLoading: Bool // Boolean to indicate if loading
    let onSearch: (String) -> Void // Callback for search action

    var body: some View {
        if !isLoading {
            HStack {
                TextField("Enter City name or ZIP code", text: $searchText, onCommit: {
                    performSearch()
                })
                .padding(8)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1) // Light border
                )
                .focused($isTextFieldFocused)
                .transition(.opacity) // Fade in/out effect
                .animation(.easeInOut(duration: 0.3), value: searchText)
                
                // Always visible Search Button
                Button(action: {
                    performSearch()
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                }
                .padding()
            }
            .onChange(of: isTextFieldFocused) { focused in
                if !focused {
                    searchText = "" // Clear the text field when focus is lost
                }
            }
            .onDisappear {
                searchText = "" // Clear the text field when view disappears
                isTextFieldFocused = false // Dismiss the keyboard
            }
        }
    }
    
    private func performSearch() {
        // Perform the search action
        onSearch(searchText) // Pass the search text
        searchText = "" // Clear the text field
        isShowingSearchOptions = false
        isTextFieldFocused = false // Dismiss the keyboard
    }
}

