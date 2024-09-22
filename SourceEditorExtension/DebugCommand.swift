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

	func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
		let lines = invocation.buffer.lines
		let selections = invocation.buffer.selections

		var linesToUpdate: [(index: Int, text: String?)] = []

		for selection in selections {
			if let range = selection as? XCSourceTextRange {
				let start = range.start.line
				let end = range.end.line

				// Ensure Clean Selection

				for i in start...end {
					if let line = lines[i] as? String {
						let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

						// Check Compilation Blocks

						if (trimmed == debugIf ||
							trimmed == debugElseIf ||
							trimmed == debugElse ||
							trimmed == debugEndIf
						) {
							completionHandler(NSError(
								domain: domain,
								code: 1,
								userInfo: [NSLocalizedDescriptionKey: "Selection contains compilation block."]
							))
						}

						// Check Block Braces

						if trimmed.hasSuffix("{") || trimmed.hasSuffix("}") {
							completionHandler(NSError(
								domain: domain,
								code: 1,
								userInfo: [NSLocalizedDescriptionKey: "Selection contains block braces."]
							))
						}

						// Check Array Braces

						if trimmed.hasSuffix("[") || trimmed.hasSuffix("]") {
							completionHandler(NSError(
								domain: domain,
								code: 1,
								userInfo: [NSLocalizedDescriptionKey: "Selection contains array braces."]
							))
						}

						// Check Tuple Braces

						if trimmed.hasSuffix("(") || trimmed.hasSuffix(")") {
							completionHandler(NSError(
								domain: domain,
								code: 1,
								userInfo: [NSLocalizedDescriptionKey: "Selection contains tuple braces."]
							))
						}
					}
				}

				// Calculate Offset

				let offset = linesToUpdate.count(where: { $0.text != nil }) - linesToUpdate.count(where: { $0.text == nil })

				// Toggle Block

				if let preStart = lines[start - 1] as? String,
				   let postEnd = lines[end + 1] as? String,
				   preStart.trimmingCharacters(in: .whitespacesAndNewlines) == debugIf,
				   postEnd.trimmingCharacters(in: .whitespacesAndNewlines) == debugEndIf {

					// Get Removal Indices

					let startIndex = start - 1 + offset
					let endIndex = end + offset

					// Queue Lines to Remove

					linesToUpdate.append((index: startIndex, text: nil))
					linesToUpdate.append((index: endIndex, text: nil))
				} else {

					// Get Insertion Indices


					let startIndex = start + offset
					let endIndex = end + 2 + offset

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
