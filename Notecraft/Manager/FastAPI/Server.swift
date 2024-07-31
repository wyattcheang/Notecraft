//
//  Server.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 17/07/2024.
//

import Foundation

class FastAPIServer {
    static let shared = FastAPIServer()
    
    @MainActor
    func uploadPDF(at pdfURL: URL, fileID: String, userID: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://helpful-albacore-distinct.ngrok-free.app/upload/") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        let filename = pdfURL.lastPathComponent
        let mimetype = "application/pdf"

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        
        // Add file_id to form data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(fileID)\r\n".data(using: .utf8)!)

        // Add user_id to form data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userID)\r\n".data(using: .utf8)!)

        // Add file to form data
        do {
            let pdfData = try Data(contentsOf: pdfURL)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            body.append(pdfData)
            body.append("\r\n".data(using: .utf8)!)
        } catch {
            completion(.failure(error))
            return
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    completion(.success("Upload successful"))
                } else {
                    let statusCodeError = NSError(domain: "", 
                                                  code: (response as? HTTPURLResponse)?.statusCode ?? -1,
                                                  userInfo: [NSLocalizedDescriptionKey: "Upload failed"])
                    completion(.failure(statusCodeError))
                }
            }
        }.resume()
    }
}


