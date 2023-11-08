import RegexBuilder

enum MoveError: Error, Equatable {
  case invalidMove(move: String)
  case moveNotFound(move: MoveRequest)
  case moveNotFound(san: String, fen: String)
  case notYourTurn

  static func == (lhs: MoveError, rhs: MoveError) -> Bool {
    switch (lhs, rhs) {
    case (.invalidMove(move: let a), .invalidMove(move: let b)):
      return a == b
    case (.notYourTurn, .notYourTurn):
      return true
    // TODO add other cases?
    default:
      return false
    }
  }
}

enum LoadError: Error {
  case invalidFen
  case invalidPgn
}

class Chess: ChessProtocol {
  private var board: Board = Board()
  private var castling: CastlingTuple = (
    Castling.kingside, Castling.queenside, Castling.kingside, Castling.queenside
  )
  private var comments: [Comment] = []
  private var epSquare: Square? = nil
  private var fullMoveCounter = 1
  private var halfMoveClock = 0
  private var history: [MoveHistory] = []
  private var positions: [String: Int] = [:]
  private var tags: [Tag] = []
  private var turn = PieceColor.white

  init() {
    let startPos = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    self.load(fen: startPos)
  }

  init(fen: String) {
    self.load(fen: fen)
  }

  init(pgn: String) throws {
    try self.load(pgn: pgn)
  }

  func export(ascii: Bool) -> String {
    return self.board.toAscii()
  }

  func export(fen: Bool) -> String {
    let ranks = self.board.toRanks()

    return Fen(
      ranks: ranks, turn: self.turn, castling: self.castling,
      epSquare: self.epSquare, halfMoveClock: self.halfMoveClock,
      fullMoveCounter: self.fullMoveCounter
    ).toString()
  }

  func export(pgn: Bool) throws -> String {
    let chess = Chess()
    chess.reset(chess: self)

    var comments = chess.comments

    var text: [String] = []
    var result = ""

    for tag in tags {
      text.append("[\(tag.name) \"\(tag.value)\"]")
      if tag.name == "Result" {
        result = tag.value
      }
    }

    // separate moves from tags
    text.append("")

    // make the moves
    var reversedHistory: [MoveHistory] = []

    for _ in chess.history {
      let undoneMove = try chess.undoMove()
      reversedHistory.insert(undoneMove, at: 0)
    }

    var addBlackToMove = false
    var moves: [String] = []

    for move in reversedHistory {
      let color = chess.getTurn()

      if color == PieceColor.white {
        moves.append("\(chess.fullMoveCounter).")
      } else if addBlackToMove {
        moves.append("\(chess.fullMoveCounter)...")
        addBlackToMove = false
      }

      // Make the move
      let item = try chess.move(pcn: move.pcn)
      moves.append(item.san)

      // Add in any comments
      if let comment = comments.first {
        if comment.moveCount == chess.fullMoveCounter && comment.turn == chess.turn {
          comments.removeFirst()
          if comments.count > 0 {
            if comment.nag > 0 {
              moves.append("$\(comment.nag)")
            }
            if comment.text != "" {
              moves.append("{\(comment.text)}")
            }
            addBlackToMove = chess.turn == PieceColor.black
          }
        }
      }
    }

    if result != "" {
      moves.append(result)
    }

    text.append(moves.joined(separator: " "))

    return text.joined(separator: "\n")
  }

  func getBoard() -> [Piece?] {
    var result: [Piece?] = []
    for (index, item) in self.board.data.enumerated() {
      if index & 0x88 != 0 {
        continue
      }

      result.append(item)
    }

    return result
  }

  func getCastling() -> CastlingTuple {
    return self.castling
  }

  func getComment() -> Comment? {
    return self.comments.first {
      $0.moveCount == fullMoveCounter && $0.turn == turn
    }
  }

  func getComments() -> [Comment] {
    return self.comments
  }

  func getEnPassantSquare() -> Square? {
    return self.epSquare
  }

  func getGameState() -> GameState {
    let (checkWhite, checkBlack) = isCheckByColor()
    let (checkmateWhite, checkmateBlack) = isCheckmateByColor()
    let (fiftyMoveRule, stalemate, repetition, material) = isDrawByState()

    var settlement: SettlementState? = nil
    if checkmateWhite || checkmateBlack || fiftyMoveRule || stalemate || repetition || material {
      var result = GameResult.unknown
      var termination = Termination.unknown

      if checkmateWhite {
        result = GameResult.white
        termination = Termination.checkmate
      } else if checkmateBlack {
        result = GameResult.black
        termination = Termination.checkmate
      } else {
        result = GameResult.draw

        if fiftyMoveRule {
          termination = Termination.fiftyMoveRule
        } else if stalemate {
          termination = Termination.stalemate
        } else if repetition {
          termination = Termination.threefoldRepetition
        } else if material {
          termination = Termination.insufficientMaterial
        }
      }

      settlement = SettlementState(
        result: result,
        termination: termination
      )
    }

    return GameState(
      check: CheckState(white: checkWhite, black: checkBlack),
      settlement: settlement
    )
  }

  func getMoveCount() -> Int {
    return self.fullMoveCounter
  }

  func getMoveHistory() -> [MoveHistory] {
    return self.history
  }

  func getPieces() -> [(Piece, Square)] {
    var pieces: [(Piece, Square)] = []

    for (index, item) in self.board.data.enumerated() {
      if index & 0x88 != 0 {
        continue
      }

      guard let piece = item else {
        continue
      }

      pieces.append((piece, Square(rawValue: index)!))
    }

    return pieces
  }

  func getTag(_ name: String) -> Tag? {
    return self.tags.first(where: { $0.name == name })
  }

  func getTags() -> [Tag] {
    return self.tags
  }

  func getTurn() -> PieceColor {
    return self.turn
  }

  func isCheck() -> Bool {
    let (white, black) = isCheckByColor()
    return white || black
  }

  private func isCheckByColor() -> (Bool, Bool) {
    let whiteKingSquare = self.board.getKingSquare(color: PieceColor.white)
    let blackKingSquare = self.board.getKingSquare(color: PieceColor.black)
    return (
      self.board.isPieceAttacked(at: whiteKingSquare),
      self.board.isPieceAttacked(at: blackKingSquare)
    )
  }

  func isCheckmate() -> Bool {
    let (white, black) = isCheckmateByColor()
    return white || black
  }

  private func isCheckmateByColor() -> (Bool, Bool) {
    let whiteKingSquare = self.board.getKingSquare(color: PieceColor.white)
    let blackKingSquare = self.board.getKingSquare(color: PieceColor.black)
    let isWhiteKingAttacked = self.board.isPieceAttacked(at: whiteKingSquare)
    let isBlackKingAttacked = self.board.isPieceAttacked(at: blackKingSquare)

    if isWhiteKingAttacked {
      let moves = self.board.getAllMoves(
        for: PieceColor.white, castling: self.castling, ep: self.getEnPassantSquare())
      return (false, moves.count == 0)
    }

    if isBlackKingAttacked {
      let moves = self.board.getAllMoves(
        for: PieceColor.black, castling: self.castling, ep: self.getEnPassantSquare())
      return (moves.count == 0, false)
    }

    return (false, false)
  }

  func isDraw() -> Bool {
    let (fiftyMoveRule, stalemate, repetition, material) = isDrawByState()
    return fiftyMoveRule || stalemate || repetition || material
  }

  private func isDrawByState() -> (Bool, Bool, Bool, Bool) {
    return (
      self.halfMoveClock >= 100,
      self.isStalemate(),
      self.isThreefoldRepetition(),
      self.isInsufficientMaterial()
    )
  }

  func isInsufficientMaterial() -> Bool {
    var pieceCount = 0
    var bishopSquareColor: [PieceColor] = []

    for (index, item) in self.board.data.enumerated() {
      if index & 0x88 != 0 {
        continue
      }

      if item != nil {
        let piece = item!
        if piece.type == PieceType.queen || piece.type == PieceType.rook
          || piece.type == PieceType.pawn
        {
          return false
        }

        pieceCount += 1

        if piece.type == PieceType.bishop {
          let square = Square(rawValue: index)!
          bishopSquareColor.append(Board.getSquareColor(square))
        }
      }
    }

    // K vs k
    // KB vs k || KN vs k ||  K vs kb || K vs kn
    if pieceCount < 4 {
      return true
    }

    // KB vs kb +
    if pieceCount == bishopSquareColor.count + 2 {
      let bishopColor = bishopSquareColor[0]
      return bishopSquareColor.allSatisfy { $0 == bishopColor }
    }

    return false
  }

  func isLegalMove(move: MoveHistory) -> Bool {
    return Board.isMoveLegal(move.details, self.board.data)
  }

  func isStalemate() -> Bool {
    let moves = self.board.getAllMoves(
      for: self.turn, castling: self.castling, ep: self.getEnPassantSquare())
    return !isCheck() && moves.count == 0
  }

  func isThreefoldRepetition() -> Bool {
    for (_, times) in positions {
      if times >= 3 {
        return true
      }
    }

    return false
  }

  func load(fen fenStr: String) {
    self.reset()

    let optionalFen = Fen.parse(fen: fenStr)
    if optionalFen == nil {
      // TODO throw instead
      return
    }

    let fen = optionalFen!

    self.castling = fen.castling
    self.epSquare = fen.epSquare
    self.fullMoveCounter = fen.fullMoveCounter
    self.halfMoveClock = fen.halfMoveClock
    self.turn = fen.turn
    self.board.setup(ranks: fen.ranks)

    self.encodePosition()
  }

  func load(pgn str: String) throws {
    let pgn = Pgn.parse(str)
    let chess = try pgn.validate()
    reset(chess: chess)
  }

  private func move(with move: MoveDetails) throws -> MoveHistory {
    guard self.board.getSquareContents(move.from)?.color == self.turn else {
      throw MoveError.notYourTurn
    }

    let allMoves = board.getAllMoves(
      for: move.piece.color,
      castling: castling,
      ep: getEnPassantSquare(),
      filterBy: move.piece.type
    )
    let prevCastling = self.castling
    let prevEpSquare = self.epSquare
    let prevHalfMoveClock = self.halfMoveClock

    let opponent = Chess.opposingColor(self.turn)

    self.board.makeMove(move)

    if move.piece.type == PieceType.king {
      if self.turn == PieceColor.white {
        self.castling.0 = Castling.none
        self.castling.1 = Castling.none
      } else {
        self.castling.2 = Castling.none
        self.castling.3 = Castling.none
      }
    }

    if move.piece.type == PieceType.rook {
      if self.turn == PieceColor.white {
        if move.from == Square.h1 {
          self.castling.0 = Castling.none
        } else if move.from == Square.a1 {
          self.castling.1 = Castling.none
        }
      } else {
        if move.from == Square.h8 {
          self.castling.2 = Castling.none
        } else if move.from == Square.a8 {
          self.castling.3 = Castling.none
        }
      }
    }

    if move.captured != nil {
      let captured = move.captured!
      if captured.type == PieceType.rook {
        if self.turn == PieceColor.black {
          if move.to == Square.h1 {
            self.castling.0 = Castling.none
          } else if move.to == Square.a1 {
            self.castling.1 = Castling.none
          }
        } else {
          if move.to == Square.h8 {
            self.castling.2 = Castling.none
          } else if move.to == Square.a8 {
            self.castling.3 = Castling.none
          }
        }
      }
    }

    // reset the square first
    self.epSquare = nil

    // that french thing
    if move.piece.type == PieceType.pawn {
      let (_, fromRank) = Board.getCoords(move.from)
      let (_, toRank) = Board.getCoords(move.to)

      if (move.piece.color == PieceColor.white && fromRank == "2" && toRank == "4")
        || (fromRank == "7" && toRank == "5" && move.piece.color == PieceColor.black)
      {

        let epTarget =
          move.piece.color == PieceColor.white ? move.to.rawValue + 16 : move.to.rawValue - 16
        if epTarget & 0x88 == 0 {
          var canPassant = false

          if let leftSquare = Square(rawValue: move.to.rawValue - 1) {
            if let piece = self.board.getSquareContents(leftSquare) {
              canPassant = piece.type == PieceType.pawn && piece.color == opponent
            }
          }

          if !canPassant {
            if let rightSquare = Square(rawValue: move.to.rawValue + 1) {
              if let piece = self.board.getSquareContents(rightSquare) {
                canPassant = piece.type == PieceType.pawn && piece.color == opponent
              }
            }
          }

          if canPassant {
            self.epSquare = Square(rawValue: epTarget)!
          }
        }
      }
    }

    // reset the 50 move counter if a pawn is moved or piece is captured
    if move.piece.type == PieceType.pawn || move.captured != nil {
      self.halfMoveClock = 0
    } else {
      self.halfMoveClock += 1
    }

    // increment fullMoveCounter
    if move.piece.color == PieceColor.black {
      self.fullMoveCounter += 1
    }

    self.turn = opponent

    self.encodePosition()

    let historyItem = MoveHistory(
      castling: prevCastling,
      details: move,
      epSquare: prevEpSquare,
      fen: self.export(fen: true),
      halfMoveClock: prevHalfMoveClock,
      pcn: Chess.pcn(move),
      san: san(move, allMoves),
      turn: self.turn
    )

    self.history.append(historyItem)

    return historyItem
  }

  func move(move moveReq: MoveRequest) throws -> MoveHistory {
    let moves = self.board.getCandidateMoves(
      at: moveReq.from, castling: self.castling, ep: self.getEnPassantSquare())
    let foundMove = moves.first(where: {
      $0.to == moveReq.to
        && (moveReq.promotion == nil
          || ($0.promotion != nil && moveReq.promotion! == $0.promotion!.type))
    })

    if foundMove == nil {
      throw MoveError.moveNotFound(move: moveReq)
    }

    return try self.move(with: foundMove!)
  }

  func move(pcn: String) throws -> MoveHistory {
    let optionalMatch = try? Chess.pcnRegex.wholeMatch(in: pcn)
    if optionalMatch == nil {
      throw MoveError.invalidMove(move: pcn)
    }

    let (_, from, to, promotion) =
      optionalMatch!.output

    let promotionPieceType =
      promotion != nil ? PieceType(rawValue: promotion!)! : nil

    let moveRequest = MoveRequest(
      from: squares[String(from)]!,
      to: squares[String(to)]!,
      promotion: promotionPieceType
    )

    return try move(move: moveRequest)
  }

  func move(san str: String) throws -> MoveHistory {
    let optionalSan = parseSan(str)

    if optionalSan == nil {
      throw MoveError.invalidMove(move: str)
    }

    let san = optionalSan!

    let moves = self.board.getAllMoves(
      for: self.turn, castling: self.castling, ep: self.getEnPassantSquare(),
      filterBy: san.piece
    )

    let foundMove = moves.first(where: {
      let destinationMatch = $0.to == san.dest
      let promotionMatch =
        ((san.promotion == nil && $0.promotion == nil)
          || (san.promotion != nil && $0.promotion != nil && san.promotion! == $0.promotion!.type))
      var disambiguation = true

      if san.disambiguator != "" {
        let (file, rank) = Board.getCoords($0.from)
        disambiguation =
          san.disambiguator == file || san.disambiguator == rank
          || san.disambiguator == "\(file)\(rank)"
      }

      return destinationMatch && promotionMatch && disambiguation
    })

    if foundMove == nil {
      throw MoveError.moveNotFound(san: str, fen: export(fen: true))
    }

    return try self.move(with: foundMove!)
  }

  func removeComment() {
    self.comments = self.comments.filter {
      $0.turn != self.turn && $0.moveCount != self.fullMoveCounter
    }
  }

  func removeTag(name: String) {
    self.tags = self.tags.filter { $0.name != name }
  }

  func reset() {
    self.board = Board()
    self.castling = (
      Castling.kingside, Castling.queenside, Castling.kingside, Castling.queenside
    )
    self.comments = []
    self.epSquare = nil
    self.fullMoveCounter = 1
    self.halfMoveClock = 0
    self.history = []
    self.positions = [:]
    self.tags = []
    self.turn = PieceColor.white
  }

  func reset(chess: Chess) {
    self.board = chess.board
    self.castling = chess.castling
    self.comments = chess.comments
    self.epSquare = chess.epSquare
    self.fullMoveCounter = chess.fullMoveCounter
    self.halfMoveClock = chess.halfMoveClock
    self.history = chess.history
    self.positions = chess.positions
    self.tags = chess.tags
    self.turn = chess.turn
  }

  func san(_ move: MoveDetails, _ moves: [MoveDetails]) -> String {
    var result = ""

    if move.castling == Castling.kingside {
      result += "O-O"
    } else if move.castling == Castling.queenside {
      result += "O-O-O"
    } else {
      if move.piece.type != PieceType.pawn {

        var ambiguous: [(String, String)] = []

        for potentialMove in moves {
          if move.from != potentialMove.from && move.to == potentialMove.to
            && move.piece.type == potentialMove.piece.type
            && move.piece.color == potentialMove.piece.color
          {
            let (file, rank) = Board.getCoords(potentialMove.from)
            ambiguous.append((file, rank))
          }
        }

        var departure = ""

        if ambiguous.count > 0 {
          let (file, rank) = Board.getCoords(move.from)

          if ambiguous.allSatisfy({ $0.0 != file }) {
            departure = file
          } else if ambiguous.allSatisfy({ $0.1 != rank }) {
            departure = rank
          } else {
            departure = "\(file)\(rank)"
          }
        }

        result = move.piece.value.uppercased() + departure
      }

      if move.captured != nil {
        if move.piece.type == PieceType.pawn {
          result += Chess.algebraic(move.from).prefix(1)
        }
        result += "x"
      }

      result += Chess.algebraic(move.to)

      if move.promotion != nil {
        result += "=" + move.promotion!.value
      }
    }

    if isCheckmate() {
      result += "#"
    } else if isCheck() {
      result += "+"
    }

    return result
  }

  func setComment(comment: String, nag: Int) {
    comments.append(
      Comment(
        moveCount: self.fullMoveCounter,
        nag: nag,
        text: comment,
        turn: self.turn
      ))
  }

  func setTag(tag name: String, value: String) {
    let newTag = Tag(
      name: name,
      value: value
    )

    for (index, tag) in self.tags.enumerated() {
      if tag.name == name {
        self.tags[index] = newTag
        return
      }
    }

    self.tags.append(newTag)
  }

  func undoMove() throws -> MoveHistory {
    let opponent = Chess.opposingColor(self.turn)

    guard history.count > 0 else {
      throw MoveError.invalidMove(move: "")
    }

    let item = self.history.removeLast()

    let move = item.details

    self.board.undoMove(move)

    self.castling = item.castling
    self.epSquare = item.epSquare
    self.halfMoveClock = item.halfMoveClock

    if move.piece.color == PieceColor.black {
      self.fullMoveCounter -= 1
    }

    self.turn = opponent

    return item
  }

  private func encodePosition() {
    let hash = Fen(
      ranks: self.board.toRanks(), turn: self.turn, castling: self.castling,
      epSquare: self.epSquare, halfMoveClock: self.halfMoveClock,
      fullMoveCounter: self.fullMoveCounter
    ).toHash()
    let timesSeen = (positions[hash] ?? 0) + 1
    positions[hash] = timesSeen
  }

  private func parseSan(_ san: String) -> San? {
    let optionalCastle = try? Chess.sanCastleRegex.wholeMatch(in: san)
    if optionalCastle != nil {
      let (_, castle) = optionalCastle!.output
      let castling = castle == "O-O" || castle == "0-0" ? Castling.kingside : Castling.queenside

      var dest: Square
      if self.turn == PieceColor.white {
        dest = castling == Castling.kingside ? Square.g1 : Square.c1
      } else {
        dest = castling == Castling.kingside ? Square.g8 : Square.c8
      }

      return San(
        castle: castling,
        disambiguator: "",
        dest: dest,
        piece: PieceType.king,
        promotion: nil
      )
    }

    let optionalMove = try? Chess.sanRegex.wholeMatch(in: san)
    if optionalMove != nil {
      let (_, pieceType, optionalDisambiguator, dest, promotion) = optionalMove!.output

      var disambiguator = optionalDisambiguator!

      var piece: PieceType = PieceType.pawn
      if pieceType != nil {
        let optionalPiece = PieceType(rawValue: pieceType!)
        if optionalPiece != nil {
          piece = optionalPiece!
        } else {
          disambiguator = pieceType!
        }
      }

      return San(
        castle: nil,
        disambiguator: disambiguator,
        dest: squares[dest]!,
        piece: piece,
        promotion: promotion != nil ? PieceType(rawValue: promotion!)! : nil
      )
    }

    return nil
  }

  static func algebraic(_ square: Square) -> String {
    let (file, rank) = Board.getCoords(square)
    return "\(file)\(rank)"
  }

  static func opposingColor(_ color: PieceColor) -> PieceColor {
    return color == PieceColor.white ? PieceColor.black : PieceColor.white
  }

  static func pcn(_ move: MoveDetails) -> String {
    let from = Chess.algebraic(move.from)
    let to = Chess.algebraic(move.to)
    let promotion = move.promotion != nil ? move.promotion!.value.lowercased() : ""
    return "\(from)\(to)\(promotion)"
  }

  private static let squareRegex = Regex {
    ("a"..."h")
    ("1"..."8")
  }

  private static let pcnRegex = Regex {
    Capture {
      squareRegex
    }
    Capture {
      squareRegex
    }
    Optionally {
      Capture {
        One(.anyOf("bnrqBNRQ"))
      } transform: {
        String($0).uppercased()
      }
    }
  }
  .anchorsMatchLineEndings()

  private static let sanCastleRegex = Regex {
    Capture {
      ChoiceOf {
        Regex {
          "O-O"
          Optionally {
            "-O"
          }
        }
        Regex {
          "0-0"
          Optionally {
            "-0"
          }
        }
      }
    }
    ZeroOrMore {
      "."
    }
  }
  .anchorsMatchLineEndings()

  // ([bnrqkBNRQK]|[a-h])?x?([a-h]?[1-8]?)?([a-h][1-8])(=[bnrqBNRQ])?
  private static let sanRegex = Regex {
    Optionally {
      Capture {
        ChoiceOf {
          One(.anyOf("bnrqkBNRQK"))
          ("a"..."h")
        }
      } transform: {
        String($0)
      }
    }
    Optionally {
      Capture {
        Regex {
          Optionally(("a"..."h"))
          Optionally(("1"..."8"))
        }
      } transform: {
        String($0)
      }
    }
    Optionally {
      "x"
    }
    Capture {
      Regex {
        ("a"..."h")
        ("1"..."8")
      }
    } transform: {
      String($0)
    }
    Optionally {
      Regex {
        "="
        Capture {
          One(.anyOf("bnrqBNRQ"))
        } transform: {
          String($0)
        }
      }
    }
    ZeroOrMore {
      CharacterClass(.anyNonNewline)
    }
  }
  .anchorsMatchLineEndings()
}
