/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Link: Fragment {
    var modifierTarget: Modifier.Target { .links }

    var target: Target
    var text: FormattedText
    
    var characterRange: Range<String.Index>

    static func read(using reader: inout Reader) throws -> Link {
        try reader.read("[")
        if reader.currentCharacter == "^" {
            let number = try reader.read(until: "]")
            return Link(target: .footnote(number), text: FormattedText(), characterRange: reader.currentIndex..<reader.currentIndex)
        }
        let text = FormattedText.read(using: &reader, terminators: ["]"])
        try reader.read("]")

        guard !reader.didReachEnd else { throw Reader.Error() }

        if reader.currentCharacter == "(" {
            reader.advanceIndex()
            let url = try reader.read(until: ")")
            return Link(target: .url(url), text: text, characterRange: (reader.currentIndex..<reader.currentIndex))
        } else {
            try reader.read("[")
            let reference = try reader.read(until: "]")
            return Link(target: .reference(reference), text: text, characterRange: (reader.currentIndex..<reader.currentIndex))
        }
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let url = target.url(from: urls)
        
        switch target {
        case .footnote(let note):
            let number = note.dropFirst(1)
            let title = "<sup>[\(number)]</sup>"
            return "<a id=\"fnref\(number)\" href=\"\(url)\">\(title)</a>"
        default:
            let title = text.html(usingURLs: urls, modifiers: modifiers)
            return "<a href=\"\(url)\">\(title)</a>"
        }
    }

    func plainText() -> String {
        text.plainText()
    }
}

extension Link {
    enum Target {
        case url(URL)
        case reference(Substring)
        case footnote(Substring)
    }
}

extension Link.Target {
    func url(from urls: NamedURLCollection) -> URL {
        switch self {
        case .url(let url):
            return url
        case .reference(let name):
            return urls.url(named: name) ?? name
        case .footnote(let note):
            let trimmed = note.dropFirst(1)
            return "#fn\(trimmed)"
        }
    }
}
