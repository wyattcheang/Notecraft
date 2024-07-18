//
//  Supabase.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 14/05/2024.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://jzwwqvvsgdyremmxzfom.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6d3dxdnZzZ2R5cmVtbXh6Zm9tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTU2NjgwNzUsImV4cCI6MjAzMTI0NDA3NX0.IQwNTOnGHzb23lWQWZJ-kfvRuts6V3Gsit1kIiVmDk8"
)
