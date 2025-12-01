#!/usr/bin/env swift

import Foundation
import Network

// Minimal HTTP server for serving test pages
// Usage: ./serve.swift [port] [directory]

let port: UInt16 = CommandLine.arguments.count > 1 ? UInt16(CommandLine.arguments[1]) ?? 8080 : 8080
let directory = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "./test-pages"

let mimeTypes: [String: String] = [
    "html": "text/html",
    "css": "text/css",
    "js": "application/javascript",
    "json": "application/json",
    "png": "image/png",
    "jpg": "image/jpeg",
    "gif": "image/gif",
    "svg": "image/svg+xml",
    "ico": "image/x-icon",
    "txt": "text/plain"
]

func getMimeType(for path: String) -> String {
    let ext = (path as NSString).pathExtension.lowercased()
    return mimeTypes[ext] ?? "application/octet-stream"
}

func handleRequest(_ data: Data) -> Data {
    guard let request = String(data: data, encoding: .utf8),
          let firstLine = request.split(separator: "\r\n").first else {
        return makeResponse(code: 400, status: "Bad Request", body: "Invalid request")
    }

    let parts = firstLine.split(separator: " ")
    guard parts.count >= 2 else {
        return makeResponse(code: 400, status: "Bad Request", body: "Invalid request")
    }

    var path = String(parts[1])

    // URL decode
    path = path.removingPercentEncoding ?? path

    // Security: prevent directory traversal
    if path.contains("..") {
        return makeResponse(code: 403, status: "Forbidden", body: "Access denied")
    }

    // Default to index.html
    if path == "/" {
        path = "/index.html"
    }

    let fullPath = (directory as NSString).appendingPathComponent(path)
    let fileManager = FileManager.default

    // Check if it's a directory, serve index.html
    var isDirectory: ObjCBool = false
    if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) {
        if isDirectory.boolValue {
            let indexPath = (fullPath as NSString).appendingPathComponent("index.html")
            if fileManager.fileExists(atPath: indexPath) {
                return serveFile(indexPath)
            } else {
                return serveDirectoryListing(fullPath, requestPath: path)
            }
        }
        return serveFile(fullPath)
    }

    return makeResponse(code: 404, status: "Not Found", body: "File not found: \(path)")
}

func serveFile(_ path: String) -> Data {
    guard let content = FileManager.default.contents(atPath: path) else {
        return makeResponse(code: 500, status: "Internal Server Error", body: "Could not read file")
    }

    let mimeType = getMimeType(for: path)
    let header = """
        HTTP/1.1 200 OK\r
        Content-Type: \(mimeType)\r
        Content-Length: \(content.count)\r
        Connection: close\r
        \r

        """

    var response = header.data(using: .utf8)!
    response.append(content)
    return response
}

func serveDirectoryListing(_ path: String, requestPath: String) -> Data {
    let fileManager = FileManager.default
    guard let items = try? fileManager.contentsOfDirectory(atPath: path) else {
        return makeResponse(code: 500, status: "Internal Server Error", body: "Could not list directory")
    }

    var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Index of \(requestPath)</title>
            <style>
                body { font-family: -apple-system, sans-serif; padding: 20px; }
                a { display: block; padding: 8px 0; color: #007aff; text-decoration: none; }
                a:hover { text-decoration: underline; }
            </style>
        </head>
        <body>
            <h1>Index of \(requestPath)</h1>
        """

    if requestPath != "/" {
        html += "<a href=\"..\">..</a>"
    }

    for item in items.sorted() {
        let itemPath = (path as NSString).appendingPathComponent(item)
        var isDir: ObjCBool = false
        fileManager.fileExists(atPath: itemPath, isDirectory: &isDir)
        let suffix = isDir.boolValue ? "/" : ""
        html += "<a href=\"\(item)\(suffix)\">\(item)\(suffix)</a>"
    }

    html += "</body></html>"

    return makeResponse(code: 200, status: "OK", body: html, contentType: "text/html")
}

func makeResponse(code: Int, status: String, body: String, contentType: String = "text/plain") -> Data {
    let response = """
        HTTP/1.1 \(code) \(status)\r
        Content-Type: \(contentType)\r
        Content-Length: \(body.utf8.count)\r
        Connection: close\r
        \r
        \(body)
        """
    return response.data(using: .utf8)!
}

// Start server
print("🌐 Starting server at http://localhost:\(port)")
print("📁 Serving files from: \(directory)")
print("Press Ctrl+C to stop\n")

let listener = try! NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: port)!)

listener.newConnectionHandler = { connection in
    connection.start(queue: .global())

    connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, _, _ in
        if let data = data {
            let response = handleRequest(data)
            connection.send(content: response, completion: .contentProcessed { _ in
                connection.cancel()
            })

            // Log request
            if let request = String(data: data, encoding: .utf8),
               let firstLine = request.split(separator: "\r\n").first {
                print("[\(Date())] \(firstLine)")
            }
        }
    }
}

listener.start(queue: .main)
dispatchMain()
