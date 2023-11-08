import XCTest

@testable import CEJ25

final class FenTests: XCTestCase {
  func testValidateBadFen() throws {
    XCTAssertThrowsError(try Fen.validate(fen: "bad fen")) {
      XCTAssertEqual(
        $0 as! FenValidationError, FenValidationError.cannotParse, "bad fen does not validate")
    }
  }

  func testValidateStartPos() throws {
    let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    XCTAssertNoThrow(try Fen.validate(fen: fen), "starting position")
  }

  func testValidateGoodFen() throws {
    let fen1 = "8/Q6p/6p1/5p2/5P2/2p3P1/3r3P/2K1k3 b - - 3 44"
    XCTAssertNoThrow(try Fen.validate(fen: fen1), "Kasparov vs. Topalov, Wijk aan Zee 1999")

    let fen2 = "1n1Rkb1r/p4ppp/4q3/4p1B1/4P3/8/PPP2PPP/2K5 b k - 1 17"
    XCTAssertNoThrow(try Fen.validate(fen: fen2), "Morphy vs. Allies, Paris Opera 1858")

    let fen3 = "2r3k1/pb4p1/4p3/1p3p1q/5Pn1/P1NQb2P/1P4P1/R1B2R1K w - - 4 24"
    XCTAssertNoThrow(try Fen.validate(fen: fen3), "Aronian vs. Anand, Wijk aan Zee 2013")

    let fen4 = "8/5pk1/7p/8/1p4P1/1P1R2P1/3N1qBP/3Nr2K w - - 1 41"
    XCTAssertNoThrow(
      try Fen.validate(fen: fen4), "Karpov vs. Kasparov, World Championship 1985, game 16")

    let fen5 = "1Q6/5pk1/2p3p1/1p2N2p/1b5P/1bn5/2r3P1/2K5 w - - 16 42"
    XCTAssertNoThrow(try Fen.validate(fen: fen5), "Byrne vs. Fischer, New York 1956")

    let fen6 = "7k/p7/4N1pp/8/2PP4/4p1qB/P3P3/R4K2 w - - 1 40"
    XCTAssertNoThrow(try Fen.validate(fen: fen6), "Ivanchuk vs. Yusupov, Brussels 1991")

    let fen7 = "2b1rrk1/2pR1p2/1pq1pQp1/p3P1Kp/P1PR3P/5N2/2P2PP1/8 b - - 7 34"
    XCTAssertNoThrow(try Fen.validate(fen: fen7), "Short vs. Timman, Tilburg 1991")

    let fen8 = "6k1/5ppp/pb2p3/1p2P3/1P2bPnP/P6r/1B4QP/R4R1K w - - 2 26"
    XCTAssertNoThrow(try Fen.validate(fen: fen8), "Rotlewi vs. Rubinstein, Lodz 1907")

    let fen9 = "4n2Q/pb1p1kp1/5p1B/1p6/3P3R/P4qN1/6rP/2R1K3 w - - 4 27"
    XCTAssertNoThrow(try Fen.validate(fen: fen9), "Geller vs. Euwe, Zurich 1953")
  }

  func testValidateThreeKingsTwoWhiteKings() throws {
    let fen = "4k3/8/8/8/8/8/8/4KK2 w - - 0 1"
    XCTAssertThrowsError(try Fen.validate(fen: fen)) {
      XCTAssertEqual($0 as! FenValidationError, FenValidationError.wrongKings, "three kings")
    }
  }

  func testValidateJustTwoBlackKings() throws {
    let fen = "4k3/8/8/8/8/8/8/4k3 w - - 0 1"
    XCTAssertThrowsError(try Fen.validate(fen: fen)) {
      XCTAssertEqual($0 as! FenValidationError, FenValidationError.wrongKings, "two wrong kings")
    }
  }

  func testValidatePawnsOnFirstAndLast() throws {
    let fen = "3Pk3/8/8/8/8/8/8/3pK3 w - - 0 1"
    XCTAssertThrowsError(try Fen.validate(fen: fen)) {
      XCTAssertEqual($0 as! FenValidationError, FenValidationError.cannotParse, "pawns on last row")
    }
  }

  func testValidateBadRank() throws {
    let fen1 = "4k3/ppppppppp/8/8/8/8/8/3K4 w - - 0 1"
    XCTAssertThrowsError(try Fen.validate(fen: fen1)) {
      XCTAssertEqual(
        $0 as! FenValidationError, FenValidationError.badRank, "too many pieces on one rank")
    }

    let fen2 = "4k3/2p2pp1/8/8/8/8/PPPP/3K4 w - - 0 1"
    XCTAssertThrowsError(try Fen.validate(fen: fen2)) {
      XCTAssertEqual(
        $0 as! FenValidationError, FenValidationError.badRank, "rank does not add up")
    }
  }

  func testValidateRankNumbersAddUp() throws {
    let fen1 = "3k5/8/8/8/8/8/8/3K3 w - - 0 1"
    XCTAssertThrowsError(try Fen.validate(fen: fen1)) {
      XCTAssertEqual($0 as! FenValidationError, FenValidationError.badRank, "too many")
    }

    let fen2 = "3k4/8/8/8/8/8/8/3K3 w - - 0 1"
    XCTAssertThrowsError(try Fen.validate(fen: fen2)) {
      XCTAssertEqual($0 as! FenValidationError, FenValidationError.badRank, "not enough")
    }
  }

  func testValidateConsecutiveNumbers() throws {
    let fen1 = "33Pk/8/8/8/8/8/8/3pK3 w - - 0 1"
    XCTAssertThrowsError(try Fen.validate(fen: fen1)) {
      XCTAssertEqual(
        $0 as! FenValidationError, FenValidationError.cannotParse, "int must follow char")
    }

    let fen2 = "4k3/8/4p21/8/8/4P3/8/4K3 w - - 0 1"
    XCTAssertThrowsError(try Fen.validate(fen: fen2)) {
      XCTAssertEqual(
        $0 as! FenValidationError, FenValidationError.badRank, "int must follow char again")
    }
  }

  func testParseStartPos() throws {
    let result = Fen.parse(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")!
    XCTAssertEqual(result.halfMoveClock, 0, "half move clock set to 0")
    XCTAssertEqual(result.fullMoveCounter, 1, "full move counter starts at 1")
    XCTAssertEqual(result.turn, PieceColor.white, "it's white's turn")
  }

  func testParseBadFen() throws {
    let result = Fen.parse(fen: "oops")
    XCTAssert(result == nil, "fen did not parse")
  }

  func testEnPassant() throws {
    let result = Fen.parse(fen: "rnbqkbnr/pppp1p1p/8/4pPp1/8/8/PPPPP1PP/RNBQKBNR w KQkq g6 0 1")!
    XCTAssertEqual(result.epSquare, Square.g6, "en-passant square is g6")
  }

  func testFenToString() throws {
    let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    let parsed = Fen.parse(fen: fen)
    let str = parsed!.toString()
    XCTAssertEqual(fen, str, "fen can be converted back to string")
  }
}
