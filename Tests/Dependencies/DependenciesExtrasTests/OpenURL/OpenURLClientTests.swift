#if !os(watchOS)

  import Dependencies
  import Foundation
  import Testing

  @testable import OpenURL

  private let testURL = URL(string: "https://example.com")!

  @MainActor
  private final class OpenURLRecorder: Sendable {
    nonisolated(unsafe) var openedURLs: [URL] = []

    #if os(iOS)
      nonisolated(unsafe) var inAppURLs: [URL] = []
    #endif

    var client: OpenURLClient {
      #if os(iOS)
        OpenURLClient(
          open: { [self] url in
            openedURLs.append(url)
            return true
          },
          openInApp: { [self] url in
            inAppURLs.append(url)
            return true
          }
        )
      #else
        OpenURLClient(open: { [self] url in
          openedURLs.append(url)
          return true
        })
      #endif
    }
  }

  @Suite("OpenURLClient")
  @MainActor
  struct OpenURLClientTests {

    @Suite("CustomValues")
    @MainActor
    struct CustomValueTests {

      @Test func `custom open records URL and returns true`() async {
        let recorder = OpenURLRecorder()
        let result = await recorder.client.open(testURL)
        #expect(result == true)
        #expect(recorder.openedURLs == [testURL])
      }

      @Test func `noop returns true`() async {
        let client = OpenURLClient.noop
        let result = await client.open(testURL)
        #expect(result == true)
      }

      #if os(iOS)
        @Test func `custom openInApp records URL`() async {
          let recorder = OpenURLRecorder()
          let result = await recorder.client.openInApp(testURL)
          #expect(result == true)
          #expect(recorder.inAppURLs == [testURL])
        }
      #endif
    }

    @Suite("WithDependencies")
    @MainActor
    struct WithDependenciesTests {

      @Test func `overridden dependency records URL`() async {
        let recorder = OpenURLRecorder()

        await withDependencies {
          $0.customOpenURL = recorder.client
        } operation: {
          @Dependency(\.customOpenURL) var customOpenURL
          _ = await customOpenURL.open(testURL)
        }

        #expect(recorder.openedURLs == [testURL])
      }

      @Test func `noop dependency override does not throw`() async {
        await withDependencies {
          $0.customOpenURL = .noop
        } operation: {
          @Dependency(\.customOpenURL) var customOpenURL
          _ = await customOpenURL.open(testURL)
        }
      }
    }

    @Suite("callAsFunction")
    @MainActor
    struct CallAsFunctionTests {

      @Test func `external call dispatches to open`() async {
        let recorder = OpenURLRecorder()
        let result = await recorder.client(testURL)
        #expect(result == true)
        #expect(recorder.openedURLs == [testURL])
      }

      #if os(iOS)
        @Test func `prefersInApp true dispatches to openInApp`() async {
          let recorder = OpenURLRecorder()
          let result = await recorder.client(testURL, prefersInApp: true)
          #expect(result == true)
          #expect(recorder.inAppURLs == [testURL])
          #expect(recorder.openedURLs.isEmpty)
        }

        @Test func `prefersInApp false dispatches to open`() async {
          let recorder = OpenURLRecorder()
          let result = await recorder.client(testURL, prefersInApp: false)
          #expect(result == true)
          #expect(recorder.openedURLs == [testURL])
          #expect(recorder.inAppURLs.isEmpty)
        }
      #endif
    }
  }

#endif
