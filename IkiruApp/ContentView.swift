import SwiftUI

struct ContentView: View {
    @State private var isLoading = true
    @State private var canGoBack = false
    @State private var canGoForward = false
    @StateObject private var webViewStore = WebViewStore()

    var body: some View {
        VStack(spacing: 0) {
            WebView(url: URL(string: "https://ikiru.id")!, store: webViewStore)
                .overlay(
                    Group {
                        if isLoading {
                            ZStack {
                                Color(UIColor.systemBackground)
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                    Text("Memuat ikiru.id...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                )
                .onReceive(webViewStore.$isLoading) { loading in
                    isLoading = loading
                }
                .onReceive(webViewStore.$canGoBack) { value in
                    canGoBack = value
                }
                .onReceive(webViewStore.$canGoForward) { value in
                    canGoForward = value
                }

            // Navigation bar
            HStack(spacing: 0) {
                Button(action: { webViewStore.goBack() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .disabled(!canGoBack)
                .foregroundColor(canGoBack ? .primary : .secondary)

                Button(action: { webViewStore.goForward() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .disabled(!canGoForward)
                .foregroundColor(canGoForward ? .primary : .secondary)

                Button(action: { webViewStore.reload() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .foregroundColor(.primary)

                Button(action: { webViewStore.goHome() }) {
                    Image(systemName: "house")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .foregroundColor(.primary)
            }
            .background(Color(UIColor.systemBackground).shadow(color: .black.opacity(0.08), radius: 4, y: -2))
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ContentView()
}
