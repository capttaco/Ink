/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct URLDeclaration: Fragment {
    var modifierTarget: Modifier.Target { .linkDeclaration }
    
    var name: String
    var url: URL
    var footnoteText: FormattedText?
    var characterRange: Range<String.Index>

    static func read(using reader: inout Reader) throws -> Self {
        var isFootnote = false
        try reader.read("[")
        if reader.currentCharacter == "^" {
            isFootnote = true
        }
        let name = try reader.read(until: "]")
        try reader.read(":")
        try reader.readWhitespaces()
        if isFootnote {
            let text = FormattedText.readLine(using: &reader)
            return URLDeclaration(name: name.lowercased(), url: name, footnoteText: text, characterRange: reader.currentIndex..<reader.currentIndex)
        }
        let url = reader.readUntilEndOfLine()
        return URLDeclaration(name: name.lowercased(), url: url, characterRange: reader.currentIndex..<reader.currentIndex)
    }
    
    func html(usingURLs urls: NamedURLCollection, modifiers: ModifierCollection) -> String {
        guard let foot = footnoteText else { return "" }
        let number = name.dropFirst(1)
        let body = foot.html(usingURLs: urls, modifiers: modifiers)
        return "<li id=\"fn\(number)\" class=\"footnote-item\"><p>\(body) <a href=\"#fnref\(number)\" class=\"footnote-backref\">↩︎</a></p></li>"
    }
    
    func plainText() -> String {
        return ""
    }
}
