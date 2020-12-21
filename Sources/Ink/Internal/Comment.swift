/**
*  Ink
*  Copyright (c) John Sundell 2019
*  (Extension by Rob Rhyne, 2020)
*  MIT license, see LICENSE file for details
*/

internal struct Comment: Fragment {
    var modifierTarget: Modifier.Target { .comments }
    
    private var rawText: Substring
    
    var characterRange: Range<String.Index>
    
    static func read(using reader: inout Reader) throws -> Comment {
        try reader.read("%")
        try reader.read("%")
        try reader.readWhitespaces()
        var text = reader.readUntilEndOfLine()
        
        while !reader.didReachEnd {
            switch reader.currentCharacter {
            case \.isNewline:
                return Comment(rawText: text, characterRange: reader.currentIndex..<reader.currentIndex)
            case "%":
                reader.advanceIndex()
            default:
                break
            }

            text += reader.readUntilEndOfLine()
        }
        
        return Comment(rawText: text, characterRange: reader.currentIndex..<reader.currentIndex)
    }
    
    func html(usingURLs urls: NamedURLCollection, modifiers: ModifierCollection) -> String {
        return ""
    }
    
    func plainText() -> String {
        return ""
    }
}
