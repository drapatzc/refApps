import SwiftUI
import PhotosUI

/// View for capturing or selecting a sick note image with device/simulator support.
struct SickNoteImagePickerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = SickNoteViewModel()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var rotation: Double = 0
    @State private var showingImagePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(white: 0.15)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: AppTheme.spacingL) {
                    if let image = viewModel.capturedImage {
                        // Image Preview with Rotation
                        ZStack {
                            Rectangle()
                                .fill(Color(white: 0.1))

                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .rotationEffect(.degrees(rotation))
                                .padding(AppTheme.spacingL)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        .cornerRadius(AppTheme.cornerRadiusL)
                        .padding(AppTheme.spacingM)

                        // Editing Controls
                        VStack(spacing: AppTheme.spacingM) {
                            HStack(spacing: AppTheme.spacingL) {
                                Button {
                                    withAnimation {
                                        rotation += 90
                                        if rotation >= 360 {
                                            rotation = 0
                                        }
                                    }
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: "rotate.right")
                                            .font(.title3)
                                        Text("Drehen")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.white)
                                }

                                Button {
                                    showingImagePicker = true
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: "photo")
                                            .font(.title3)
                                        Text("Ändern")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.white)
                                }

                                Spacer()

                                Button {
                                    dismiss()
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title3)
                                        Text("Fertig")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.green)
                                }
                            }
                            .padding(AppTheme.spacingM)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(AppTheme.cornerRadiusL)
                        }
                        .padding(AppTheme.spacingM)
                    } else {
                        // Image Selection UI
                        VStack(spacing: AppTheme.spacingL) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.6))

                            Text("Foto aufnehmen oder auswählen")
                                .font(.headline)
                                .foregroundStyle(.white)

                            #if targetEnvironment(simulator)
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Label("Aus Fotos auswählen", systemImage: "photo.on.rectangle")
                                    .font(.body)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, AppTheme.spacingL)
                                    .padding(.vertical, AppTheme.spacingM)
                                    .background(Color.blue.opacity(0.7))
                                    .cornerRadius(8)
                            }
                            .onChange(of: selectedItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        viewModel.capturedImage = image
                                    }
                                }
                            }
                            #else
                            Button {
                                showingImagePicker = true
                            } label: {
                                Label("Kamera", systemImage: "camera")
                                    .font(.body)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, AppTheme.spacingL)
                                    .padding(.vertical, AppTheme.spacingM)
                                    .background(Color.blue.opacity(0.7))
                                    .cornerRadius(8)
                            }
                            #endif
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(AppTheme.spacingL)
                    }

                    Spacer()
                }
                .navigationTitle("Krankmeldung fotografieren")
                .navigationBarTitleDisplayMode(.inline)
            }
            .sheet(isPresented: $showingImagePicker) {
                #if !targetEnvironment(simulator)
                ImagePickerController(image: $viewModel.capturedImage)
                #endif
            }
        }
    }
}

#if !targetEnvironment(simulator)
/// UIViewControllerRepresentable for camera access on real devices.
struct ImagePickerController: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerController

        init(_ parent: ImagePickerController) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
    }
}
#endif

#Preview {
    SickNoteImagePickerView()
        .environment(AppState())
}
