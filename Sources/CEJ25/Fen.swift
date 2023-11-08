import RegexBuilder

enum FenValidationError: Error {
  case badRank
  case cannotParse
  case wrongKings
}

struct Fen {
  var ranks: [String]
  var turn: PieceColor
  var castling: CastlingTuple
  var epSquare: Square?
  var halfMoveClock: Int
  var fullMoveCounter: Int

  public func toHash() -> String {
    let ranks = self.ranks.joined(separator: "/")
    let turn = self.turn == PieceColor.white ? "w" : "b"
    let castleKingsideWhite = self.castling.0 == Castling.kingside ? "K" : ""
    let castleQueensideWhite = self.castling.1 == Castling.queenside ? "Q" : ""
    let castleKingsideBlack = self.castling.2 == Castling.kingside ? "k" : ""
    let castleQueensideBlack = self.castling.3 == Castling.queenside ? "q" : ""
    let optionalCastling =
      "\(castleKingsideWhite)\(castleQueensideWhite)\(castleKingsideBlack)\(castleQueensideBlack)"
    let castling = optionalCastling == "" ? "-" : optionalCastling
    let enPassantTarget = Board.squareToString(self.epSquare)

    return
      "\(ranks) \(turn) \(castling) \(enPassantTarget)"
  }

  public func toString() -> String {
    return
      "\(self.toHash()) \(self.halfMoveClock) \(self.fullMoveCounter)"
  }

  // TODO have one that throws and one that doesn't
  public static func parse(fen: String) -> Fen? {
    let optionalFen = try? Fen.validate(fen: fen)
    if optionalFen == nil {
      return nil
    }

    return optionalFen!
  }

  public static func validate(fen: String) throws -> Fen {
    // Regex takes care of validating that
    // * there are 8 ranks
    // * turn is either w|b
    // * half move clock is a digit
    // * full move counter is a digit
    // * no pawns are on 1st and 8th rank
    // * en-passant square is legal
    let optionalMatch = try Fen.rxSearch.wholeMatch(in: fen)
    if optionalMatch == nil {
      throw FenValidationError.cannotParse
    }
    let (_, ranks, turn, castling, enPassantTarget, halfMoveClock, fullMoveCounter) =
      optionalMatch!.output

    // Validate all the ranks follow FEN piece placement
    for rank in ranks {
      try Fen.validateRank(rank: rank)
    }

    // Make sure there is exactly one white and one black king
    let kings = ranks.joined(separator: "/").matches(of: Fen.rxKing)
    if kings.count != 2 {
      throw FenValidationError.wrongKings
    }
    if kings[0].output == kings[1].output {
      throw FenValidationError.wrongKings
    }

    let ranksAsString = ranks.map { String($0) }
    let epSquare = enPassantTarget != nil ? squares[enPassantTarget!] : nil

    return Fen(
      ranks: ranksAsString, turn: turn, castling: castling,
      epSquare: epSquare, halfMoveClock: halfMoveClock,
      fullMoveCounter: fullMoveCounter)
  }

  private static func validateRank(rank: Substring) throws {
    // Regex ensures there are no consecutive numbers
    let optionalMatch = try Fen.rxRankValidator.wholeMatch(in: rank)
    if optionalMatch == nil {
      throw FenValidationError.badRank
    }

    let ranki = rank.split(separator: "")

    if ranki.count > 8 {
      throw FenValidationError.badRank
    }

    var pieceCount = 0
    for item in ranki {
      let num = Int(item)
      let add = num == nil ? 1 : num!
      pieceCount += add
    }
    if pieceCount != 8 {
      throw FenValidationError.badRank
    }
  }

  private static let rxRankValidator = Regex {
    ChoiceOf {
      Regex {
        Repeat(1...8) {
          Regex {
            Optionally(("1"..."7"))
            One(.anyOf("pbnrqkPBNRQK"))
          }
        }
        Optionally(("1"..."7"))
      }
      "8"
    }
  }
  .anchorsMatchLineEndings()

  private static let rxKing = Regex {
    "K"
  }.anchorsMatchLineEndings().ignoresCase()

  private static let rxBackrank = ChoiceOf {
    OneOrMore {
      CharacterClass(
        .anyOf("bnrqkBNRQK"),
        ("1"..."7")
      )
    }
    "8"
  }

  private static let rxRank = Regex {
    ChoiceOf {
      OneOrMore {
        CharacterClass(
          .anyOf("pbnrqkPBNRQK"),
          ("1"..."7")
        )
      }
      "8"
    }
    "/"
  }

  // OG: ^((?:[pbnrqkPBNRQK1-8]{1,8}/){7}[pbnrqkPBNRQK1-8]{1,8}) ([wb]) (K?Q?k?q?|-) ([a-h][36]|-) ([0-9]+) ([0-9]+)$
  // Best ^([bnrqkBNRQK1-7]+|8/(?:[pbnrqkPBNRQK1-7]+|8/){6}[bnrqkBNRQK1-7]+|8) ([wb]) (K?Q?k?q?|-) ([a-h][36]|-) ([0-9]+) ([0-9]+)$
  private static let rxSearch = Regex {
    Capture {
      Fen.rxBackrank
      "/"
      Repeat(count: 6) {
        Fen.rxRank
      }
      Fen.rxBackrank
    } transform: {
      $0.split(separator: "/")
    }
    " "
    Capture {
      One(.anyOf("wb"))
    } transform: {
      $0 == "w" ? PieceColor.white : PieceColor.black
    }
    " "
    Capture {
      ChoiceOf {
        Regex {
          Optionally {
            "K"
          }
          Optionally {
            "Q"
          }
          Optionally {
            "k"
          }
          Optionally {
            "q"
          }
        }
        "-"
      }
    } transform: { str -> CastlingTuple in
      if str == "-" {
        return (Castling.none, Castling.none, Castling.none, Castling.none)
      }

      var whiteKingside = false
      var whiteQueenside = false
      var blackKingside = false
      var blackQueenside = false

      str.split(separator: "").forEach {
        if $0 == "K" {
          whiteKingside = true
        } else if $0 == "Q" {
          whiteQueenside = true
        } else if $0 == "k" {
          blackKingside = true
        } else if $0 == "q" {
          blackQueenside = true
        }
      }

      return (
        whiteKingside ? Castling.kingside : Castling.none,
        whiteQueenside ? Castling.queenside : Castling.none,
        blackKingside ? Castling.kingside : Castling.none,
        blackQueenside ? Castling.queenside : Castling.none
      )
    }
    " "
    Capture {
      ChoiceOf {
        Regex {
          ("a"..."h")
          One(.anyOf("36"))
        }
        "-"
      }
    } transform: { str -> String? in
      if str == "-" {
        return nil
      }
      return String(str)
    }
    " "
    Capture {
      OneOrMore(("0"..."9"))
    } transform: {
      Int($0) ?? 0
    }
    " "
    Capture {
      OneOrMore(("0"..."9"))
    } transform: {
      Int($0) ?? 1
    }
  }
  .anchorsMatchLineEndings()
}
