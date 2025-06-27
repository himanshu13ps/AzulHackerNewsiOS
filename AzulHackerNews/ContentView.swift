import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = StoryViewModel()
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    NavigationView {
      ZStack {
        // Background gradient
        LinearGradient(
          gradient: Gradient(colors: [
            Color.azulSecondary,  // Top-leading corner (light blue)
            Color.azulPrimary,  // Middle (primary blue)
            Color.azulAccent, // Bottom-trailing corner (darker blue)
          ]),
          startPoint: colorScheme == .dark ? .bottomTrailing : .topLeading,
          endPoint: colorScheme == .dark ? .topLeading : .bottomTrailing
        )
        .ignoresSafeArea()

        if viewModel.isLoading && viewModel.stories.isEmpty {
          // Initial loading state
          VStack(spacing: 16) {
            ProgressView()
              .scaleEffect(1.2)
              .tint(.azulLoadingText)

            Text("Loading stories...")
              .font(.system(.subheadline, design: .default))
              .foregroundColor(.azulLoadingText)
              .accessibilityLabel("Loading stories from Hacker News")
              .dynamicTypeSize(...DynamicTypeSize.accessibility1)
          }
          .transition(.opacity.combined(with: .scale(scale: 0.9)))
        } else if let errorMessage = viewModel.errorMessage, viewModel.stories.isEmpty {
          // Error state for initial load
          VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
              .font(.system(size: 48))
              .foregroundColor(.azulAccent)

            Text("Failed to load stories")
              .font(.system(.headline, design: .default))
              .foregroundColor(.azulTextPrimary)
              .accessibilityAddTraits(.isHeader)
              .dynamicTypeSize(...DynamicTypeSize.accessibility2)

            Text(errorMessage)
              .font(.system(.subheadline, design: .default))
              .foregroundColor(.azulLoadingText)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
              .accessibilityLabel("Error: \(errorMessage)")
              .dynamicTypeSize(...DynamicTypeSize.accessibility1)

            Button("Retry") {
              Task {
                await viewModel.retryLoad()
              }
            }
            .buttonStyle(.borderedProminent)
            .tint(.azulPrimary)
            .accessibilityLabel("Retry loading stories")
            .accessibilityHint("Attempts to reload the story list")
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
          }
        } else {
          // Story list
          ScrollView {
            // Accessibility announcement for screen readers
            if !viewModel.stories.isEmpty {
              Text("\(viewModel.stories.count) stories loaded")
                .accessibilityHidden(true)
                .frame(width: 0, height: 0)
            }
            LazyVStack(spacing: 12) {
              ForEach(viewModel.stories) { story in
                CardView(story: story)
                  .padding(.horizontal)
                  .transition(
                    .asymmetric(
                      insertion: .opacity.combined(with: .move(edge: .bottom)),
                      removal: .opacity
                    )
                  )
                  .onAppear {
                    // Trigger loading more when approaching the end
                    if story.id == viewModel.stories.last?.id {
                      Task {
                        await viewModel.loadMoreStories()
                      }
                    }
                  }
              }

              // Loading more indicator
              if viewModel.isLoadingMore {
                HStack {
                  ProgressView()
                    .scaleEffect(0.8)
                    .tint(colorScheme == .dark ? .azulAccent : .azulLoadingText)
                  Text("Loading more...")
                    .font(.system(.caption, design: .default))
                    .foregroundColor(colorScheme == .dark ? .azulAccent : .azulLoadingText)
                    .accessibilityLabel("Loading more stories")
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                }
                .padding()
              }

              // Error handling for infinite scroll
              if let errorMessage = viewModel.errorMessage, !viewModel.stories.isEmpty {
                VStack(spacing: 12) {
                  Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)

                  Text("Failed to load more stories")
                    .font(.subheadline)
                    .foregroundColor(.azulTextPrimary)
                    .fontWeight(.medium)

                  Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.azulLoadingText)
                    .multilineTextAlignment(.center)

                  Button("Tap to retry") {
                    viewModel.clearError()
                    Task {
                      await viewModel.retryLoad()
                    }
                  }
                  .buttonStyle(.bordered)
                  .tint(.azulPrimary)
                }
                .padding()
                .background(Color.azulSecondary.opacity(0.5))
                .cornerRadius(8)
                .padding(.horizontal)
              }

              // End of stories message
              if viewModel.hasReachedEnd && !viewModel.stories.isEmpty
                && viewModel.errorMessage == nil
              {
                VStack(spacing: 8) {
                  Image(systemName: "checkmark.circle")
                    .font(.title2)
                    .foregroundColor(.azulAccent)

                  Text("You've reached the end!")
                    .font(.system(.subheadline, design: .default))
                    .foregroundColor(colorScheme == .dark ? .azulAccent : .azulLoadingText)
                    .accessibilityLabel("You have reached the end of the story list")
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                }
                .padding()
              }
            }
            .padding(.vertical)
          }
          .animation(.easeInOut(duration: 0.3), value: viewModel.stories.count)
        }
      }
      .navigationTitle("Hacker News")
      .navigationBarTitleDisplayMode(.large)
      .accessibilityLabel("Hacker News Stories")
      .accessibilityHint("Browse latest stories from Hacker News")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          StoryTypeToggle(
            selectedType: $viewModel.selectedStoryType,
            onSelectionChange: { newType in
              Task {
                await viewModel.switchStoryType(to: newType)
              }
            }
          )
          .accessibilityLabel("Story type selector")
          .accessibilityHint("Switch between top stories and new stories")
        }
      }
      .task {
        if viewModel.stories.isEmpty {
          await viewModel.loadInitialStories()
        }
      }
      .onReceive(
        NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
      ) { _ in
        // Handle memory warnings by cleaning up excess stories
        viewModel.cleanup()
      }
    }
  }
}

#Preview {
  ContentView()
}
