import CoreServices
import Foundation

// Narrow watcher: ~/Reports + GitHub trees, but notify only for final reports or .log files.
let home = FileManager.default.homeDirectoryForCurrentUser
let watchedRoots = [
    home.appendingPathComponent("Reports", isDirectory: true),
    home.appendingPathComponent("Documents/GitHub", isDirectory: true),
]
let ignoredNames: Set<String> = [".DS_Store"]
let reportDebounce: TimeInterval = 1.0
let logDebounce: TimeInterval = 300.0

func appleScriptLiteral(_ value: String) -> String {
    let escaped = value
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: " ")
    return "\"\(escaped)\""
}

func isGitInternal(_ path: String) -> Bool {
    path.lowercased().contains("/.git/")
}

/// Only final reports (name contains both "final" and "report") or .log files.
func isAlertableFile(_ path: String) -> Bool {
    if isGitInternal(path) { return false }
    let name = URL(fileURLWithPath: path).lastPathComponent.lowercased()
    if ignoredNames.contains(name) { return false }
    if name.hasSuffix(".log") { return true }
    return name.contains("final") && name.contains("report")
}

func debounceInterval(for path: String) -> TimeInterval {
    let name = URL(fileURLWithPath: path).lastPathComponent.lowercased()
    return name.hasSuffix(".log") ? logDebounce : reportDebounce
}

func notifyReportChange(_ path: String, title: String) {
    let fileName = URL(fileURLWithPath: path).lastPathComponent
    let relativePath = watchedRoots
        .first(where: { path.hasPrefix($0.path + "/") })
        .map { path.replacingOccurrences(of: $0.path + "/", with: "") } ?? path
    let script = "display notification \(appleScriptLiteral(relativePath)) with title \(appleScriptLiteral(title)) subtitle \(appleScriptLiteral(fileName)) sound name \"Glass\""

    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    task.arguments = ["-e", script]
    try? task.run()
}

let callback: FSEventStreamCallback = { _, info, eventCount, eventPaths, eventFlags, _ in
    guard let info else { return }
    let watcher = Unmanaged<ReportsWatcher>.fromOpaque(info).takeUnretainedValue()
    let paths = Unmanaged<NSArray>.fromOpaque(eventPaths).takeUnretainedValue() as! [String]

    for index in 0..<Int(eventCount) {
        let flags = eventFlags[index]
        let path = paths[index]

        guard flags & UInt32(kFSEventStreamEventFlagItemIsFile) != 0 else { continue }
        guard isAlertableFile(path) else { continue }

        let isNewFile = flags & UInt32(kFSEventStreamEventFlagItemCreated) != 0
        let isContentChange = flags & UInt32(kFSEventStreamEventFlagItemModified) != 0
        let isAtomicSave = flags & UInt32(kFSEventStreamEventFlagItemRenamed) != 0
        guard isNewFile || isContentChange || isAtomicSave else { continue }
        guard watcher.shouldNotify(path: path) else { continue }

        let wasKnown = watcher.knownFiles.contains(path)
        watcher.knownFiles.insert(path)
        let title = isNewFile && !wasKnown ? "New file saved" : "File updated"
        let event = "\(title): \(path)\n"
        FileHandle.standardOutput.write(event.data(using: .utf8)!)
        notifyReportChange(path, title: title)
    }
}

final class ReportsWatcher {
    var knownFiles: Set<String> = []
    private var lastNotification: [String: Date] = [:]

    func shouldNotify(path: String) -> Bool {
        let now = Date()
        defer { lastNotification[path] = now }
        guard let last = lastNotification[path] else { return true }
        return now.timeIntervalSince(last) >= debounceInterval(for: path)
    }
}

for root in watchedRoots {
    guard FileManager.default.fileExists(atPath: root.path) else {
        fputs("Watched directory does not exist: \(root.path)\n", stderr)
        exit(1)
    }
}

let watcher = ReportsWatcher()
let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(watcher).toOpaque())
var streamContext = FSEventStreamContext(
    version: 0,
    info: context,
    retain: nil,
    release: nil,
    copyDescription: nil
)

guard let stream = FSEventStreamCreate(
    kCFAllocatorDefault,
    callback,
    &streamContext,
    watchedRoots.map(\.path) as CFArray,
    FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
    0.5,
    FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes)
) else {
    fputs("Could not create FSEvent stream\n", stderr)
    exit(1)
}

FileHandle.standardOutput.write("ReportsFileAlert started (final reports + .log only)\n".data(using: .utf8)!)
FSEventStreamSetDispatchQueue(stream, DispatchQueue.main)
FSEventStreamStart(stream)
dispatchMain()
