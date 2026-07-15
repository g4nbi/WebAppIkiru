import SwiftUI
import WebKit
import Combine

class WebViewStore: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    var webView: WKWebView?
    private let homeURL = URL(string: "https://ikiru.id")!

    func goBack() { webView?.goBack() }
    func goForward() { webView?.goForward() }
    func reload() { webView?.reload() }
    func goHome() {
        webView?.load(URLRequest(url: homeURL))
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @ObservedObject var store: WebViewStore

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Apply ad blocking rules
        AdBlocker.apply(to: config) {
            // Rules loaded
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic

        // Inject CSS to hide common ad containers
        let cssScript = WKUserScript(
            source: AdBlocker.cssHideScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        webView.configuration.userContentController.addUserScript(cssScript)

        store.webView = webView
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(store: store)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var store: WebViewStore

        init(store: WebViewStore) {
            self.store = store
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.store.isLoading = true
                self.store.canGoBack = webView.canGoBack
                self.store.canGoForward = webView.canGoForward
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.store.isLoading = false
                self.store.canGoBack = webView.canGoBack
                self.store.canGoForward = webView.canGoForward
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.store.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.store.isLoading = false
            }
        }

        // Allow all navigation within the app
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            decisionHandler(.allow)
        }
    }
}
