import ArgumentParser
import XCTest

@testable import RakuyoSwiftFormatTool

// MARK: - RakuyoSwiftFormatToolTest

final class RakuyoSwiftFormatToolTest: XCTestCase {
    func testFormatWithNoViolations() {
        var ranSwiftFormat = false
        var ranSwiftLint = false
        var ranSwiftLintAutocorrect = false

        let error = runFormatTool(
            with: MockCommands(
                swiftFormat: {
                    ranSwiftFormat = true
                    return EXIT_SUCCESS
                },
                swiftLint: {
                    ranSwiftLint = true
                    return EXIT_SUCCESS
                },
                swiftLintAutocorrect: {
                    ranSwiftLintAutocorrect = true
                    return EXIT_SUCCESS
                }
            )
        )

        XCTAssertNil(error)
        XCTAssertTrue(ranSwiftFormat)
        XCTAssertTrue(ranSwiftLint)
        XCTAssertTrue(ranSwiftLintAutocorrect)
    }

    func testLintWithNoViolations() {
        var ranSwiftFormat = false
        var ranSwiftLint = false
        var ranSwiftLintAutocorrect = false

        let error = runFormatTool(
            arguments: ["--lint"],
            with: MockCommands(
                swiftFormat: {
                    ranSwiftFormat = true
                    return EXIT_SUCCESS
                },
                swiftLint: {
                    ranSwiftLint = true
                    return EXIT_SUCCESS
                },
                swiftLintAutocorrect: {
                    ranSwiftLintAutocorrect = true
                    return EXIT_SUCCESS
                }
            )
        )

        XCTAssertNil(error)
        XCTAssertTrue(ranSwiftFormat)
        XCTAssertTrue(ranSwiftLint)

        // Should't run SwiftLint autocorrect in lint-only mode
        XCTAssertFalse(ranSwiftLintAutocorrect)
    }

    func testFormatWithViolations() {
        var ranSwiftFormat = false
        var ranSwiftLint = false
        var ranSwiftLintAutocorrect = false

        let error = runFormatTool(
            with: MockCommands(
                swiftFormat: {
                    ranSwiftFormat = true

                    // When autocorrecting SwiftFormat returns EXIT_SUCCESS
                    // even if there were violations that were fixed
                    return EXIT_SUCCESS
                },
                swiftLint: {
                    ranSwiftLint = true
                    return SwiftLintExitCode.lintFailure
                },
                swiftLintAutocorrect: {
                    ranSwiftLintAutocorrect = true

                    // When autocorrecting SwiftLint returns EXIT_SUCCESS
                    // even if there were violations that were fixed
                    return EXIT_SUCCESS
                }
            )
        )

        XCTAssertEqual(error as? ExitCode, ExitCode(SwiftFormatExitCode.lintFailure))
        XCTAssertTrue(ranSwiftFormat)
        XCTAssertTrue(ranSwiftLint)
        XCTAssertTrue(ranSwiftLintAutocorrect)
    }

    func testFormatWithOnlySwiftLintAutocorrectedViolation() {
        var ranSwiftFormat = false
        var ranSwiftLint = false
        var ranSwiftLintAutocorrect = false

        let error = runFormatTool(
            with: MockCommands(
                swiftFormat: {
                    ranSwiftFormat = true
                    return EXIT_SUCCESS
                },
                swiftLint: {
                    ranSwiftLint = true

                    // Assume that the codebase has violations that would be corrected by SwiftLint autocorrect.
                    if ranSwiftLintAutocorrect {
                        // If SwiftLint autocorrect has already run, then there are no more violations.
                        // This is the expected behavior.
                        return EXIT_SUCCESS
                    }
                    // If SwiftLint autocorrect hasn't run yet, then there are still violations.
                    // This should not happen, because we run autocorrect first.
                    return SwiftLintExitCode.lintFailure
                },
                swiftLintAutocorrect: {
                    // Assume that this SwiftLint autocorrect invocation applied a code change.
                    // In this case, SwiftLint still returns a zero exit code.
                    ranSwiftLintAutocorrect = true
                    return EXIT_SUCCESS
                }
            )
        )

        // Even though there was a SwiftLint failure, it was autocorrected so doesn't require attention.
        // The tool should not return an error (e.g. it should return a zero exit code).
        XCTAssertNil(error)

        XCTAssertTrue(ranSwiftFormat)
        XCTAssertTrue(ranSwiftLint)
        XCTAssertTrue(ranSwiftLintAutocorrect)
    }

    func testLintWithViolations() {
        var ranSwiftFormat = false
        var ranSwiftLint = false
        var ranSwiftLintAutocorrect = false

        let error = runFormatTool(
            arguments: ["--lint"],
            with: MockCommands(
                swiftFormat: {
                    ranSwiftFormat = true
                    return SwiftFormatExitCode.lintFailure
                },
                swiftLint: {
                    ranSwiftLint = true
                    return SwiftLintExitCode.lintFailure
                },
                swiftLintAutocorrect: {
                    ranSwiftLintAutocorrect = true
                    return EXIT_SUCCESS
                }
            )
        )

        XCTAssertEqual(error as? ExitCode, ExitCode.failure)
        XCTAssertTrue(ranSwiftFormat)
        XCTAssertTrue(ranSwiftLint)
        XCTAssertFalse(ranSwiftLintAutocorrect)
    }

    func testLintWithOnlySwiftLintViolation() {
        var ranSwiftFormat = false
        var ranSwiftLint = false
        var ranSwiftLintAutocorrect = false

        let error = runFormatTool(
            arguments: ["--lint"],
            with: MockCommands(
                swiftFormat: {
                    ranSwiftFormat = true
                    return EXIT_SUCCESS
                },
                swiftLint: {
                    ranSwiftLint = true
                    return SwiftLintExitCode.lintFailure
                },
                swiftLintAutocorrect: {
                    ranSwiftLintAutocorrect = true
                    return EXIT_SUCCESS
                }
            )
        )

        XCTAssertEqual(error as? ExitCode, ExitCode.failure)
        XCTAssertTrue(ranSwiftFormat)
        XCTAssertTrue(ranSwiftLint)
        XCTAssertFalse(ranSwiftLintAutocorrect)
    }

    func testLintWithOnlySwiftFormatViolation() {
        var ranSwiftFormat = false
        var ranSwiftLint = false
        var ranSwiftLintAutocorrect = false

        let error = runFormatTool(
            arguments: ["--lint"],
            with: MockCommands(
                swiftFormat: {
                    ranSwiftFormat = true
                    return SwiftFormatExitCode.lintFailure
                },
                swiftLint: {
                    ranSwiftLint = true
                    return EXIT_SUCCESS
                },
                swiftLintAutocorrect: {
                    ranSwiftLintAutocorrect = true
                    return EXIT_SUCCESS
                }
            )
        )

        XCTAssertEqual(error as? ExitCode, ExitCode.failure)
        XCTAssertTrue(ranSwiftFormat)
        XCTAssertTrue(ranSwiftLint)
        XCTAssertFalse(ranSwiftLintAutocorrect)
    }

    func testHandlesUnexpectedErrorCode() {
        let unexpectedSwiftFormatExitCode = runFormatTool(
            with: MockCommands(swiftFormat: { 1234 })
        )

        let unexpectedSwiftLintExitCode = runFormatTool(
            with: MockCommands(swiftLint: { 42 })
        )

        XCTAssertEqual(unexpectedSwiftFormatExitCode as? ExitCode, ExitCode(1234))
        XCTAssertEqual(unexpectedSwiftLintExitCode as? ExitCode, ExitCode(42))
    }
}

// MARK: - Private

extension RakuyoSwiftFormatToolTest {
    /// Runs `RakuyoSwiftFormatTool` with the `Command` calls mocked using the given mocks
    private func runFormatTool(arguments: [String]? = nil, with mocks: MockCommands) -> Error? {
        let existingRunCommandImplementation = Command.runCommand

        Command.runCommand = mocks.mockRunCommand(_:)
        defer { Command.runCommand = existingRunCommandImplementation }

        do {
            let formatTool = try RakuyoSwiftFormatTool.parse([
                "Sources",
                "--swift-format-path",
                "rakuyo.swiftformat",
                "--swift-lint-path",
                "swiftlint.yml",
            ] + (arguments ?? []))

            try formatTool.run()
            return nil
        } catch {
            return error
        }
    }
}

// MARK: - MockCommands

/// Mock implementations of the commands ran by `RakuyoSwiftFormatTool`
struct MockCommands {
    var swiftFormat: (() -> Int32)? = nil
    var swiftLint: (() -> Int32)? = nil
    var swiftLintAutocorrect: (() -> Int32)? = nil
    
    func mockRunCommand(_ command: Command) -> Int32 {
        if command.launchPath.lowercased().contains("swiftformat") {
            return swiftFormat?() ?? EXIT_SUCCESS
        }
        
        if command.launchPath.lowercased().contains("swiftlint") {
            if command.arguments.contains("--fix") {
                return swiftLintAutocorrect?() ?? EXIT_SUCCESS
            }
            return swiftLint?() ?? EXIT_SUCCESS
        }
        
        fatalError("Unexpected command: \(command)")
    }
}
