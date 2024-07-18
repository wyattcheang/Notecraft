//
//  SheetView.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 01/02/2024.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

enum FileActionType {
    case rename
    case create
    case delete
    case none
}

enum FileType: String {
    case pdf = "File"
    case dir = "Directory"
}

struct PDFViewer: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            uiView.document = document
        } else {
            print("Failed to load PDF document from URL: \(url)")
        }
    }
}

struct SheetView: View {
    var dir: URL = SheetManager.shared.mainDirectory

    var body: some View {
        NavigationView {
            DirectoryContentView(dir: dir, isOuttestView: true)
        }
        .navigationViewStyle(.stack)
    }
}

struct DirectoryContentView: View {
    var dir: URL
    var isOuttestView: Bool = false
    @State private var files: [URL] = []
    @State private var directories: [URL] = []

    var body: some View {
        GeometryReader { reader in
            let size = reader.size
            let col = Array(repeating: GridItem(.flexible(), spacing: 36), count: Int(size.width)/180)
        
            ScrollView {
                
                LazyVGrid(columns: col, spacing: 36) {
                    Group {
                        UploadFileView(dir: dir, load: loadContent)
                        ForEach(directories, id: \.self) { dir in
                            DirectoryIconView(dir: dir, load: loadContent)
                        }
                        ForEach(files, id: \.self) { file in
                            FileIconView(file: file, load: loadContent)
                        }
                    }
                    .frame(height: 240)
                }
                .padding()
                .padding(.horizontal)
                .onAppear(perform: loadContent)
            }
        }
        .navigationTitle(isOuttestView ? dir.lastPathComponent.capitalized : dir.lastPathComponent)
        .navigationBarTitleDisplayMode(isOuttestView ? .large : .inline)
    }
    
    func loadContent() {
        withAnimation {
            let result = SheetManager.shared.loadFilesAndDirectories(dir)
            switch result {
            case .success(let (files, directories)):
                self.files = files
                self.directories = directories
            case .failure(let error):
                print("Error loading directory contents: \(error.localizedDescription)")
            }
        }
    }
}

@Observable
class AlertControl {
    var title: String
    var message: String
    var dismissMessage: String
    var isPresented: Bool
    
    init(title: String = "", message: String = "", dismiss: String = "OK", isPresented: Bool = false) {
        self.title = title
        self.message = message
        self.dismissMessage = dismiss
        self.isPresented = isPresented
    }
}

struct UploadFileView: View {
    var dir: URL
    var load: () -> Void
    
    @State private var selectedPDF: URL?
    
    // dialog and alert controller
    @State private var isMenuPresented = false
    
    @State private var pdfImportPresented = false
    @State private var addDirectoryPromptPresented = false
    
    @State private var alertControl = AlertControl()
    @State private var newDirName: String = ""
    
    var body: some View {
        VStack {
            VStack {
                Button(action: { isMenuPresented.toggle() } ) {
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(style: .init(dash: [8]))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay {
                            Image(systemName: "plus")
                        }
                        .padding()
                }
            }
            .frame(maxHeight: .infinity)
            Text("Add file")
                .font(.caption)
                .frame(height: 40)
        }
        .confirmationDialog("Choose an option", isPresented: $isMenuPresented) {
            Button("Create Directory") { addDirectoryPromptPresented.toggle() }
            Button("Upload PDF") { pdfImportPresented.toggle() }
        }
        .fileImporter(
            isPresented: $pdfImportPresented,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false,
            onCompletion: handleFileSelection
        )
        .alert("Create Directory", isPresented: $addDirectoryPromptPresented) {
            TextField("Directory Name", text: $newDirName)
            Button("Cancel", role: .cancel) {}
            Button("Create") { createDirectory() }
        } message: {
            Text("Enter a name for the new directory.")
        }
        .alert(isPresented: $alertControl.isPresented) {
            Alert(
                title: Text(alertControl.title),
                message: Text(alertControl.message),
                dismissButton: .default(Text(alertControl.dismissMessage))
            )
        }
    }
    
    private func handleFileSelection(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                processSelectedFile(url)
            }
        case .failure(let error):
            alertControl.message = error.localizedDescription
            alertControl.isPresented = true
        }
    }
    
    private func processSelectedFile(_ url: URL) {
        let gotAccess = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        
        guard gotAccess else {
            alertControl.message = "No access."
            alertControl.isPresented = true
            return
        }
        
        SheetManager.shared.uploadFile(at: url, to: dir) { result in
            switch result {
            case .success(let msg):
                alertControl.title = "File Import"
                alertControl.message = msg
                load()
            case .failure(let error):
                alertControl.message = error.localizedDescription
            }
            alertControl.isPresented = true
        }
    }
    
    private func createDirectory() {
        SheetManager.shared.createDirectory(dir: dir, name: newDirName) { result in
            switch result {
            case .success(let message):
                alertControl.title = "Create Directory"
                alertControl.message = message
                load()
            case .failure(let error):
                alertControl.message = error.localizedDescription
            }
            alertControl.isPresented = true
        }
    }
}

struct FileIconView: View {
    var file: URL
    var load: () -> Void
    
    @State private var popover: Bool = false
    @State private var isPresenting = false
    
    var body: some View {
        VStack {
            Group {
                if let thumbnail = SheetManager.shared.generatePDFThumbnail(url: file) {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: 4)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(radius: 4)
                }
            }
            .frame(maxHeight: .infinity)
            .onTapGesture {
                isPresenting.toggle()
            }
            .fullScreenCover(isPresented: $isPresenting) {
                MusicSheetView(file: file, dismiss: $isPresenting)
            }
            DocumentInfoView(url: file, type: .pdf, load: load)
        }
    }
}

struct DirectoryIconView: View {
    var dir: URL
    var load: () -> Void
        
    var body: some View {
        NavigationLink(destination: DirectoryContentView(dir: dir)) {
            VStack {
                Spacer()
                Image("dir")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: .infinity)
                DocumentInfoView(url: dir, type: .dir, load: load)
            }
        }
    }
}

struct DocumentInfoView: View {
    var url: URL
    var type: FileType
    var load: () -> Void
    
    init(url: URL, type: FileType, load: @escaping () -> Void) {
        self.url = url
        self.type = type
        self.load = load
        self.docName = url.lastPathComponent
    }
    
    @State private var action: FileActionType = .none
    @State private var popover: Bool = false
    @State private var docName: String
    
    @State private var actionAlert = AlertControl()
    @State private var completionAlert = AlertControl()
    var body: some View {
        HStack {
            Text(url.lastPathComponent)
                .font(.caption)
            Button(action: { popover.toggle() }) {
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .confirmationDialog("", isPresented: $popover) {
                renameButton
                deleteButton
            }
            .alert(actionAlert.title, isPresented: $actionAlert.isPresented) {
                switch action {
                case .rename:
                    renameAlertContent
                case .delete:
                    deleteAlertContent
                case .create, .none:
                    VStack {}
                }
            } message: {
                Text(actionAlert.message)
            }
            .alert(isPresented: $completionAlert.isPresented) {
                Alert(title: Text(completionAlert.title),
                      message: Text(completionAlert.message),
                      dismissButton: .default(Text(completionAlert.dismissMessage)))
            }
        }
        .frame(height: 40)
    }
    
    private var renameButton: some View {
        Button("Rename") {
            docName = url.lastPathComponent
            action = .rename
            actionAlert.title = "Rename \(type.rawValue)"
            actionAlert.message = "Enter \(type.rawValue) Name"
            actionAlert.isPresented.toggle()
        }
    }
    
    private var deleteButton: some View {
        Button("Delete", role: .destructive) {
            action = .delete
            actionAlert.title = "Delete \(type.rawValue)"
            actionAlert.message = "Confirm delete \(docName)?"
            actionAlert.isPresented.toggle()
        }
    }
    
    private var renameAlertContent: some View {
        VStack {
            TextField("", text: $docName)
            Button("Cancel", role: .cancel) {}
            Button("Done") { renameDirectory() }
        }
    }
    
    private var deleteAlertContent: some View {
        VStack {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { deleteDirectory() }
        }
    }
    
    private var failedAlertContent: some View {
        VStack {
            Button("OK", role: .cancel) {}
        }
    }
    
    private func renameDirectory() {
        actionAlert.isPresented = false
        guard url.lastPathComponent != docName else { return }
        SheetManager.shared.renameFile(at: url, to: docName) { result in
            switch result {
            case .success:
                load()
            case .failure:
                print("here")
                completionAlert.title = "Action Failed"
                completionAlert.message = "The \(type.rawValue) with the same name already exists."
                completionAlert.dismissMessage = "OK"
                completionAlert.isPresented = true
            }
        }
    }
    
    private func deleteDirectory() {
        SheetManager.shared.deleteFile(at: url) { result in
            switch result {
            case .success:
                load()
            case .failure(_):
                completionAlert.title = "Action Failed"
                completionAlert.message = "Failed to delete \(type.rawValue): \(docName)"
                completionAlert.dismissMessage = "OK"
                completionAlert.isPresented = true
            }
        }
    }
}

//struct MusicSheetView: View {
//    var file: URL
//    @Binding var dismiss: Bool
//    @State private var currentPage: Int = 1
//    @State private var isShowingNavBar: Bool = true
//    
//    var body: some View {
//        GeometryReader { geometry in
//            NavigationStack {
//                GeometryReader { reader in
//                    let size = reader.size
//                        VStack {
//                            Text("\(UIScreen.main.bounds.width)")
//                            Text("\(UIScreen.main.bounds.height)")
//                            Text("\(size.width)")
//                            Text("\(size.height)")
//                        }
////                    PDFKitView(url: file, size: geometry.size, currentPage: $currentPage)
////                        .frame(width: .infinity, height: .infinity)
////                    //                    .simultaneousGesture(
////                    //                        DragGesture(minimumDistance: 0.1)
////                    //                            .onEnded { value in
////                    //                                let touchX = value.location.x
////                    //                                if touchX < size.width / 3 {
////                    //                                    if currentPage > 1 {
////                    //                                        flipPage(to: .left)
////                    //                                    }
////                    //                                } else if touchX > 2 * size.width / 3 {
////                    //                                    if currentPage < totalPages(for: file) {
////                    //                                        flipPage(to: .right)
////                    //                                    }
////                    //                                }
////                    //                            }
////                    //                    )
////                        .navigationTitle(file.lastPathComponent)
////                        .navigationBarTitleDisplayMode(.inline)
////                        .navigationBarHidden(!isShowingNavBar)
////                        .toolbar {
////                            ToolbarItem(placement: .navigationBarLeading) {
////                                Button(action: {
////                                    dismiss.toggle()
////                                }) {
////                                    Label("Back", systemImage: "chevron.left")
////                                }
////                            }
////                        }
////                        .animation(.easeIn(duration: 0.3), value: isShowingNavBar)
//                }
//            }
//        }
//        HStack {
//            Button("Previous", action: { flipPage(to: .left) })
//            Spacer()
//            Button("Next", action: { flipPage(to: .right) })
//        }
//    }
//    
//    private func totalPages(for pdfURL: URL) -> Int {
//        guard let pdfDocument = PDFDocument(url: pdfURL) else { return 0 }
//        return pdfDocument.pageCount
//    }
//    
//    private func flipPage(to direction: FlipDirection) {
//        withAnimation {
//            if direction == .left {
//                currentPage = max(currentPage - 1, 1)
//            } else if direction == .right {
//                currentPage = min(currentPage + 1, totalPages(for: file))
//            }
//        }
//    }
//    
//    enum FlipDirection {
//        case left, right
//    }
//}

struct PDFKitView: UIViewRepresentable {
    var url: URL
    var width: CGFloat
    @Binding var currentPage: Int
    var pdfView = PDFView()

    func makeUIView(context: Context) -> PDFView {
        pdfView.document = PDFDocument(url: url)
        setup(pdfView: pdfView)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        print("callced")
        if let page = uiView.document?.page(at: currentPage - 1) {
            uiView.go(to: page)
        }
        scalePDFViewToFit(uiView)
    }

    func setup(pdfView: PDFView) {
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.systemBackground
        pdfView.autoScales = false
        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.setNeedsLayout()
        pdfView.layoutIfNeeded()
    }

    func scalePDFViewToFit(_ pdfView: PDFView) {
        guard let page = pdfView.document?.page(at: currentPage - 1) else { return }
        
        let pageRect = page.bounds(for: .mediaBox)
        let scale = width / pageRect.width
        
        pdfView.scaleFactor = scale
        pdfView.minScaleFactor = scale
        pdfView.maxScaleFactor = scale * 4
        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit

        pdfView.setNeedsLayout()
        pdfView.layoutIfNeeded()
    }
}

struct MusicSheetView: View {
    var file: URL
    @Binding var dismiss: Bool
    @State private var currentPage: Int = 1
    @State private var isShowingNavBar: Bool = true
    
    var id: String {
        do {
            return try SheetManager.shared.getID(from: file)
        } catch {
            return ""
        }
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                NavigationStack {
                    PDFKitView(url: file, width: geometry.size.width, currentPage: $currentPage)
                        .navigationTitle(file.lastPathComponent)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarHidden(!isShowingNavBar)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    dismiss.toggle()
                                }) {
                                    Label("Back", systemImage: "chevron.left")
                                }
                                Spacer()
                                Button(action: {}) {
                                    Image(systemName: "share")
                                }
                            }
                        }
                        .animation(.easeIn(duration: 0.3), value: isShowingNavBar)
                }
            }
            HStack {
                Button("Previous", action: { flipPage(to: .left) })
                Spacer()
                Text(id)
                Spacer()
                Button("Next", action: { flipPage(to: .right) })
            }
            .padding()
        }
    }
    
    private func totalPages(for pdfURL: URL) -> Int {
        guard let pdfDocument = PDFDocument(url: pdfURL) else { return 0 }
        return pdfDocument.pageCount
    }
    
    private func flipPage(to direction: FlipDirection) {
        withAnimation {
            if direction == .left {
                currentPage = max(currentPage - 1, 1)
            } else if direction == .right {
                currentPage = min(currentPage + 1, totalPages(for: file))
            }
        }
    }
    
    enum FlipDirection {
        case left, right
    }
}

struct TestingView: View {
    var url: URL? = Bundle.main.url(forResource: "Ray Chen-IU Through the Night Violin" , withExtension: "pdf")
    @State var popup: Bool = false
    
    var body: some View {
        MusicSheetView(file: url!, dismiss: $popup)
    }
}

#Preview {
    SheetView()
}


//#Preview("Test") {
//    MusicSheetView(file: <#T##URL#>, dismiss: <#T##Bool#>)
//}

