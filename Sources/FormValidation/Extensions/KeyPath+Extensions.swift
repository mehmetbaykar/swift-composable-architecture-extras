import Foundation

/// Extracts the field name from a keypath and formats it as a display-friendly string.
///
/// The extraction uses the keypath's string description (e.g., `\State.userEmail`)
/// and extracts the property name portion after the last dot.
///
/// The resulting field name is formatted for display by:
/// - Capitalizing the first letter
/// - Inserting spaces before uppercase letters (converting camelCase to "Title Case")
///
/// Examples:
/// - `\.email` → "Email"
/// - `\.userAge` → "User Age"
/// - `\.firstName` → "First Name"
///
/// - Note: This implementation relies on Swift's KeyPath string representation.
///   Field names with consecutive uppercase letters (acronyms like `userID`)
///   will be formatted as "User I D". For custom formatting of acronyms,
///   use explicit field names in validation rules.
///
/// - Parameter keyPath: The keypath to extract the field name from
/// - Returns: A formatted display string for the field name
public func extractFieldName<Root, Value>(from keyPath: KeyPath<Root, Value>) -> String {
  let description = String(describing: keyPath)

  // Extract the property name from the keypath description
  // Format is "\TypeName.fieldName" or "\TypeName.nested.fieldName"
  let fieldName: String
  if let dotIndex = description.lastIndex(of: ".") {
    fieldName = String(description[description.index(after: dotIndex)...])
  } else {
    // Fallback: remove leading backslash if present, otherwise use as-is
    fieldName = description.hasPrefix("\\") ? String(description.dropFirst()) : description
  }

  return formatFieldName(fieldName)
}

/// Formats a camelCase field name into a display-friendly "Title Case" string.
///
/// - Parameter name: The camelCase field name
/// - Returns: A formatted string with spaces before uppercase letters and capitalized first letter
private func formatFieldName(_ name: String) -> String {
  guard !name.isEmpty else { return name }

  var characters: [Character] = []
  characters.reserveCapacity(name.count + 5)  // Estimate a few extra spaces

  for (index, char) in name.enumerated() {
    if char.isUppercase && index > 0 {
      characters.append(" ")
    }
    if index == 0 {
      characters.append(contentsOf: char.uppercased())
    } else {
      characters.append(char)
    }
  }
  return String(characters)
}
