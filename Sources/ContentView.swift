import SwiftUI

struct ContentView: View {
    @State private var inputItems: [URL] = []
    @State private var width: String = ""
    @State private var height: String = ""
    @State private var keepAspect: Bool = true
    @State private var useLongSide: Bool = true
    @State private var outputName: String = "output"
    @State private var isConverting: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            DropAreaView(items: $inputItems)
                .frame(height: 150)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))

            HStack {
                TextField("Width", text: $width)
                    .frame(width: 80)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Height", text: $height)
                    .frame(width: 80)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Toggle("Keep Aspect", isOn: $keepAspect)
                Picker("Side", selection: $useLongSide) {
                    Text("Long Side").tag(true)
                    Text("Short Side").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            TextField("Output Name", text: $outputName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 300)

            if let message = errorMessage {
                Text(message)
                    .foregroundColor(Color(hex: "#FF7F50"))
            }

            Button(action: convert) {
                if isConverting {
                    ProgressView()
                } else {
                    Text("Convert")
                        .padding()
                        .background(Color(hex: "#EEF19B"))
                        .cornerRadius(8)
                }
            }
            .disabled(isConverting || inputItems.isEmpty)
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
    }

    private func convert() {
        isConverting = true
        errorMessage = nil
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WebpConverter.convert(items: inputItems,
                                          width: Int(width),
                                          height: Int(height),
                                          keepAspect: keepAspect,
                                          useLongSide: useLongSide,
                                          outputName: outputName)
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            }
            DispatchQueue.main.async {
                isConverting = false
            }
        }
    }
}

struct DropAreaView: NSViewRepresentable {
    @Binding var items: [URL]

    func makeNSView(context: Context) -> DropView {
        let view = DropView()
        view.onURLsDropped = { urls in
            items = urls
        }
        return view
    }

    func updateNSView(_ nsView: DropView, context: Context) {}
}

class DropView: NSView {
    var onURLsDropped: (([URL]) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else {
            return false
        }
        onURLsDropped?(urls)
        return true
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView()
}
