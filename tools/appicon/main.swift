// Chatty Pal app icon generator (store-ready phase C).
//
// Renders the intentional initial icon: white speech bubble with "CP" monogram
// on a blue diagonal gradient. Output is an opaque 1024x1024 PNG (App Store
// requirement: no alpha). Final designed art replaces the same file later.
//
// Usage:
//   swiftc -O tools/appicon/main.swift -o /tmp/genappicon
//   /tmp/genappicon chatty-pal/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
//   (or: swift tools/appicon/main.swift <output.png>)

import AppKit
import CoreGraphics
import ImageIO
import Foundation

let side = 1024.0

func srgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> CGColor {
    CGColor(srgbRed: r, green: g, blue: b, alpha: 1)
}

// Brand colors (aligned with the app's system-blue accent).
let blueTop = srgb(0x3E / 255, 0x7B / 255, 0xFA / 255)      // bright blue, top-leading
let blueBottom = srgb(0x1E / 255, 0x3A / 255, 0x8A / 255)   // deep blue, bottom-trailing
let bubbleWhite = srgb(1, 1, 1)
let monogramBlue = srgb(0x22 / 255, 0x4E / 255, 0xC8 / 255)

// Opaque RGB context (NoneSkipLast = 3 color bytes + 1 skipped; the PNG encoder
// emits no alpha channel) — guarantees the required alpha-free App Store icon.
let space = CGColorSpace(name: CGColorSpace.sRGB)!
guard let ctx = CGContext(data: nil,
                          width: Int(side), height: Int(side),
                          bitsPerComponent: 8,
                          bytesPerRow: Int(side) * 4,
                          space: space,
                          bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
    FileHandle.standardError.write("cannot create bitmap context\n".data(using: .utf8)!)
    exit(1)
}

// Background gradient (bottom-left -> top-right in CG's flipped coordinates).
let gradient = CGGradient(colorsSpace: space,
                          colors: [blueBottom, blueTop] as CFArray,
                          locations: [0, 1])!
ctx.drawLinearGradient(gradient,
                       start: CGPoint(x: 0, y: 0),
                       end: CGPoint(x: side, y: side),
                       options: [])

// Speech bubble: rounded rect body + tail at the bubble's bottom-left.
// Body and tail are filled as separate paths (same fill color): merging them into
// one path made opposite windings cut a hole where the tail meets the body.
let bubbleWidth = 640.0
let bubbleHeight = 470.0
let bubbleX = (side - bubbleWidth) / 2
let bubbleY = (side - bubbleHeight) / 2 + 60        // sits slightly high; tail fills below
let corner: CGFloat = 130

let tailBaseY = bubbleY + corner * 0.4
let tailX = bubbleX + bubbleWidth * 0.24
var tail = CGMutablePath()
tail.move(to: CGPoint(x: tailX, y: tailBaseY + 120))
tail.addLine(to: CGPoint(x: tailX, y: tailBaseY))
tail.addQuadCurve(to: CGPoint(x: tailX - 150, y: tailBaseY - 170),
                  control: CGPoint(x: tailX - 10, y: tailBaseY - 170))
tail.closeSubpath()

ctx.setFillColor(bubbleWhite)
ctx.addPath(CGPath(roundedRect: CGRect(x: bubbleX, y: bubbleY, width: bubbleWidth, height: bubbleHeight),
                   cornerWidth: corner, cornerHeight: corner, transform: nil))
ctx.fillPath()
ctx.addPath(tail)
ctx.fillPath()

// "CP" monogram in SF Pro Rounded Bold, centered inside the bubble body.
let text = "CP"
let rounded = NSFont(name: "SFProRounded-Bold", size: 240)
    ?? NSFont.systemFont(ofSize: 240, weight: .bold)
let attrs: [NSAttributedString.Key: Any] = [
    .font: rounded,
    .foregroundColor: NSColor(cgColor: monogramBlue) ?? NSColor.systemBlue,
]
let attributed = NSAttributedString(string: text, attributes: attrs)
let textSize = attributed.size()

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
let textOrigin = CGPoint(x: bubbleX + (bubbleWidth - textSize.width) / 2,
                        y: bubbleY + (bubbleHeight - textSize.height) / 2 + 6)
attributed.draw(at: textOrigin)
NSGraphicsContext.restoreGraphicsState()

// Write opaque PNG.
guard let image = ctx.makeImage() else {
    FileHandle.standardError.write("cannot make image\n".data(using: .utf8)!)
    exit(1)
}

let arguments = CommandLine.arguments
guard arguments.count >= 2 else {
    FileHandle.standardError.write("usage: genappicon <output.png>\n".data(using: .utf8)!)
    exit(1)
}
let outputURL = URL(fileURLWithPath: arguments[1]) as CFURL
guard let dest = CGImageDestinationCreateWithURL(outputURL, "public.png" as CFString, 1, nil) else {
    FileHandle.standardError.write("cannot create image destination\n".data(using: .utf8)!)
    exit(1)
}
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else {
    FileHandle.standardError.write("cannot write PNG\n".data(using: .utf8)!)
    exit(1)
}
print("wrote \(arguments[1]) (\(Int(side))x\(Int(side)) opaque PNG)")
