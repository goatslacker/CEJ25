import XCTest

@testable import CEJ25

final class BoardTests: XCTestCase {
  private func getRanks(_ fen: String) -> [String] {
    return Fen.parse(fen: fen)!.ranks
  }

  func testToAscii() throws {
    let board = Board(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    let ascii = board.toAscii()
    print(ascii)
    XCTAssertEqual(
      ascii,
      """
      8  r n b q k b n r
      7  p p p p p p p p
      6  · · · · · · · ·
      5  · · · · · · · ·
      4  · · · · · · · ·
      3  · · · · · · · ·
      2  P P P P P P P P
      1  R N B Q K B N R
         a b c d e f g h
      """, "ascii board is matched")
  }

  func testCandidateMovesStartPos() throws {
    let board = Board(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

    let castling = (Castling.none, Castling.none, Castling.none, Castling.none)

    let moves = board.getCandidateMoves(at: Square.h1, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(moves, [], "moves for white rook at h1")

    let moves2 = board.getCandidateMoves(at: Square.d4, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(moves2, [], "empty square at d4")

    let moves3 = board.getCandidateMoves(at: Square.b2, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(moves3, ["b2b4", "b2b3"], "starting pawn has two available moves")

    let moves4 = board.getCandidateMoves(at: Square.c7, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(moves4, ["c7c5", "c7c6"], "black pawn has two available moves")

    let moves5 = board.getCandidateMoves(at: Square.g1, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(moves5, ["g1f3", "g1h3"], "white knight moves")

    let moves6 = board.getCandidateMoves(at: Square.b8, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(moves6, ["b8a6", "b8c6"], "black knight moves")

    let moves7 = board.getCandidateMoves(at: Square.e8, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(moves7, [], "king no moves")
  }

  func testCandidateMovesPawn() throws {
    var board = Board()
    let castling = (Castling.none, Castling.none, Castling.none, Castling.none)

    board.setup(ranks: self.getRanks("4k3/8/8/2P5/8/8/8/4K3 w - - 0 1"))
    let pawnPush = board.getCandidateMoves(at: Square.c5, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(pawnPush, ["c5c6"], "pawn push")

    board.setup(ranks: self.getRanks("8/P7/8/8/6k1/8/8/4K3 w - - 0 1"))
    let possiblePromotion = board.getCandidateMoves(at: Square.a7, castling: castling, ep: nil).map
    { Chess.pcn($0) }
    XCTAssertEqual(possiblePromotion, ["a7a8n", "a7a8b", "a7a8r", "a7a8q"], "possible promotion")

    board.setup(ranks: self.getRanks("8/8/8/8/6k1/2p1p3/3P4/4K3 w - - 0 1"))
    let pawnCapture = board.getCandidateMoves(at: Square.d2, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(pawnCapture, ["d2d4", "d2d3", "d2c3", "d2e3"], "pawn captures")

    board.setup(ranks: self.getRanks("8/8/2p5/pP6/6k1/8/8/4K3 w - a6 0 1"))
    let enPassant = board.getCandidateMoves(at: Square.b5, castling: castling, ep: Square.a6).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(enPassant, ["b5b6", "b5c6", "b5a6"], "pawn moves including en-passant")

    board.setup(ranks: self.getRanks("8/8/3b4/3Pp3/6k1/8/5B2/4K3 w - e6 0 1"))
    let enPassantCapture = board.getCandidateMoves(at: Square.d5, castling: castling, ep: Square.e6)
      .map {
        $0.captured!
      }
    XCTAssertEqual(enPassantCapture.count, 1, "en-passant is forced!")
    if enPassantCapture.count > 0 {
      XCTAssertEqual(enPassantCapture[0].type, PieceType.pawn, "capture is a pawn")
      XCTAssertEqual(enPassantCapture[0].color, PieceColor.black, "capture is a black pawn")
    }
  }

  func testCandidateMovesKing() throws {
    var board = Board()
    let castling = (Castling.none, Castling.none, Castling.none, Castling.none)

    board.setup(ranks: self.getRanks("8/8/Kr3q1k/8/8/8/8/8 w - - 0 1"))
    let kingCannotCapture = board.getCandidateMoves(at: Square.a6, castling: castling, ep: nil).map
    { Chess.pcn($0) }
    XCTAssertEqual(kingCannotCapture, ["a6a7", "a6a5"], "king cannot capture rook")

    board.setup(ranks: self.getRanks("2kr4/ppp5/8/8/8/8/4QPPP/q1N1K2R w K - 0 1"))
    let kingShouldCastleKingside = board.getCandidateMoves(
      at: Square.e1,
      castling: (
        Castling.kingside, Castling.none, Castling.none, Castling.none
      ),
      ep: nil
    ).map { Chess.pcn($0) }
    XCTAssertEqual(
      kingShouldCastleKingside, ["e1f1", "e1g1"], "king should castle kingside")

    board.setup(ranks: self.getRanks("6b1/3p1p2/2k1K3/8/6n1/8/5r2/8 w - - 0 1"))
    let kingOnlyMove = board.getCandidateMoves(at: Square.e6, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(kingOnlyMove, ["e6e7"], "only move king has")

    board.setup(ranks: self.getRanks("7k/1pp5/8/8/8/6K1/8/8 b - - 0 1"))
    let kingCornered = board.getCandidateMoves(at: Square.h8, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(kingCornered, ["h8g8", "h8g7", "h8h7"], "cornered king")

    board.setup(ranks: self.getRanks("4k2r/8/8/8/8/8/8/4K3 w k - 0 1"))
    let kingEmptyBoardStart = board.getCandidateMoves(
      at: Square.e8,
      castling: (Castling.none, Castling.none, Castling.kingside, Castling.none),
      ep: nil
    ).map(Chess.pcn)
    XCTAssertEqual(
      kingEmptyBoardStart, ["e8d8", "e8f8", "e8d7", "e8e7", "e8f7", "e8g8"],
      "all king moves from start empty board")

    board.setup(ranks: self.getRanks("4k3/6pp/8/8/3K4/8/8/8 w - - 0 1"))
    let kingOpenBoard = board.getCandidateMoves(at: Square.d4, castling: castling, ep: nil).map(
      Chess.pcn)
    XCTAssertEqual(
      kingOpenBoard, ["d4c5", "d4d5", "d4e5", "d4c4", "d4e4", "d4c3", "d4d3", "d4e3"],
      "open board king")
  }

  func testCandidateMovesKnight() throws {
    var board = Board()
    let castling = (Castling.none, Castling.none, Castling.none, Castling.none)

    board.setup(ranks: self.getRanks("4r1k1/1b3rp1/1n3q1p/2p1N3/1p6/7P/PP3PP1/R2QR1K1 w - - 0 25"))
    let knightMoves = board.getCandidateMoves(at: Square.e5, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(
      knightMoves, ["e5d7", "e5f7", "e5c6", "e5g6", "e5c4", "e5g4", "e5d3", "e5f3"],
      "all knight moves")
  }

  func testCandidateMovesOpenBoard() throws {
    let board = Board(fen: "4k3/8/8/8/2R5/8/8/4K3 w - - 0 1")
    let castling = (Castling.none, Castling.none, Castling.none, Castling.none)

    let moves = board.getCandidateMoves(at: Square.c4, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(
      moves,
      [
        "c4c5", "c4c6", "c4c7", "c4c8",
        "c4b4", "c4a4",
        "c4d4", "c4e4", "c4f4", "c4g4", "c4h4",
        "c4c3", "c4c2", "c4c1",
      ], "rook on c4")

    // TODO test more open board moves
  }

  func testAttacks() throws {
    var board = Board(fen: "4k3/2p5/8/8/8/2R5/8/4K3 w - - 0 1")
    XCTAssertTrue(
      board.isPieceAttacked(at: Square.c7),
      "pawn is attacked by rook"
    )

    board.setup(ranks: self.getRanks("4k3/4p3/8/8/8/3b1b2/4P3/4K3 w - - 0 1"))
    XCTAssertTrue(board.isPieceAttacked(at: Square.d3), "d3 diagonal attack")
    XCTAssertTrue(board.isPieceAttacked(at: Square.f3), "f3 diagonal attack")

    board.setup(ranks: self.getRanks("4k3/4p3/3p1p2/2p3p1/4N3/8/8/4K3 w - - 0 1"))
    XCTAssertTrue(board.isPieceAttacked(at: Square.g5), "knight g5 attack")
    XCTAssertTrue(board.isPieceAttacked(at: Square.f6), "knight f6 attack")
    XCTAssertTrue(board.isPieceAttacked(at: Square.d6), "knight d6 attack")
    XCTAssertTrue(board.isPieceAttacked(at: Square.c5), "knight c5 attack")

    board.setup(ranks: self.getRanks("4k3/q7/8/8/Q1Q5/8/8/4K3 b - - 1 1"))
    XCTAssertTrue(board.isPieceAttacked(at: Square.a7), "queen attack on a7")
    XCTAssertFalse(board.isPieceAttacked(at: Square.c4), "can't attack friendly piece")
    XCTAssertFalse(board.isPieceAttacked(at: Square.c6), "can't attack empty square")

    board.setup(ranks: self.getRanks("4k3/4n3/8/8/8/4q3/4P3/4K3 b - - 0 1"))
    XCTAssertFalse(board.isPieceAttacked(at: Square.e1), "pawn is blocking")

    board.setup(ranks: self.getRanks("4k3/4r3/8/1pP5/7B/8/4Rn2/4K3 w - b6 0 1"))
    XCTAssertTrue(board.isPieceAttacked(at: Square.e7), "bishop x rook at e7")
    XCTAssertTrue(board.isPieceAttacked(at: Square.f2), "bishop+king x knight at f2")
    XCTAssertFalse(board.isPieceAttacked(at: Square.e8), "e8 king not attacked")
    XCTAssertFalse(board.isPieceAttacked(at: Square.e1), "e1 king not attacked")
  }

  func testLegalMoves() throws {
    let board = Board(fen: "4k3/4r3/8/8/8/8/4B3/4K3 w - - 0 1")
    let castling = (Castling.none, Castling.none, Castling.none, Castling.none)

    let moves = board.getCandidateMoves(at: Square.e2, castling: castling, ep: nil).map {
      Chess.pcn($0)
    }
    XCTAssertEqual(moves, [], "cannot move because pinned")

    // TODO test other legal moves
  }

  func testMakeMove() throws {
    var board = Board(fen: "8/8/8/8/2pP4/2b2k2/5B2/5K2 b - d3 0 1")
    board.makeMove(
      MoveDetails(
        from: Square.c4, to: Square.d3,
        piece: BlackPawn(), captured: WhitePawn(), ep: Square.d4))
    XCTAssertTrue(board.data[Square.d4.rawValue] == nil, "white pawn is gone")
  }
}
