//
//  WordService.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import Foundation

// use actor to protect data from race conditions
actor WordService {
    func fetchRandomWord(length: Int = 5) async throws -> String { // async function that returns 5 letter string = secret word
        let urlString = "https://random-word-api.vercel.app/api?words=1&length=\(length)" // full url
        guard let url = URL(string: urlString) else { // convert string into array, if error -> standard URL error
            throw URLError(.badURL)
        }

        // fetch data
        let (data, _) = try await URLSession.shared.data(from: url) // actual network request

        // decode JSON array of strings
        let words = try JSONDecoder().decode([String].self, from: data) // API returns JSON, convert raw JSON into Swift array of strings

        // return first word uppercased
        return words.first?.uppercased() ?? "APPLE" // return first word else (fails) default to APPLE
    }
}
