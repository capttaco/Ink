/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

struct InlineCode: Fragment {
    var modifierTarget: Modifier.Target { .inlineCode }

    private var code: String

    var characterRange: Range<String.Index>
    
    static func read(using reader: inout Reader) throws -> InlineCode {
        try reader.read("`")
        var code = ""

        while !reader.didReachEnd {
            switch reader.currentCharacter {
            case \.isNewline:
                throw Reader.Error()
            case "`":
                reader.advanceIndex()
                return InlineCode(code: code, characterRange: (reader.currentIndex..<reader.currentIndex))
            default:
                if let escaped = reader.currentCharacter.escaped {
                    code.append(escaped)
                } else {
                    code.append(reader.currentCharacter)
                }

                reader.advanceIndex()
            }
        }

        throw Reader.Error()
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        return "<code>\(code)</code>"
    }

    func plainText() -> String {
        code
    }
}
