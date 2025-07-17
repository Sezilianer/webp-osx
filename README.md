# webp-osx

A macOS application to convert common image formats to WebP. The UI is built with SwiftUI and allows drag-and-drop of files or folders. Users can specify the output size, keep the aspect ratio, and choose a custom name for the resulting images.

## Requirements

- macOS 11 or newer
- Xcode with Swift 5.7 or newer

## Building

Open the project directory in Xcode and build the `WebpApp` executable target. The application uses the native WebP support provided by `ImageIO` on macOS.

## Usage

Drag images or folders onto the application window, adjust the width/height settings, and press **Convert**. The converted images will be saved next to the originals with the provided output name.
