import Foundation

/// Extracts the field name from a keypath and formats it as a display-friendly string.
///
/// The extraction uses the keypath's debug description (e.g., `\State.userEmail`)
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
    fieldName = description
  }
  
  return formatFieldName(fieldName)
}

/// Formats a camelCase field name into a display-friendly "Title Case" string.
///
/// - Parameter name: The camelCase field name
/// - Returns: A formatted string with spaces before uppercase letters and capitalized first letter
private func formatFieldName(_ name: String) -> String {
  var result = ""
  for (index, char) in name.enumerated() {
    if char.isUppercase && index > 0 {
      result += " "
    }
    if index == 0 {
      result += char.uppercased()
    } else {
      result += String(char)
    }
  }
  return result
}
