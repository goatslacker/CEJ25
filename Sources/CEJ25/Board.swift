struct Board: BoardProtocol {
  var data: [Piece?] = Array(repeating: nil, count: 128)

  init(fen: String = "") {
    if fen == "" {
      return
    }

    let optionalFen = Fen.parse(fen: fen)
    if optionalFen == nil {
      return
    }
    let fen = optionalFen!
    self.setup(ranks: fen.ranks)
  }

  init(data: [Piece?]) {
    self.data = data
  }

  mutating func clear(sq: Square) {
    self.data[sq.rawValue] = nil
  }

  func getAllMoves(for color: PieceColor, castling: CastlingTuple, ep: Square?) -> [MoveDetails] {
    return getAllMoves(for: color, castling: castling, ep: ep, filterBy: nil)
  }

  func getAllMoves(
    for color: PieceColor, castling: CastlingTuple, ep: Square?, filterBy: PieceType?
  )
    -> [MoveDetails]
  {
    var moves: [MoveDetails] = []

    for square in Square.allCases {
      let item = self.data[square.rawValue]
      // Empty square
      if item == nil {
        continue
      }

      let piece = item!
      // Opposing color
      if piece.color != color {
        continue
      }

      if filterBy != nil && piece.type != filterBy! {
        continue
      }

      let candidates = self.getCandidateMoves(at: square, castling: castling, ep: ep)
      moves += candidates
    }

    return moves
  }

  func getCandidateMoves(at square: Square, castling: CastlingTuple, ep: Square?)
    -> [MoveDetails]
  {
    let item = self.data[square.rawValue]

    // Empty square
    if item == nil {
      return []
    }

    let piece = item!
    let opponentColor = self.opposingColor(piece.color)

    var result: [MoveDetails] = []

    // Pawn moves
    if piece.type == PieceType.pawn {
      let rank = square.rawValue >> 4
      let isStartingSquare =
        (rank == 1 && piece.color == PieceColor.black)
        || (rank == 6 && piece.color == PieceColor.white)

      // Double Step
      if isStartingSquare {
        let nextSquare = square.rawValue + piece.moves[1]
        let nextItem = self.data[nextSquare]

        let frontSquare = square.rawValue + piece.moves[0]
        let frontItem = self.data[frontSquare]

        if nextItem == nil && frontItem == nil {
          let to = Square(rawValue: nextSquare)!

          let moveDetails = MoveDetails(
            from: square,
            to: to,
            piece: piece
          )

          if Board.isMoveLegal(moveDetails, self.data) {
            result.append(moveDetails)
          }
        }
      }

      let offset = piece.moves[0]
      let nextSquare = square.rawValue + offset

      let nextItem = self.data[nextSquare]
      let to = Square(rawValue: nextSquare)!
      let toRank = nextSquare >> 4
      let isPromotionEligible =
        (toRank == 0 && piece.color == PieceColor.white)
        || (toRank == 7 && piece.color == PieceColor.black)

      if nextItem == nil {
        // Promotion
        if isPromotionEligible {
          let promotionPieces = self.getPromotionPieces(color: piece.color)

          for promotion in promotionPieces {
            let moveDetails = MoveDetails(
              from: square,
              to: to,
              piece: piece,
              promotion: promotion
            )

            if Board.isMoveLegal(moveDetails, self.data) {
              result.append(moveDetails)
            }
          }
        } else {
          // Regular pawn move
          let moveDetails = MoveDetails(
            from: square,
            to: to,
            piece: piece
          )

          if Board.isMoveLegal(moveDetails, self.data) {
            result.append(moveDetails)
          }
        }
      }

      let captures = piece.moves[2...3]

      // Potential captures
      for offset in captures {
        let nextSquare = square.rawValue + offset

        if nextSquare & 0x88 == 0 {
          let nextItem = self.data[nextSquare]
          let to = Square(rawValue: nextSquare)!
          let toRank = nextSquare >> 4
          let isPromotionEligible =
            (toRank == 0 && piece.color == PieceColor.white)
            || (toRank == 7 && piece.color == PieceColor.black)

          if nextItem != nil {
            let pieceAtSquare = nextItem!

            if isPromotionEligible {
              let promotionPieces = self.getPromotionPieces(color: piece.color)

              for promotion in promotionPieces {
                let moveDetails = MoveDetails(
                  from: square,
                  to: to,
                  piece: piece,
                  captured: pieceAtSquare,
                  promotion: promotion
                )

                if Board.isMoveLegal(moveDetails, self.data) {
                  result.append(moveDetails)
                }
              }
            } else {
              if pieceAtSquare.color == opponentColor {
                let moveDetails = MoveDetails(
                  from: square,
                  to: to,
                  piece: piece,
                  captured: pieceAtSquare
                )

                if Board.isMoveLegal(moveDetails, self.data) {
                  result.append(moveDetails)
                }
              }
            }
          }
        }
      }

      // holy hell
      if ep != nil {
        let (file, rank) = Board.getCoords(ep!)
        let pawnSquareValue = rank == "6" ? "\(file)5" : "\(file)4"

        if let pawnSquare = squares[pawnSquareValue] {
          if let captured = self.data[pawnSquare.rawValue] {

            let moveDetails = MoveDetails(
              from: square,
              to: ep!,
              piece: piece,
              captured: captured,
              ep: pawnSquare
            )

            if Board.isMoveLegal(moveDetails, self.data) {
              result.append(moveDetails)
            }
          }
        }
      }

      return result
    }

    // Other pieces
    for offset in piece.moves {
      var nextSquare = square.rawValue

      // while for sliding
      while true {
        nextSquare += offset
        // if we are off-board break out of the loop
        if nextSquare & 0x88 != 0 {
          break
        }

        let nextItem = self.data[nextSquare]
        let to = Square(rawValue: nextSquare)!

        // Empty square
        if nextItem == nil {
          let moveDetails = MoveDetails(
            from: square,
            to: to,
            piece: piece
          )

          if Board.isMoveLegal(moveDetails, self.data) {
            result.append(moveDetails)
          }
        } else {
          let pieceAtSquare = nextItem!

          // Captures
          if pieceAtSquare.color == opponentColor {
            let moveDetails = MoveDetails(
              from: square,
              to: to,
              piece: piece,
              captured: pieceAtSquare
            )

            if Board.isMoveLegal(moveDetails, self.data) {
              result.append(moveDetails)
            }
          }

          // encountered a blocking piece, break out of the loop
          break
        }

        // break for the non-sliding pieces
        if !piece.sliding {
          break
        }
      }
    }

    // Castling
    if piece.type == PieceType.king {
      if piece.color == PieceColor.white {
        if castling.0 == Castling.kingside && self.data[Square.f1.rawValue] == nil
          && self.data[Square.g1.rawValue] == nil
        {
          let moveDetails = MoveDetails(
            from: square,
            to: Square.g1,
            piece: piece,
            castling: Castling.kingside
          )

          if Board.isMoveLegal(moveDetails, self.data) {
            result.append(moveDetails)
          }
        }
        if castling.1 == Castling.queenside
          && self.data[Square.d1.rawValue] == nil && self.data[Square.c1.rawValue] == nil
          && self.data[Square.b1.rawValue] == nil
        {
          let moveDetails = MoveDetails(
            from: square,
            to: Square.c1,
            piece: piece,
            castling: Castling.queenside
          )

          if Board.isMoveLegal(moveDetails, self.data) {
            result.append(moveDetails)
          }
        }
      } else if piece.color == PieceColor.black {
        if castling.2 == Castling.kingside && self.data[Square.f8.rawValue] == nil
          && self.data[Square.g8.rawValue] == nil
        {
          let moveDetails = MoveDetails(
            from: square,
            to: Square.g8,
            piece: piece,
            castling: Castling.kingside
          )

          if Board.isMoveLegal(moveDetails, self.data) {
            result.append(moveDetails)
          }
        }
        if castling.3 == Castling.queenside
          && self.data[Square.d8.rawValue] == nil && self.data[Square.c8.rawValue] == nil
          && self.data[Square.b8.rawValue] == nil
        {
          let moveDetails = MoveDetails(
            from: square,
            to: Square.c8,
            piece: piece,
            castling: Castling.queenside
          )

          if Board.isMoveLegal(moveDetails, self.data) {
            result.append(moveDetails)
          }
        }
      }
    }

    return result
  }

  static func getCoords(_ square: Square) -> (String, String) {
    let value = square.rawValue
    let file = files[value & 0x7]
    let rank = ranks[value >> 4]
    return (file, rank)
  }

  static func getSquareColor(_ square: Square) -> PieceColor {
    let value = square.rawValue
    let file = value & 0xf
    let rank = value >> 4

    if (file + rank) % 2 == 0 {
      return PieceColor.white
    }

    return PieceColor.black
  }

  func getSquareContents(_ square: Square) -> Piece? {
    return self.data[square.rawValue]
  }

  func getKingSquare(color: PieceColor) -> Square {
    for (index, item) in self.data.enumerated() {
      if index & 0x88 != 0 {
        continue
      }
      if item != nil {
        let piece = item!
        if piece.color == color && piece.type == PieceType.king {
          return Square(rawValue: index)!
        }
      }
    }

    return color == PieceColor.white ? Square.e1 : Square.e8
  }

  private func getPiece(_ value: String) -> Piece? {
    switch value {
    case "p":
      return BlackPawn()
    case "r":
      return BlackRook()
    case "n":
      return BlackKnight()
    case "b":
      return BlackBishop()
    case "q":
      return BlackQueen()
    case "k":
      return BlackKing()
    case "P":
      return WhitePawn()
    case "R":
      return WhiteRook()
    case "N":
      return WhiteKnight()
    case "B":
      return WhiteBishop()
    case "Q":
      return WhiteQueen()
    case "K":
      return WhiteKing()
    default:
      return nil
    }
  }

  private func getPromotionPieces(color: PieceColor) -> [Piece] {
    if color == PieceColor.white {
      return [
        WhiteKnight(),
        WhiteBishop(),
        WhiteRook(),
        WhiteQueen(),
      ]
    }

    return [
      BlackKnight(),
      BlackBishop(),
      BlackRook(),
      BlackQueen(),
    ]
  }

  static func isMoveLegal(_ move: MoveDetails, _ data: [Piece?]) -> Bool {
    var board = Board(data: data)
    board.makeMove(move)

    let ourKingSquare = board.getKingSquare(color: move.piece.color)

    let isOurKingAttacked = board.isPieceAttacked(at: ourKingSquare)
    return !isOurKingAttacked
  }

  func isPieceAttacked(at attackedSquare: Square) -> Bool {
    let attacked = self.data[attackedSquare.rawValue]

    if attacked == nil {
      return false
    }

    let attackedPiece = attacked!

    for square in Square.allCases {
      let item = self.data[square.rawValue]
      // Empty square
      if item == nil {
        continue
      }

      let piece = item!
      // Same color
      if piece.color == attackedPiece.color {
        continue
      }

      let diff = square.rawValue - attackedSquare.rawValue

      if diff == 0 {
        continue
      }

      let index = diff + 119

      if attackMap[index] & piece.mask == 0 {
        continue
      }

      // pawn attack
      if piece.type == PieceType.pawn {
        if diff > 0 {
          if piece.color == PieceColor.white {
            return true
          }
        } else {
          if piece.color == PieceColor.black {
            return true
          }
        }
        continue
      }

      // knight or king
      if piece.type == PieceType.knight || piece.type == PieceType.king {
        return true
      }

      // sliding piece
      let offset = raysMap[index]
      var j = square.rawValue + offset
      var blocked = false

      while j != attackedSquare.rawValue {
        if self.data[j] != nil {
          blocked = true
          break
        }
        j += offset
      }

      if !blocked {
        return true
      }
    }

    return false
  }

  mutating func makeMove(_ move: MoveDetails) {
    let piece = move.promotion != nil ? move.promotion! : move.piece

    self.data[move.from.rawValue] = nil
    self.data[move.to.rawValue] = piece

    // en-passant capture
    if move.ep != nil {
      self.data[move.ep!.rawValue] = nil
    }

    if move.castling == Castling.kingside {
      if move.piece.color == PieceColor.white {
        self.data[Square.f1.rawValue] = self.data[Square.h1.rawValue]
        self.data[Square.h1.rawValue] = nil
      } else {
        self.data[Square.f8.rawValue] = self.data[Square.h8.rawValue]
        self.data[Square.h8.rawValue] = nil
      }
    } else if move.castling == Castling.queenside {
      if move.piece.color == PieceColor.white {
        self.data[Square.d1.rawValue] = self.data[Square.a1.rawValue]
        self.data[Square.a1.rawValue] = nil
      } else {
        self.data[Square.d8.rawValue] = self.data[Square.a8.rawValue]
        self.data[Square.a8.rawValue] = nil
      }
    }
  }

  private func opposingColor(_ color: PieceColor) -> PieceColor {
    return color == PieceColor.white ? PieceColor.black : PieceColor.white
  }

  mutating func put(sq: Square, piece: Piece) {
    self.data[sq.rawValue] = piece
  }

  mutating func reset() {
    self.data = Array(repeating: nil, count: 128)
  }

  mutating func setup(ranks: [String]) {
    self.reset()

    var squareValue = 0
    for rank in ranks {
      let contents = rank.split(separator: "")
      for pieceOrDigit in contents {
        let digit = Int(pieceOrDigit)
        if digit != nil {
          squareValue += digit!
        } else {
          let pieceValue = String(pieceOrDigit)
          let piece = self.getPiece(pieceValue)
          if piece != nil {
            self.data[squareValue] = piece
          }
          squareValue += 1
        }
      }
      squareValue += 8
    }
  }

  static func squareToString(_ square: Square?) -> String {
    if square == nil {
      return "-"
    }

    let (file, rank) = Board.getCoords(square!)
    return "\(file)\(rank)"
  }

  func toAscii() -> String {
    var result: [String] = []
    var line: [String] = []
    var file = 8
    for (index, item) in self.data.enumerated() {
      if index & 0x88 != 0 {
        if line.count > 0 {
          let rank = line.joined(separator: " ")
          result.append("\(file)  \(rank)")
          line = []
          file -= 1
        }
        continue
      }

      let value = item == nil ? "·" : item!.value
      line.append(value)
    }

    result.append("   a b c d e f g h")
    let ascii = result.joined(separator: "\n")
    return ascii
  }

  func toRanks() -> [String] {
    var ranks: [String] = []
    var file = ""
    var empty = 0

    for (index, item) in self.data.enumerated() {
      if index & 0x88 != 0 {
        if file != "" {
          var endDigit = ""
          if empty > 0 {
            endDigit = String(empty)
            empty = 0
          }

          ranks.append("\(file)\(endDigit)")
          file = ""
        } else if empty > 0 {
          ranks.append("8")
          empty = 0
        }
        continue
      }

      if item == nil {
        empty += 1
      } else {
        if empty > 0 {
          file += String(empty)
          empty = 0
        }
        file += item!.value
      }
    }

    return ranks
  }

  mutating func undoMove(_ move: MoveDetails) {
    let prevOccupant = move.captured != nil ? move.captured! : nil

    self.data[move.from.rawValue] = move.piece

    if move.ep != nil {
      self.data[move.ep!.rawValue] = prevOccupant
    } else {
      self.data[move.to.rawValue] = prevOccupant
    }

    if move.castling == Castling.kingside {
      if move.piece.color == PieceColor.white {
        self.data[Square.h1.rawValue] = self.data[Square.f1.rawValue]
        self.data[Square.f1.rawValue] = nil
      } else {
        self.data[Square.h8.rawValue] = self.data[Square.f8.rawValue]
        self.data[Square.f8.rawValue] = nil
      }
    } else if move.castling == Castling.queenside {
      if move.piece.color == PieceColor.white {
        self.data[Square.a1.rawValue] = self.data[Square.d1.rawValue]
        self.data[Square.d1.rawValue] = nil
      } else {
        self.data[Square.a8.rawValue] = self.data[Square.d8.rawValue]
        self.data[Square.d8.rawValue] = nil
      }
    }
  }
}
