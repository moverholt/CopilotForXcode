import SwiftUI

@MainActor
final class WidgetViewModel: ObservableObject {
    @Published var isProcessing: Bool

    init(isProcessing: Bool = false) {
        self.isProcessing = isProcessing
    }
}

struct WidgetView: View {
    @ObservedObject var viewModel: WidgetViewModel
    @ObservedObject var panelViewModel: SuggestionPanelViewModel
    @State var isHovering: Bool = false
    @State var processingProgress: Double = 0

    var body: some View {
        Circle().fill(isHovering ? .white.opacity(0.8) : .white.opacity(0.3))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    panelViewModel.isPanelDisplayed.toggle()
                }
            }
            .overlay {
                let minimumLineWidth: Double = 4
                let lineWidth = (1 - processingProgress) * 28 + minimumLineWidth
                let scale = max(processingProgress * 1, 0.0001)
                let empty = panelViewModel.content == nil && panelViewModel.chat == nil

                ZStack {
                    Circle()
                        .stroke(
                            Color(nsColor: .darkGray),
                            style: .init(lineWidth: minimumLineWidth)
                        )
                        .padding(2)

                    #warning("TODO: Tweak the animation")
                    // how do I stop the repeatForever animation without removing the view?
                    // I tried many solutions found on stackoverflow but non of them works.
                    if viewModel.isProcessing {
                        Circle()
                            .stroke(
                                Color.accentColor,
                                style: .init(lineWidth: lineWidth)
                            )
                            .padding(2)
                            .scaleEffect(x: scale, y: scale)
                            .opacity(!empty || viewModel.isProcessing ? 1 : 0)
                            .animation(
                                .easeInOut(duration: 1).repeatForever(autoreverses: true),
                                value: processingProgress
                            )
                    } else {
                        Circle()
                            .stroke(
                                Color.accentColor,
                                style: .init(lineWidth: lineWidth)
                            )
                            .padding(2)
                            .scaleEffect(x: scale, y: scale)
                            .opacity(!empty || viewModel.isProcessing ? 1 : 0)
                            .animation(.easeInOut(duration: 1), value: processingProgress)
                    }
                }
            }
            .onChange(of: viewModel.isProcessing) { _ in refreshRing() }
            .onChange(of: panelViewModel.content?.contentHash) { _ in refreshRing() }
            .onHover { yes in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = yes
                }
            }.contextMenu {
                WidgetContextMenu()
            }
    }

    func refreshRing() {
        Task {
            await Task.yield()
            if viewModel.isProcessing {
                processingProgress = 1 - processingProgress
            } else {
                let empty = panelViewModel.content == nil && panelViewModel.chat == nil
                processingProgress = empty ? 0 : 1
            }
        }
    }
}

struct WidgetContextMenu: View {
    @AppStorage(\.useGlobalChat) var useGlobalChat
    @AppStorage(\.realtimeSuggestionToggle) var realtimeSuggestionToggle
    @AppStorage(\.acceptSuggestionWithAccessibilityAPI) var acceptSuggestionWithAccessibilityAPI
    @AppStorage(\.hideCommonPrecedingSpacesInSuggestion) var hideCommonPrecedingSpacesInSuggestion
    @AppStorage(\.forceOrderWidgetToFront) var forceOrderWidgetToFront

    var body: some View {
        Group {
            Button(action: {
                useGlobalChat.toggle()
            }) {
                Text("Use Global Chat")
                if useGlobalChat {
                    Image(systemName: "checkmark")
                }
            }

            Button(action: {
                realtimeSuggestionToggle.toggle()
            }) {
                Text("Realtime Suggestion")
                if realtimeSuggestionToggle {
                    Image(systemName: "checkmark")
                }
            }
            
            Button(action: {
                acceptSuggestionWithAccessibilityAPI.toggle()
            }, label: {
                Text("Accept Suggestion with Accessibility API")
                if acceptSuggestionWithAccessibilityAPI {
                    Image(systemName: "checkmark")
                }
            })
            
            Button(action: {
                hideCommonPrecedingSpacesInSuggestion.toggle()
            }, label: {
                Text("Hide Common Preceding Spaces in Suggestion")
                if hideCommonPrecedingSpacesInSuggestion {
                    Image(systemName: "checkmark")
                }
            })
            
            Button(action: {
                forceOrderWidgetToFront.toggle()
            }, label: {
                Text("Force Order Widget to Front")
                if forceOrderWidgetToFront {
                    Image(systemName: "checkmark")
                }
            })
            
            Divider()
            
            Button(action: {
                exit(0)
            }) {
                Text("Quit")
            }
        }
    }
}

struct WidgetView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            WidgetView(
                viewModel: .init(isProcessing: false),
                panelViewModel: .init(),
                isHovering: false
            )

            WidgetView(
                viewModel: .init(isProcessing: false),
                panelViewModel: .init(),
                isHovering: true
            )

            WidgetView(
                viewModel: .init(isProcessing: true),
                panelViewModel: .init(),
                isHovering: false
            )

            WidgetView(
                viewModel: .init(isProcessing: false),
                panelViewModel: .init(
                    content: .suggestion(SuggestionProvider(
                        code: "Hello",
                        startLineIndex: 0,
                        suggestionCount: 0,
                        currentSuggestionIndex: 0
                    ))
                ),
                isHovering: false
            )
        }
        .frame(width: 30)
        .background(Color.black)
    }
}
