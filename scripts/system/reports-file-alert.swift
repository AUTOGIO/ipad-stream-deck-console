import CoreServices
import Foundation

// Narrow watcher: personal Reports tree only (not ~/Documents).
let home = FileManager.default.homeDirectoryForCurrentUser
let watchedRoots = [
    home.appendingPathComponent("Reports", isDirectory: true),
]
let ignoredNames: Set<String> = [".DS_Store"]
let notificationDebounce: TimeInterval = 1.0

func existingFiles(at roots: [URL]) -> Set<String> {
    var paths = Set<String>()
    for root in roots {
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            continue
        }
        for case let url as URL in enumerator {
            guard (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else {
                continue
            }
            paths.insert(url.path)
        }
    }
    return paths
}

func appleScriptLiteral(_ value: String) -> String {
    let escaped = value
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: " ")
    return "\"\(escaped)\""
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
        let url = URL(fileURLWithPath: path)

        guard flags & UInt32(kFSEventStreamEventFlagItemIsFile) != 0 else { continue }
        guard !ignoredNames.contains(url.lastPathComponent) else { continue }

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
    var knownFiles: Set<String>
    private var lastNotification: [String: Date] = [:]

    init(knownFiles: Set<String>) {
        self.knownFiles = knownFiles
    }

    func shouldNotify(path: String) -> Bool {
        let now = Date()
        defer { lastNotification[path] = now }
        guard let last = lastNotification[path] else { return true }
        return now.timeIntervalSince(last) >= notificationDebounce
    }
}

for root in watchedRoots {
    guard FileManager.default.fileExists(atPath: root.path) else {
        fputs("Watched directory does not exist: \(root.path)\n", stderr)
        exit(1)
    }
}

let watcher = ReportsWatcher(knownFiles: existingFiles(at: watchedRoots))
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

FSEventStreamSetDispatchQueue(stream, DispatchQueue.main)
FSEventStreamStart(stream)
dispatchMain()
