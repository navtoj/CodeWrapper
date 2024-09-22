//
//  SourceEditorExtension.swift
//  SourceEditorExtension
//
//  Created by Navtoj Chahal on 2024-09-22.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {

	// If your extension needs to do any work at launch, implement this optional method.

	/*
	func extensionDidFinishLaunching() {}
	*/

	// If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.

	/*
	var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
		guard let bundleId = Bundle(for: type(of: self)).bundleIdentifier else { return [] }
		return [
			makeDefinition(bundleId, DebugCommand.className(), "#if DEBUG")
		]
	}
	*/
}

// Helper Function

/*
private func makeDefinition(
	_ bundleId: String,
	_ className: String,
	_ commandName: String
) -> [XCSourceEditorCommandDefinitionKey: Any] {
	[
		XCSourceEditorCommandDefinitionKey.identifierKey: bundleId + "." + className,
		XCSourceEditorCommandDefinitionKey.classNameKey: className,
		XCSourceEditorCommandDefinitionKey.nameKey: commandName
	]
}
*/
