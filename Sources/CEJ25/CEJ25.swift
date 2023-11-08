enum PieceColor {
  case white
  case black
}

enum Castling {
  case none
  case kingside
  case queenside
}

let attackMap: [Int] = [
  20, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 20, 0,
  0, 20, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 20, 0, 0,
  0, 0, 20, 0, 0, 0, 0, 24, 0, 0, 0, 0, 20, 0, 0, 0,
  0, 0, 0, 20, 0, 0, 0, 24, 0, 0, 0, 20, 0, 0, 0, 0,
  0, 0, 0, 0, 20, 0, 0, 24, 0, 0, 20, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 20, 2, 24, 2, 20, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 2, 53, 56, 53, 2, 0, 0, 0, 0, 0, 0,
  24, 24, 24, 24, 24, 24, 56, 0, 56, 24, 24, 24, 24, 24, 24, 0,
  0, 0, 0, 0, 0, 2, 53, 56, 53, 2, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 20, 2, 24, 2, 20, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 20, 0, 0, 24, 0, 0, 20, 0, 0, 0, 0, 0,
  0, 0, 0, 20, 0, 0, 0, 24, 0, 0, 0, 20, 0, 0, 0, 0,
  0, 0, 20, 0, 0, 0, 0, 24, 0, 0, 0, 0, 20, 0, 0, 0,
  0, 20, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 20, 0, 0,
  20, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 20,
]

let raysMap: [Int] = [
  17, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 15, 0,
  0, 17, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 15, 0, 0,
  0, 0, 17, 0, 0, 0, 0, 16, 0, 0, 0, 0, 15, 0, 0, 0,
  0, 0, 0, 17, 0, 0, 0, 16, 0, 0, 0, 15, 0, 0, 0, 0,
  0, 0, 0, 0, 17, 0, 0, 16, 0, 0, 15, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 17, 0, 16, 0, 15, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 17, 16, 15, 0, 0, 0, 0, 0, 0, 0,
  1, 1, 1, 1, 1, 1, 1, 0, -1, -1, -1, -1, -1, -1, -1, 0,
  0, 0, 0, 0, 0, 0, -15, -16, -17, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, -15, 0, -16, 0, -17, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, -15, 0, 0, -16, 0, 0, -17, 0, 0, 0, 0, 0,
  0, 0, 0, -15, 0, 0, 0, -16, 0, 0, 0, -17, 0, 0, 0, 0,
  0, 0, -15, 0, 0, 0, 0, -16, 0, 0, 0, 0, -17, 0, 0, 0,
  0, -15, 0, 0, 0, 0, 0, -16, 0, 0, 0, 0, 0, -17, 0, 0,
  -15, 0, 0, 0, 0, 0, 0, -16, 0, 0, 0, 0, 0, 0, -17,
]

let files: [String] = ["a", "b", "c", "d", "e", "f", "g", "h"]
let ranks: [String] = ["8", "7", "6", "5", "4", "3", "2", "1"]

enum Square: Int, CaseIterable {
  case a8 = 0
  case b8 = 1
  case c8 = 2
  case d8 = 3
  case e8 = 4
  case f8 = 5
  case g8 = 6
  case h8 = 7
  case a7 = 16
  case b7 = 17
  case c7 = 18
  case d7 = 19
  case e7 = 20
  case f7 = 21
  case g7 = 22
  case h7 = 23
  case a6 = 32
  case b6 = 33
  case c6 = 34
  case d6 = 35
  case e6 = 36
  case f6 = 37
  case g6 = 38
  case h6 = 39
  case a5 = 48
  case b5 = 49
  case c5 = 50
  case d5 = 51
  case e5 = 52
  case f5 = 53
  case g5 = 54
  case h5 = 55
  case a4 = 64
  case b4 = 65
  case c4 = 66
  case d4 = 67
  case e4 = 68
  case f4 = 69
  case g4 = 70
  case h4 = 71
  case a3 = 80
  case b3 = 81
  case c3 = 82
  case d3 = 83
  case e3 = 84
  case f3 = 85
  case g3 = 86
  case h3 = 87
  case a2 = 96
  case b2 = 97
  case c2 = 98
  case d2 = 99
  case e2 = 100
  case f2 = 101
  case g2 = 102
  case h2 = 103
  case a1 = 112
  case b1 = 113
  case c1 = 114
  case d1 = 115
  case e1 = 116
  case f1 = 117
  case g1 = 118
  case h1 = 119
}

enum PieceType: String {
  case king = "K"
  case queen = "Q"
  case bishop = "B"
  case knight = "N"
  case rook = "R"
  case pawn = "P"
}

protocol Piece {
  var color: PieceColor { get }
  var mask: Int { get }
  var moves: [Int] { get }
  var sliding: Bool { get }
  var type: PieceType { get }
  var value: String { get }
  var symbol: String { get }
}

// TODO if too slow move to class
struct WhitePawn: Piece {
  let color = PieceColor.white
  let mask = 1
  let moves = [-16, -32, -17, -15]
  let sliding = false
  let symbol = "\u{2659}\u{fe0e}"
  let type = PieceType.pawn
  let value = "P"
}

struct WhiteRook: Piece {
  let color = PieceColor.white
  let mask = 8
  let moves = [-16, -1, 1, 16]
  let sliding = true
  let symbol = "\u{2656}\u{fe0e}"
  let type = PieceType.rook
  let value = "R"
}

struct WhiteKnight: Piece {
  let color = PieceColor.white
  let mask = 2
  let moves = [-33, -31, -18, -14, 14, 18, 31, 33]
  let sliding = false
  let symbol = "\u{2658}\u{fe0e}"
  let type = PieceType.knight
  let value = "N"
}

struct WhiteBishop: Piece {
  let color = PieceColor.white
  let mask = 4
  let moves = [-17, -15, 15, 17]
  let sliding = true
  let symbol = "\u{2657}\u{fe0e}"
  let type = PieceType.bishop
  let value = "B"
}

struct WhiteQueen: Piece {
  let color = PieceColor.white
  let mask = 16
  let moves = [-17, -16, -15, -1, 1, 15, 16, 17]
  let sliding = true
  let symbol = "\u{2655}\u{fe0e}"
  let type = PieceType.queen
  let value = "Q"
}

struct WhiteKing: Piece {
  let color = PieceColor.white
  let mask = 32
  let moves = [-17, -16, -15, -1, 1, 15, 16, 17]
  let sliding = false
  let symbol = "\u{2654}\u{fe0e}"
  let type = PieceType.king
  let value = "K"
}

struct BlackPawn: Piece {
  let color = PieceColor.black
  let mask = 1
  let moves = [16, 32, 15, 17]
  let sliding = false
  let symbol = "\u{265f}\u{fe0e}"
  let type = PieceType.pawn
  let value = "p"
}

struct BlackRook: Piece {
  let color = PieceColor.black
  let mask = 8
  let moves = [-16, -1, 1, 16]
  let sliding = true
  let symbol = "\u{265c}\u{fe0e}"
  let type = PieceType.rook
  let value = "r"
}

struct BlackKnight: Piece {
  let color = PieceColor.black
  let mask = 2
  let moves = [-33, -31, -18, -14, 14, 18, 31, 33]
  let sliding = false
  let symbol = "\u{265e}\u{fe0e}"
  let type = PieceType.knight
  let value = "n"
}

struct BlackBishop: Piece {
  let color = PieceColor.black
  let mask = 4
  let moves = [-17, -15, 15, 17]
  let sliding = true
  let symbol = "\u{265d}\u{fe0e}"
  let type = PieceType.bishop
  let value = "b"
}

struct BlackQueen: Piece {
  let color = PieceColor.black
  let mask = 16
  let moves = [-17, -16, -15, -1, 1, 15, 16, 17]
  let sliding = true
  let symbol = "\u{265b}\u{fe0e}"
  let type = PieceType.queen
  let value = "q"
}

struct BlackKing: Piece {
  let color = PieceColor.black
  let mask = 32
  let moves = [-17, -16, -15, -1, 1, 15, 16, 17]
  let sliding = false
  let symbol = "\u{265a}\u{fe0e}"
  let type = PieceType.king
  let value = "k"
}

struct San {
  let castle: Castling?
  let disambiguator: String
  let dest: Square
  let piece: PieceType
  let promotion: PieceType?
}

struct MoveRequest {
  let from: Square
  let to: Square
  let promotion: PieceType?
}

struct MoveDetails {
  let from: Square
  let to: Square
  let piece: Piece
  let captured: Piece?
  let castling: Castling?
  let promotion: Piece?
  let ep: Square?

  init(from: Square, to: Square, piece: Piece) {
    self.from = from
    self.to = to
    self.piece = piece
    self.captured = nil
    self.castling = nil
    self.promotion = nil
    self.ep = nil
  }

  init(from: Square, to: Square, piece: Piece, captured: Piece) {
    self.from = from
    self.to = to
    self.piece = piece
    self.captured = captured
    self.castling = nil
    self.promotion = nil
    self.ep = nil
  }

  init(from: Square, to: Square, piece: Piece, captured: Piece, ep: Square) {
    self.from = from
    self.to = to
    self.piece = piece
    self.captured = captured
    self.ep = ep
    self.castling = nil
    self.promotion = nil
  }

  init(from: Square, to: Square, piece: Piece, captured: Piece, promotion: Piece) {
    self.from = from
    self.to = to
    self.piece = piece
    self.captured = captured
    self.promotion = promotion
    self.castling = nil
    self.ep = nil
  }

  init(from: Square, to: Square, piece: Piece, promotion: Piece) {
    self.from = from
    self.to = to
    self.piece = piece
    self.promotion = promotion
    self.captured = nil
    self.castling = nil
    self.ep = nil
  }

  init(from: Square, to: Square, piece: Piece, castling: Castling) {
    self.from = from
    self.to = to
    self.piece = piece
    self.castling = castling
    self.captured = nil
    self.promotion = nil
    self.ep = nil
  }
}

enum GameResult: String {
  case white = "1-0"
  case black = "0-1"
  case draw = "1/2-1/2"
  case unknown = "*"
}

enum Termination {
  case checkmate
  case fiftyMoveRule
  case insufficientMaterial
  case stalemate
  case threefoldRepetition
  case unknown
}

struct SettlementState {
  let result: GameResult
  let termination: Termination
}

struct CheckState {
  let white: Bool
  let black: Bool
}

struct GameState {
  let check: CheckState
  let settlement: SettlementState?
}

struct MoveHistory {
  let castling: CastlingTuple
  let details: MoveDetails
  let epSquare: Square?
  let fen: String
  let halfMoveClock: Int
  let pcn: String
  let san: String
  let turn: PieceColor
}

struct Comment {
  let moveCount: Int
  let nag: Int
  let text: String
  let turn: PieceColor
}

struct Tag {
  let name: String
  let value: String
}

protocol ChessProtocol {
  func export(ascii: Bool) -> String
  func export(fen: Bool) -> String
  func export(pgn: Bool) throws -> String
  func getBoard() -> [Piece?]
  func getCastling() -> CastlingTuple
  func getComment() -> Comment?
  func getComments() -> [Comment]
  func getEnPassantSquare() -> Square?
  func getGameState() -> GameState
  func getMoveCount() -> Int
  func getMoveHistory() -> [MoveHistory]
  func getPieces() -> [(Piece, Square)]
  func getTag(_ name: String) -> Tag?
  func getTags() -> [Tag]
  func getTurn() -> PieceColor
  func isCheck() -> Bool
  func isCheckmate() -> Bool
  func isDraw() -> Bool
  func isInsufficientMaterial() -> Bool
  func isLegalMove(move: MoveHistory) -> Bool
  func isStalemate() -> Bool
  func isThreefoldRepetition() -> Bool
  func load(fen: String)
  func load(pgn: String) throws
  func move(move: MoveRequest) throws -> MoveHistory
  func move(pcn: String) throws -> MoveHistory
  func move(san: String) throws -> MoveHistory
  func removeComment()
  func removeTag(name: String)
  func reset()
  func reset(chess: Chess)
  func san(_ move: MoveDetails, _ moves: [MoveDetails]) -> String
  func setComment(comment: String, nag: Int)
  func setTag(tag name: String, value: String)
  func undoMove() throws -> MoveHistory
  static func algebraic(_ square: Square) -> String
  static func opposingColor(_ color: PieceColor) -> PieceColor
  static func pcn(_ move: MoveDetails) -> String
}

typealias CastlingTuple = (Castling, Castling, Castling, Castling)

protocol BoardProtocol {
  func getAllMoves(for color: PieceColor, castling: CastlingTuple, ep: Square?) -> [MoveDetails]
  func getAllMoves(
    for color: PieceColor, castling: CastlingTuple, ep: Square?, filterBy: PieceType?
  )
    -> [MoveDetails]
  func getCandidateMoves(at square: Square, castling: CastlingTuple, ep: Square?) -> [MoveDetails]
  func getKingSquare(color: PieceColor) -> Square
  func getSquareContents(_ square: Square) -> Piece?
  func isPieceAttacked(at attackedSquare: Square) -> Bool
  func toAscii() -> String
  func toRanks() -> [String]
  mutating func clear(sq: Square)
  mutating func makeMove(_ move: MoveDetails)
  mutating func put(sq: Square, piece: Piece)
  mutating func reset()
  mutating func setup(ranks: [String])
  mutating func undoMove(_ move: MoveDetails)
  static func getCoords(_ square: Square) -> (String, String)
  static func getSquareColor(_ square: Square) -> PieceColor
  static func isMoveLegal(_ move: MoveDetails, _ data: [Piece?]) -> Bool
  static func squareToString(_ square: Square?) -> String
}

let squares: [String: Square] = [
  "a8": Square.a8, "b8": Square.b8, "c8": Square.c8, "d8": Square.d8, "e8": Square.e8,
  "f8": Square.f8, "g8": Square.g8, "h8": Square.h8, "a7": Square.a7, "b7": Square.b7,
  "c7": Square.c7, "d7": Square.d7, "e7": Square.e7, "f7": Square.f7, "g7": Square.g7,
  "h7": Square.h7, "a6": Square.a6, "b6": Square.b6, "c6": Square.c6,
  "d6": Square.d6, "e6": Square.e6, "f6": Square.f6, "g6": Square.g6, "h6": Square.h6,
  "a5": Square.a5, "b5": Square.b5, "c5": Square.c5, "d5": Square.d5,
  "e5": Square.e5, "f5": Square.f5, "g5": Square.g5, "h5": Square.h5, "a4": Square.a4,
  "b4": Square.b4, "c4": Square.c4, "d4": Square.d4, "e4": Square.e4,
  "f4": Square.f4, "g4": Square.g4, "h4": Square.h4, "a3": Square.a3, "b3": Square.b3,
  "c3": Square.c3, "d3": Square.d3, "e3": Square.e3, "f3": Square.f3,
  "g3": Square.g3, "h3": Square.h3, "a2": Square.a2, "b2": Square.b2, "c2": Square.c2,
  "d2": Square.d2, "e2": Square.e2, "f2": Square.f2, "g2": Square.g2,
  "h2": Square.h2, "a1": Square.a1, "b1": Square.b1, "c1": Square.c1, "d1": Square.d1,
  "e1": Square.e1, "f1": Square.f1, "g1": Square.g1, "h1": Square.h1,
]
