//
//  WordService.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import Foundation

/// A lightweight service responsible for fetching random words from the API.
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
        /// 1. Constructs the request URL
        /// 2. Performs an asynchronous network request using `URLSession`
        /// 3. Decodes the JSON array returned by the API
        /// 4. Returns the first word capitalized
        /// 5. Falls back to `"APPLE"` if the API response is empty
        ///
        /// - Parameter length: The target length of the word (default is 5)
        /// - Returns: An uppercase word of the requested length
        /// - Throws: A `URLError` if the URL is invalid, or any decoding/network error
        ///
        /// ## Swift Concurrency Notes
        /// - `async` means this function can suspend while waiting for the network
        /// - `await` means the caller waits *asynchronously* (without blocking)
        /// - Using `actor` ensures this function is executed in a thread-safe context
    func fetchRandomWord(length: Int = 5) async throws -> String {
        // 1. Build API request
        let urlString = "https://random-word-api.vercel.app/api?words=1&length=\(length)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        // 2. Perform the actual network request (non-blocking)
        //
        // `await` suspends the task until data arrives.
        // UI remains fully responsive during this.
        let (data, _) = try await URLSession.shared.data(from: url)

        // 3. Decode payload — API returns an array like: ["apple"]
        let words = try JSONDecoder().decode([String].self, from: data)

        // 4. Return first word uppercased, with safe fallback
        return words.first?.uppercased() ?? "APPLE"
    }
}
