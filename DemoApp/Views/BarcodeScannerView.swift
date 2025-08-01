//
//  BarcodeScannerView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 4/15/25.
//

import SwiftUI
import AVFoundation
import Combine

struct BarcodeScannerView: View {
    @ObservedObject private var openLibraryService = OpenLibraryService.shared
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    @State private var scannedCode = ""
    @State private var showingScanner = false
    @State private var scannedBook: DemoApp.Book?
    @State private var showingBookResult = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let book = scannedBook {
                    BookCard(book: book)
                        .padding()
                    
                    HStack {
                        Button("Add to Catalog") {
                            addBookToCatalog(book)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Scan Another") {
                            resetScanner()
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Staff Book Scanner")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Scan a book's barcode to add it to the catalog")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Start Scanning") {
                            showingScanner = true
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                }
                
                if openLibraryService.isLoading {
                    ProgressView("Looking up book...")
                        .padding()
                }
                
                if let error = openLibraryService.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Book Scanner")
            .sheet(isPresented: $showingScanner) {
                ScannerView(scannedCode: $scannedCode, onScan: handleScannedCode)
            }
            .onChange(of: scannedCode) { newValue in
                if !newValue.isEmpty {
                    handleScannedCode(newValue)
                }
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        showingScanner = false
        
        // Look up book using OpenLibrary API
        openLibraryService.fetchBookByISBN(code)
            .receive(on: DispatchQueue.main)
            .sink { book in
                if let book = book {
                    scannedBook = book
                    showingBookResult = true
                } else {
                    // Try Google Books API as fallback
                    BookAPI.fetchBookInfo(isbn: code) { fetchedBook in
                        if let fetchedBook = fetchedBook {
                            scannedBook = fetchedBook
                            showingBookResult = true
                        }
                    }
                }
            }
            .store(in: &openLibraryService.cancellables)
    }
    
    private func addBookToCatalog(_ book: DemoApp.Book) {
        let coreDataBook = coreDataManager.createBook(from: book)
        resetScanner()
    }
    
    private func resetScanner() {
        scannedCode = ""
        scannedBook = nil
        openLibraryService.error = nil
    }
}

struct ScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    let onScan: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: ScannerView
        var session: AVCaptureSession?
        
        init(parent: ScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput,
                           didOutput metadataObjects: [AVMetadataObject],
                           from connection: AVCaptureConnection) {
            if let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let stringValue = metadata.stringValue {
                parent.scannedCode = stringValue
                parent.onScan(stringValue)
                session?.stopRunning()
                parent.dismiss()
            }
        }
        
        @objc func closeScanner() {
            parent.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let session = AVCaptureSession()
        context.coordinator.session = session
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              session.canAddInput(videoInput) else {
            return viewController
        }
        
        session.addInput(videoInput)
        
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.ean13, .ean8, .upce, .code128, .code39]
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        viewController.view.backgroundColor = .black
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Cancel", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        closeButton.layer.cornerRadius = 8
        closeButton.addTarget(context.coordinator, action: #selector(Coordinator.closeScanner), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 80),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        session.startRunning()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
