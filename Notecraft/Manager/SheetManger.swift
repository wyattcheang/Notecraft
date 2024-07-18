//
//  PDFManger.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 03/07/2024.
//

import Foundation
import PDFKit

class SheetManager {
    static let shared = SheetManager()
    
    let fileManager = FileManager.default
    
    let mainDirectory: URL
    
    private init() {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        mainDirectory = documentsURL.appendingPathComponent("sheets")
        // Check if 'sheets' directory exists, create if it doesn't
        if !FileManager.default.fileExists(atPath: mainDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: mainDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Created 'Sheets' directory at: \(mainDirectory)")
            } catch {
                print("Failed to create 'Sheets' directory: \(error.localizedDescription)")
            }
        }
    }
    
    func loadFilesAndDirectories(_ dir: URL) -> Result<([URL], [URL]), Error> {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isDirectoryKey])
            let files = contents.filter { $0.pathExtension == "pdf" }
            let dirs = contents.filter { $0.hasDirectoryPath }
            return .success((files, dirs))  // Return a success result with the tuple
        } catch {
            print("Failed to list directory contents: \(error.localizedDescription)")
            return .failure(error)  // Return a failure result with the error
        }
    }
    
    func generatePDFThumbnail(url: URL) -> UIImage? {
        guard let document = PDFDocument(url: url), let page = document.page(at: 0) else {
            return nil
        }
        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let thumbnail = renderer.image { context in
            UIColor.white.set()
            context.fill(pageRect)
            context.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)
            page.draw(with: .mediaBox, to: context.cgContext)
        }
        return thumbnail
    }
    
    func createDirectory(dir: URL, name: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !name.isEmpty else {
            let error = NSError(domain: "Directory name is empty", code: 1, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        let fileManager = FileManager.default
        var newDirectoryURL = dir.appendingPathComponent(name)
        var suffix = 1
        
        // Check if directory already exists and append suffix
        while fileManager.fileExists(atPath: newDirectoryURL.path) {
            newDirectoryURL = dir.appendingPathComponent("\(name) \(suffix)")
            suffix += 1
        }
        
        do {
            try fileManager.createDirectory(at: newDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            print("Directory created at: \(newDirectoryURL)")
            
            _ = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isDirectoryKey])
//            let directories = contents.filter { $0.hasDirectoryPath }
            
            completion(.success("Directory successfully created"))
        } catch {
            print("Failed to create directory: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
        
    func uploadFile(at fileURL: URL, to dirURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        print(dirURL)
        var destinationURL = dirURL.appendingPathComponent(fileURL.lastPathComponent)
        let fileName = fileURL.deletingPathExtension().lastPathComponent
        let fileExtension = fileURL.pathExtension
        
        // Check if a file with the same name already exists and append a suffix if needed
        var counter = 1
        while fileManager.fileExists(atPath: destinationURL.path) {
            let newName = "\(fileName)_\(counter).\(fileExtension)"
            destinationURL = dirURL.appendingPathComponent(newName)
            counter += 1
        }
        
        do {
            try fileManager.copyItem(at: fileURL, to: destinationURL)
            try addID(to: destinationURL)
            completion(.success("File successfully imported"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteFile(at url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try fileManager.removeItem(at: url)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func renameFile(at url: URL, to newName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let newURL = url.deletingLastPathComponent().appendingPathComponent(newName)
        
        do {
            try fileManager.moveItem(at: url, to: newURL)
            completion(.success(newURL))
        } catch {
            completion(.failure(error))
        }
    }
    
    func uploadPDFToFastAPI(at pdfURL: URL) {
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
    
    func addID(to pdfURL: URL) throws {
        // Generate a UUID and add it as extended attribute
        let uuid = UUID().uuidString
        try addExtendedAttribute(name: "id", value: uuid, to: pdfURL)
    }
    
    func getID(from pdfURL: URL) throws -> String {
        try getExtendedAttribute(name: "id", from: pdfURL)
    }
    
    func addExtendedAttribute(name: String, value: String, to fileURL: URL) throws {
        let data = value.data(using: .utf8)!
        let result = data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> Int32 in
            let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
            return setxattr(fileURL.path, name, bufferPointer.baseAddress!, bufferPointer.count, 0, 0)
        }
        if result != 0 {
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil)
        }
    }
    
    func getExtendedAttribute(name: String, from fileURL: URL) throws -> String {
        let length = getxattr(fileURL.path, name, nil, 0, 0, 0)
        guard length != -1 else {
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil)
        }
        
        var data = Data(count: length)
        let result = data.withUnsafeMutableBytes { (rawBufferPointer: UnsafeMutableRawBufferPointer) -> Int32 in
            let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
            return Int32(getxattr(fileURL.path, name, bufferPointer.baseAddress!, bufferPointer.count, 0, 0))
        }
        
        guard result != -1 else {
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil)
        }
        
        return String(data: data, encoding: .utf8)!
    }
}
