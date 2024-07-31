//
//  Storage.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 17/07/2024.
//

import Foundation
import UIKit

class Storage {
    static let shared = Storage()
    
    func fetchImage(bucket: String, path: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        Task {
            do {
                let data = try await supabase.storage
                    .from(bucket)
                    .download(path: path)
                
                    if let image = UIImage(data: data) {
                        completion(.success(image))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, 
                                                    userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to UIImage"])))
                    }
                }
                
            catch {
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func checkXMLFileAvailability(bucket: String, path: String) async -> [String] {
        do {
            let data = try await supabase.storage
                .from(bucket)
                .list(path: path)
            let result = (data.map {$0.name})
            return result
        }
        catch {
            print(error)
            return []
        }
    }
    
    func getXMLFile(bucket: String, paths: [String]) async -> [URL] {
        var fileURLs: [URL] = []
        
        for path in paths {
            do {
                let data = try await supabase.storage
                    .from(bucket)
                    .download(path: path)
                
                let localURL = getLocalFilePath(for: path)
                try data.write(to: localURL)
                fileURLs.append(localURL)
            } catch {
                print(error)
            }
        }
        return fileURLs
    }

    func getLocalFilePath(for remotePath: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localFileName = (remotePath as NSString).lastPathComponent
        return documentsDirectory.appendingPathComponent(localFileName)
    }
}
