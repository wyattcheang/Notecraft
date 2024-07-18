//
//  Server.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 17/07/2024.
//

import Foundation

class FastAPIServer {
    static let shared = FastAPIServer()
    
    func uploadPDF(at pdfURL: URL) {
        guard let url = URL(string: "https://bbe2-2001-f40-987-15b2-153d-d372-d626-1b84.ngrok-free.app/upload/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        let filename = pdfURL.lastPathComponent
        let mimetype = "application/pdf"
        let fileData = try? Data(contentsOf: pdfURL)
        
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData!)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Upload successful")
            }
        }.resume()
    }
}
