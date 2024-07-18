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
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to UIImage"])))
                    }
                }
                
            catch {
                print(error)
                completion(.failure(error))
            }
        }
    }
}
