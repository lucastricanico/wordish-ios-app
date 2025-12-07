//
//  WordService.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import Foundation

/// A lightweight service responsible for fetching random words from API.
///
/// `WordService` is implemented as an `actor` to guarantee thread safety.
/// Even though this service currently has no shared mutable state, using
/// an actor models real production patterns where networking services may:
/// - cache responses,
/// - maintain local state,
/// - be accessed from multiple tasks concurrently.
///
/// ## Responsibilities
/// - Build the request URL
/// - Perform an async network call using `URLSession`
/// - Decode the returned JSON payload
/// - Return an uppercase 5-letter word or a safe fallback
///
/// This service uses **Swift Concurrency**, ensuring calls do not block the UI
/// and transparently suspend while waiting for network responses.
actor WordService {
    /// Fetches a random word of the given length from the Random Word API.
        ///
        /// This method:
        /// - Constructs the request URL
        /// - Performs an asynchronous network request using `URLSession`
        /// - Decodes the JSON array returned by the API
        /// - Returns the first word capitalized
        /// - Falls back to  word`"APPLE"` if the API response is empty
        ///
        /// - Parameter length: The target length of the word (default is 5)
        /// - Returns: An uppercase word of the requested length
        /// - Throws: A `URLError` if the URL is invalid, or any decoding/network error
        ///
    func fetchRandomWord(length: Int = 5) async throws -> String {
        // Build API request
        let urlString = "https://random-word-api.vercel.app/api?words=1&length=\(length)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        // Perform the actual network request (non-blocking)
        //
        // `await` suspends the task until data arrives.
        // UI remains fully responsive during this.
        let (data, _) = try await URLSession.shared.data(from: url)

        // Decode payload — API returns an array like: ["apple"]
        let words = try JSONDecoder().decode([String].self, from: data)

        // Return first word uppercased, with safe fallback
        return words.first?.uppercased() ?? GameConstants.fallbackWord
    }
}
