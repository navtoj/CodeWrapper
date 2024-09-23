//
//  DebugCommand.swift
//  SourceEditorExtension
//
//  Created by Navtoj Chahal on 2024-09-22.
//

import Foundation
import XcodeKit

// Conditional Compilation Block
// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/statements/#Conditional-Compilation-Block

private let debugIf = "#if DEBUG"
private let debugElse = "#else"
private let debugElseIf = "#elseif"
private let debugEndIf = "#endif"

class DebugCommand: NSObject, XCSourceEditorCommand {
	private let domain = (Bundle.main.bundleIdentifier ?? "CodeWrapper") + "." + DebugCommand.className()

	private func handleCompletion(with handler: @escaping (Error?) -> Void, message: String) -> Void {
		handler(NSError(
			domain: domain,
			code: 1,
			userInfo: [NSLocalizedDescriptionKey: message]
		))
	}

	func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
		let lines = invocation.buffer.lines
		let selections = invocation.buffer.selections

		var linesToUpdate: [(index: Int, text: String?)] = []

		for selection in selections {
			if let range = selection as? XCSourceTextRange {
				let startLineIndex = range.start.line
				let endLineIndex = range.end.line

				// Ensure Valid Selection

				if startLineIndex >= lines.count || endLineIndex >= lines.count {
					return handleCompletion(with: completionHandler, message: "Selection out of bounds.")
				}

				// Ensure Clean Selection

				for i in startLineIndex...endLineIndex {
					if i < lines.count,
					   let line = lines[i] as? String {
						let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

						// Check Compilation Blocks

						if (trimmed == debugIf ||
							trimmed == debugElseIf ||
							trimmed == debugElse ||
							trimmed == debugEndIf
						) {
							return handleCompletion(with: completionHandler, message: "Selection contains compilation block.")
						}
					}
				}

				// Calculate Offset

				let linesToAdd = linesToUpdate.count(where: { $0.text != nil })
				let linesToRemove = linesToUpdate.count(where: { $0.text == nil })
				let offset = linesToAdd - linesToRemove

				// Toggle Block

				if startLineIndex > 0,
				   endLineIndex < lines.count - 1,
				   let preStart = lines[startLineIndex - 1] as? String,
				   let postEnd = lines[endLineIndex + 1] as? String,
				   preStart.trimmingCharacters(in: .whitespacesAndNewlines) == debugIf,
				   postEnd.trimmingCharacters(in: .whitespacesAndNewlines) == debugEndIf {

					// Get Removal Indices

					let startIndex = startLineIndex - 1 + offset
					let endIndex = endLineIndex + offset

					// Queue Lines to Remove

					linesToUpdate.append((index: startIndex, text: nil))
					linesToUpdate.append((index: endIndex, text: nil))
				} else {

					// Check Empty Selection

					if areStringsEmptyInRange(lines, start: startLineIndex, end: endLineIndex) {
						return handleCompletion(with: completionHandler, message: "Selection is empty.")
					}

					// Get Insertion Indices

					let startIndex = startLineIndex + offset
					let endIndex = endLineIndex + 2 + offset

					// Queue Lines to Add

					linesToUpdate.append((index: startIndex, text: debugIf))
					linesToUpdate.append((index: endIndex, text: debugEndIf))
				}
			}
		}

		// Update Lines

		for (index, line) in linesToUpdate {
			if let text = line {
				lines.insert(text, at: index)
			} else {
				lines.removeObject(at: index)
			}
		}

		// Signal to Xcode that the command has completed.
		// Pass it nil on success, and an NSError on failure.
		completionHandler(nil)
	}
}

// Helper Function

private func areStringsEmptyInRange(_ lines: NSMutableArray, start: Int, end: Int) -> Bool {
	for i in start...end {
		if i < lines.count,
		   let line = lines[i] as? String,
		   !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			return false
		}
	}
	return true
}
