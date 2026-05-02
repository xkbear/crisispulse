//
//  APIClient.swift
//  CrisisPulse
//
//  Thin wrapper over the existing Netlify Functions backend at crisispulse.org.
//

import Foundation

actor APIClient {
    let baseURL = URL(string: "https://crisispulse.org")!
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    enum APIError: LocalizedError {
        case badStatus(Int)
        case decoding(String)

        var errorDescription: String? {
            switch self {
            case .badStatus(let code): return "Server returned HTTP \(code)"
            case .decoding(let msg):   return "Decoding failed: \(msg)"
            }
        }
    }

    /// GET /api/conflicts → ConflictsResponse
    func fetchConflicts() async throws -> ConflictsResponse {
        let url = baseURL.appendingPathComponent("api/conflicts")
        let (data, resp) = try await session.data(from: url)
        try validate(resp)
        do {
            return try JSONDecoder().decode(ConflictsResponse.self, from: data)
        } catch {
            throw APIError.decoding(String(describing: error))
        }
    }

    /// POST /api/visitor → VisitorResponse
    /// Optionally pass a country code to attribute the visit; otherwise the
    /// server uses Netlify's geo header.
    func recordVisit(country: String? = nil) async throws -> VisitorResponse {
        let url = baseURL.appendingPathComponent("api/visitor")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let country {
            req.httpBody = try JSONSerialization.data(withJSONObject: ["country": country])
        }
        let (data, resp) = try await session.data(for: req)
        try validate(resp)
        return try JSONDecoder().decode(VisitorResponse.self, from: data)
    }

    /// POST /api/subscribe { email, country } → { ok, message }
    /// Backend then sends the welcome email through Resend.
    @discardableResult
    func subscribe(email: String, country: String?) async throws -> SubscribeResult {
        let url = baseURL.appendingPathComponent("api/subscribe")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: Any] = ["email": email]
        if let country { body["country"] = country }
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await session.data(for: req)
        try validate(resp)
        return try JSONDecoder().decode(SubscribeResult.self, from: data)
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard 200..<300 ~= http.statusCode else {
            throw APIError.badStatus(http.statusCode)
        }
    }
}

struct SubscribeResult: Codable {
    let ok: Bool
    let message: String?
    let error: String?
    let count: Int?
}
