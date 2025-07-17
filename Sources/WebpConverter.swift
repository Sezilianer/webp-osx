import AppKit
import ImageIO

enum WebpConverter {
    static func convert(items: [URL],
                        width: Int?,
                        height: Int?,
                        keepAspect: Bool,
                        useLongSide: Bool,
                        outputName: String) throws {
        let fileManager = FileManager.default
        for (index, url) in items.enumerated() {
            let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            if isDir {
                let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                try convert(items: contents, width: width, height: height, keepAspect: keepAspect, useLongSide: useLongSide, outputName: outputName)
                continue
            }

            guard let image = NSImage(contentsOf: url) else { continue }
            let targetSize = resizedSize(for: image.size, width: width, height: height, keepAspect: keepAspect, useLongSide: useLongSide)
            let resizedImage = image.resized(to: targetSize)
            let destURL = url.deletingLastPathComponent()
                .appendingPathComponent("\(outputName)_\(index).webp")
            try saveWebP(image: resizedImage, to: destURL)
        }
    }

    private static func resizedSize(for size: NSSize,
                                    width: Int?,
                                    height: Int?,
                                    keepAspect: Bool,
                                    useLongSide: Bool) -> NSSize {
        var w = CGFloat(width ?? Int(size.width))
        var h = CGFloat(height ?? Int(size.height))

        if keepAspect {
            if width != nil && height == nil {
                let ratio = size.height / size.width
                h = w * ratio
            } else if height != nil && width == nil {
                let ratio = size.width / size.height
                w = h * ratio
            } else if width == nil && height == nil {
                w = size.width
                h = size.height
            }
        } else if width == nil || height == nil {
            if useLongSide {
                let long = max(size.width, size.height)
                let short = min(size.width, size.height)
                if width != nil {
                    let ratio = short / long
                    h = CGFloat(width!) * ratio
                } else if height != nil {
                    let ratio = short / long
                    w = CGFloat(height!) * ratio
                }
            } else {
                if width != nil {
                    h = CGFloat(width!)
                } else if height != nil {
                    w = CGFloat(height!)
                }
            }
        }
        return NSSize(width: w, height: h)
    }

    private static func saveWebP(image: NSImage, to url: URL) throws {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw NSError(domain: "WebpConverter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create CGImage"])
        }
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, AVFileType.webp as CFString, 1, nil) else {
            throw NSError(domain: "WebpConverter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to create destination"])
        }
        CGImageDestinationAddImage(dest, cgImage, nil)
        if !CGImageDestinationFinalize(dest) {
            throw NSError(domain: "WebpConverter", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize WebP"])
        }
    }
}

extension NSImage {
    func resized(to size: NSSize) -> NSImage {
        let img = NSImage(size: size)
        img.lockFocus()
        defer { img.unlockFocus() }
        let ctx = NSGraphicsContext.current
        ctx?.imageInterpolation = .high
        draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .copy, fraction: 1)
        return img
    }
}
