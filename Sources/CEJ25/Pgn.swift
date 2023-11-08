import Foundation
import RegexBuilder

struct PgnMove {
  var comment: String
  var nag: Int
  var rav: [String]
  let san: String
}

struct Pgn {
  let fen: String
  let input: String
  let moves: [PgnMove]
  let prelude: String
  let tags: [Tag]

  func validate() throws -> Chess {
    let chess = Chess()

    if fen != "" {
      chess.load(fen: fen)
    }

    for tag in tags {
      chess.setTag(tag: tag.name, value: tag.value)
    }

    if prelude != "" {
      chess.setComment(comment: prelude, nag: 0)
    }

    for move in moves {
      let _ = try chess.move(san: move.san)
      if move.comment != "" || move.nag != 0 {
        chess.setComment(comment: move.comment, nag: move.nag)
      }
    }

    return chess
  }

  static func parseMultiGame(_ pgn: String) -> [Pgn] {
    var pgns: [String] = []
    let draft = pgn.split(separator: Pgn.multiGameRegex)

    var i = 0
    while i < draft.count {
      let tmp = "\(draft[i])\n\n\(draft[i + 1]))"
      pgns.append(tmp)
      i += 2
    }

    return pgns.map(Pgn.parse)
  }

  static func parse(_ pgn: String) -> Pgn {
    let splitPgn = pgn.split(separator: Pgn.multiGameRegex)

    if splitPgn.count < 1 {
      // TODO throw error?
      return Pgn(fen: "", input: pgn, moves: [], prelude: "", tags: [])
    }

    let tagLines = splitPgn[0].split(whereSeparator: \.isNewline)
    var tags: [Tag] = []
    var fenValue: String = ""

    for line in tagLines {
      let trimmed = String(line).trimmingCharacters(in: .whitespaces)

      let optionalMatch = try? Pgn.tagRegex.wholeMatch(in: trimmed)
      if optionalMatch == nil {
        continue
      }
      let (_, name, value) = optionalMatch!.output

      tags.append(
        Tag(
          name: String(name),
          value: String(value)
        ))

      if String(name).uppercased() == "FEN" {
        fenValue = String(value)
      }
    }

    var body = splitPgn.count > 1 ? String(splitPgn[1]) : ""
    if body == "" && tags.count == 0 {
      body = String(splitPgn[0])
    }

    var commentStack = 0
    var ravStack = 0
    var acc = ""
    var accComment = ""
    for char in body {
      if char == "{" {
        commentStack += 1
      } else if char == "}" {
        commentStack -= 1

        if commentStack == 0 && accComment != "" {
          let str = accComment.replacing(CharacterClass(.newlineSequence), with: "")
          if let data = String(str).data(using: .utf8) {
            acc += "{\(data.base64EncodedString())}"
          }
          accComment = ""
        }
      } else if commentStack > 0 {
        accComment += String(char)
        // TODO maybe we keep rav at some point by encoding it
      } else if char == "(" {
        ravStack += 1
      } else if char == ")" {
        ravStack -= 1
      } else if ravStack == 0 {
        acc += String(char)
      }
    }

    body = acc
    body = body.replacing(Pgn.movesRegex, with: "")
    body = body.replacing(Pgn.blackToMoveRegex, with: "")
    body = body.replacing(CharacterClass(.newlineSequence), with: " ")

    let items = body.split(separator: Pgn.whitespaceRegex)

    var prelude = ""
    var result = "*"
    var moves: [PgnMove] = []

    for substr in items {
      let item = String(substr)

      if item.first == "{" {
        var encoded = item
        encoded.remove(at: item.index(before: item.endIndex))
        encoded.remove(at: item.startIndex)
        if let data = Data(base64Encoded: encoded) {
          if let comment = String(data: data, encoding: .utf8) {
            if moves.count == 0 {
              prelude = comment
            } else {
              moves[moves.count - 1].comment = comment
            }
          }
        }
        continue
      }

      let optionalMatch = try? Pgn.nagRegex.wholeMatch(in: item)
      if moves.count > 0 && optionalMatch != nil {
        let (_, nagValue) = optionalMatch!.output
        moves[moves.count - 1].nag = nagValue!
        continue
      }

      if moves.count > 0 && Pgn.terminationMarkers.contains(item) {
        result = item
        moves[moves.count - 1].comment = result
        continue
      }

      let move = PgnMove(
        comment: "",
        nag: 0,
        rav: [],
        san: item
      )
      moves.append(move)
    }

    for (index, tag) in tags.enumerated() {
      if tag.name == "Result" {
        tags[index] = Tag(
          name: "Result",
          value: result
        )
      }
    }

    return Pgn(fen: fenValue, input: pgn, moves: moves, prelude: prelude, tags: tags)
  }

  private static let terminationMarkers: Set = ["1-0", "0-1", "1/2-1/2", "*"]

  private static let whitespaceRegex = Regex {
    OneOrMore(.whitespace)
  }

  private static let nagRegex = Regex {
    "$"
    Capture {
      OneOrMore(.digit)
    } transform: {
      Int($0)
    }
  }

  private static let blackToMoveRegex = Regex {
    ".../"
  }

  private static let movesRegex = Regex {
    OneOrMore(.digit)
    "."
    Optionally {
      Capture {
        ".."
      }
    }
  }

  private static let tagRegex = Regex {
    "["
    Capture {
      OneOrMore {
        CharacterClass(.anyNonNewline)
      }
    }
    " \""
    Capture {
      ZeroOrMore {
        CharacterClass(.anyNonNewline)
      }
    }
    "\"]"
  }
  .anchorsMatchLineEndings()

  private static let multiGameRegex = Regex {
    CharacterClass(.newlineSequence)
    CharacterClass(.newlineSequence)
  }
}
