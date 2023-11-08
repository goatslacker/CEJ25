import XCTest

@testable import CEJ25

final class ChessTests: XCTestCase {
  func testStartPos() throws {
    let chess = Chess()
    let startPos = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    chess.load(fen: startPos)
    let fen = chess.export(fen: true)
    XCTAssertEqual(fen, startPos, "fen export works")
  }

  private func doTestFenExport(title: String, fen: String) throws {
    let chess = Chess()
    chess.load(fen: fen)
    XCTAssertEqual(
      fen, chess.export(fen: true), title)
  }

  func testPopularFen() throws {
    try self.doTestFenExport(
      title: "Alexander Steinkuehler vs Joseph Henry Blackburne",
      fen: "r4r1k/pp4pp/3p4/3B4/8/1QN3Pb/PP3nKP/R5R1 w - - 3 23"
    )

    try self.doTestFenExport(
      title: "Aron Nimzowitsch vs Siegbert Tarrasch",
      fen: "4r1k1/p2K3p/6p1/1bpP4/4P3/1PQ5/PB5q/2R5 w - - 7 33"
    )

    try self.doTestFenExport(
      title: "Donald Burne vs Robert James Fischer",
      fen: "1Q6/5pk1/2p3p1/1p2N2p/1b5P/1bn5/2r3P1/2K5 w - - 16 42"
    )

    try self.doTestFenExport(
      title: "Alexander McDonnell vs Louis-Charles Mahé de La Bourdonnais",
      fen: "3b2rk/3P2pp/8/p7/8/2Q5/PP1pppPP/3R3K w - - 0 38"
    )

    try self.doTestFenExport(
      title: "Adolf Anderssen vs Lionel Kieseritzky",
      fen: "r1bk3r/p2pBpNp/n4n2/1p1NP2P/6P1/3P4/P1P1K3/q5b1 b - - 1 23"
    )

    try self.doTestFenExport(
      title: "Garry Kasparov vs Vassily Ivanchuk",
      fen: "2N1b1rq/5p1k/5Q1R/pPp2pP1/P4N2/7P/8/7K b - - 0 39"
    )

    try self.doTestFenExport(
      title: "Garry Kasparov vs Anatoly Karpov",
      fen: "8/5pk1/7p/8/1p4P1/1P1R2P1/7P/3N1q1K w - - 0 43"
    )

    try self.doTestFenExport(
      title: "Robert James Fischer vs Robert Eugene Byrne",
      fen: "r5k1/pb3p1p/1p4p1/8/3b4/BPN3Pq/P4Q1P/R3R1K1 w - - 0 25"
    )

    try self.doTestFenExport(
      title: "Nigel Short vs Jan Timman (1991) A Long Walk Off a Short Peer",
      fen: "2b1rrk1/2p2pQ1/1pq1p1pK/p3P2p/P1PR3P/5N2/2P2PP1/8 b - - 3 36"
    )

    try self.doTestFenExport(
      title: "Paul Morphy vs Carl Isouard 'The Opera Chess'",
      fen: "1n1Rkb1r/p4ppp/4q3/4p1B1/4P3/8/PPP2PPP/2K5 b k - 1 17"
    )
  }

  func testCheck() throws {
    XCTAssertTrue(Chess(fen: "1R2k3/8/8/8/8/8/8/4K3 b - - 0 1").isCheck(), "rook check 8th rank")
    XCTAssertTrue(Chess(fen: "1R2k3/8/4K3/8/8/8/8/8 w - - 0 1").isCheck(), "checkmate actually")
    XCTAssertTrue(Chess(fen: "4k3/8/4KN2/8/8/8/8/8 b - - 0 1").isCheck(), "knight check")
    XCTAssertTrue(
      Chess(fen: "rnbqkbnr/pppp1ppp/8/8/4Q3/8/PPPP1PPP/RNB1KBNR b KQkq - 0 1").isCheck(),
      "queen check")
    XCTAssertTrue(
      Chess(fen: "4k2r/pbp3bp/3p2p1/1B3pB1/8/2N2N2/PPP2PPP/R4RK1 w k - 0 1").isCheck(),
      "bishop check")
    XCTAssertTrue(
      Chess(fen: "5rk1/pp3pbp/2p3p1/1b1n2B1/5pP1/PPNB1NKP/2P2P2/4RR2 b - - 0 1").isCheck(),
      "pawn check")
    XCTAssertTrue(
      Chess(fen: "rn2k2r/pp3pbp/1qpp1Np1/6B1/3P2b1/2NBQ3/PPP2PPP/2KR3R w kq - 0 1").isCheck(),
      "double check")
    XCTAssertFalse(Chess(fen: "4k3/8/8/8/8/8/8/4K3 w - - 0 1").isCheck(), "no check")
  }

  func testCheckmate() throws {
    let fool = Chess(fen: "rnbqkbnr/ppppp2p/5p2/6pQ/3PP3/8/PPP2PPP/RNB1KBNR w KQkq - 0 1")
    XCTAssertTrue(
      fool.isCheckmate(),
      "fool's mate")

    let anastasia = try Chess(
      pgn:
        "1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. b4 Bxb4 5. c3 Ba5 6. d4 exd4 7. O-O d6 8. Qb3 Qf6 9. cxd4 Bb6 10. e5 dxe5 11. dxe5 Qg6 12. Nh4 Qh5 13. e6 fxe6 14. Bxe6 Bxe6 15. Qxe6+ Nge7 16. Nf3 Rf8 17. Bg5 Rxf3 18. Bxe7 Nd4 19. Qe4 Rf4 20. Qxb7 Kxe7 21. Qxa8 Ne2+ 22. Kh1 Qxh2+ 23. Kxh2 Rh4#"
    )
    XCTAssertTrue(
      anastasia.isCheckmate(),
      "anastasia's mate")

    let arabian = try Chess(
      pgn:
        "1. e4 e5 2. Nf3 Nc6 3. d4 exd4 4. Bc4 Bc5 5. O-O d6 6. c3 Bg4 7. Qb3 Bxf3 8. Bxf7+ Kf8 9. Bxg8 Rxg8 10. gxf3 g5 11. Qe6 Ne5 12. Qf5+ Kg7 13. Kh1 Kh8 14. Rg1 g4 15. f4 Nf3 16. Rxg4 Qh4 17. Rg2 Qxh2+ 18. Rxh2 Rg1# 0-1"
    )
    XCTAssertTrue(
      arabian.isCheckmate(),
      "arabian mate")

    let backrank = try Chess(
      pgn:
        "1. e4 c5 2. Nc3 Nc6 3. g3 g6 4. Bg2 Bg7 5. d3 e6 6. Be3 Qa5 7. Nge2 Nd4 8. O-O Ne7 9. a3 Nec6 10. Rb1 d6 11. b4 Qc7 12. Kh1 O-O 13. Qd2 Bd7 14. f4 f5 15. Ng1 Rab8 16. Rfc1 b5 17. Nd1 e5 18. c3 Ne6 19. exf5 Rxf5 20. fxe5 Nxe5 21. c4 Ng4 22. Ne2 Bc6 23. Nf4 Nxf4 24. Bxf4 Be5 25. Bxe5 Rf1# 0-1"
    )
    XCTAssertTrue(
      backrank.isCheckmate(),
      "back rank mate")

    // TODO add more tests
  }

  private func doTestMovePcn(title: String, fen: String, pcn: String) throws {
    let chess = Chess(fen: fen)
    let move = try? chess.move(pcn: pcn)
    if move != nil {
      XCTAssertEqual(move!.pcn, pcn, title)
    } else {
      XCTAssertTrue(false, "\(title): nil")
    }
  }

  func testMovePcn() throws {
    try doTestMovePcn(
      title: "queen's pawn opening",
      fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", pcn: "d2d4")
    try doTestMovePcn(
      title: "2018-WCC: e4", fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
      pcn: "e2e4")
    try doTestMovePcn(
      title: "2018-WCC: c5", fen: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1",
      pcn: "c7c5")
    try doTestMovePcn(
      title: "2018-WCC: Nf3", fen: "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2",
      pcn: "g1f3")
    try doTestMovePcn(
      title: "2018-WCC: e6", fen: "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2",
      pcn: "e7e6")
    try doTestMovePcn(
      title: "2018-WCC: c4",
      fen: "rnbqkbnr/pp1p1ppp/4p3/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 0 3", pcn: "c2c4")
    try doTestMovePcn(
      title: "2018-WCC: Nc6",
      fen: "rnbqkbnr/pp1p1ppp/4p3/2p5/2P1P3/5N2/PP1P1PPP/RNBQKB1R b KQkq - 0 3", pcn: "b8c6")
    try doTestMovePcn(
      title: "2018-WCC: d4",
      fen: "r1bqkbnr/pp1p1ppp/2n1p3/2p5/2P1P3/5N2/PP1P1PPP/RNBQKB1R w KQkq - 1 4", pcn: "d2d4")
    try doTestMovePcn(
      title: "2018-WCC: cxd4",
      fen: "r1bqkbnr/pp1p1ppp/2n1p3/2p5/2PPP3/5N2/PP3PPP/RNBQKB1R b KQkq - 0 4", pcn: "c5d4")
    try doTestMovePcn(
      title: "2018-WCC: Nxd4",
      fen: "r1bqkbnr/pp1p1ppp/2n1p3/8/2PpP3/5N2/PP3PPP/RNBQKB1R w KQkq - 0 5", pcn: "f3d4")
    try doTestMovePcn(
      title: "2018-WCC: Bc5", fen: "r1bqkbnr/pp1p1ppp/2n1p3/8/2PNP3/8/PP3PPP/RNBQKB1R b KQkq - 0 5",
      pcn: "f8c5")
    try doTestMovePcn(
      title: "2018-WCC: Nc2",
      fen: "r1bqk1nr/pp1p1ppp/2n1p3/2b5/2PNP3/8/PP3PPP/RNBQKB1R w KQkq - 1 6", pcn: "d4c2")
    try doTestMovePcn(
      title: "2018-WCC: Nf6",
      fen: "r1bqk1nr/pp1p1ppp/2n1p3/2b5/2P1P3/8/PPN2PPP/RNBQKB1R b KQkq - 2 6", pcn: "g8f6")
    try doTestMovePcn(
      title: "2018-WCC: Nc3",
      fen: "r1bqk2r/pp1p1ppp/2n1pn2/2b5/2P1P3/8/PPN2PPP/RNBQKB1R w KQkq - 3 7", pcn: "b1c3")
    try doTestMovePcn(
      title: "2018-WCC: O-O",
      fen: "r1bqk2r/pp1p1ppp/2n1pn2/2b5/2P1P3/2N5/PPN2PPP/R1BQKB1R b KQkq - 4 7", pcn: "e8g8")
    try doTestMovePcn(
      title: "2018-WCC: Be3",
      fen: "r1bq1rk1/pp1p1ppp/2n1pn2/2b5/2P1P3/2N5/PPN2PPP/R1BQKB1R w KQ - 5 8", pcn: "c1e3")
    try doTestMovePcn(
      title: "2018-WCC: b6",
      fen: "r1bq1rk1/pp1p1ppp/2n1pn2/2b5/2P1P3/2N1B3/PPN2PPP/R2QKB1R b KQ - 6 8", pcn: "b7b6")
    try doTestMovePcn(
      title: "2018-WCC: Be2",
      fen: "r1bq1rk1/p2p1ppp/1pn1pn2/2b5/2P1P3/2N1B3/PPN2PPP/R2QKB1R w KQ - 0 9", pcn: "f1e2")
    try doTestMovePcn(
      title: "2018-WCC: Bb7",
      fen: "r1bq1rk1/p2p1ppp/1pn1pn2/2b5/2P1P3/2N1B3/PPN1BPPP/R2QK2R b KQ - 1 9", pcn: "c8b7")
    try doTestMovePcn(
      title: "2018-WCC: O-O",
      fen: "r2q1rk1/pb1p1ppp/1pn1pn2/2b5/2P1P3/2N1B3/PPN1BPPP/R2QK2R w KQ - 2 10", pcn: "e1g1")
    try doTestMovePcn(
      title: "2018-WCC: Qe7",
      fen: "r2q1rk1/pb1p1ppp/1pn1pn2/2b5/2P1P3/2N1B3/PPN1BPPP/R2Q1RK1 b - - 3 10", pcn: "d8e7")
    try doTestMovePcn(
      title: "2018-WCC: Qd2",
      fen: "r4rk1/pb1pqppp/1pn1pn2/2b5/2P1P3/2N1B3/PPN1BPPP/R2Q1RK1 w - - 4 11", pcn: "d1d2")
    try doTestMovePcn(
      title: "2018-WCC: Rfd8",
      fen: "r4rk1/pb1pqppp/1pn1pn2/2b5/2P1P3/2N1B3/PPNQBPPP/R4RK1 b - - 5 11", pcn: "f8d8")
    try doTestMovePcn(
      title: "2018-WCC: Rfd1",
      fen: "r2r2k1/pb1pqppp/1pn1pn2/2b5/2P1P3/2N1B3/PPNQBPPP/R4RK1 w - - 6 12", pcn: "f1d1")
    try doTestMovePcn(
      title: "2018-WCC: Ne5",
      fen: "r2r2k1/pb1pqppp/1pn1pn2/2b5/2P1P3/2N1B3/PPNQBPPP/R2R2K1 b - - 7 12", pcn: "c6e5")
    try doTestMovePcn(
      title: "2018-WCC: Bxc5",
      fen: "r2r2k1/pb1pqppp/1p2pn2/2b1n3/2P1P3/2N1B3/PPNQBPPP/R2R2K1 w - - 8 13", pcn: "e3c5")
    try doTestMovePcn(
      title: "2018-WCC: bxc5",
      fen: "r2r2k1/pb1pqppp/1p2pn2/2B1n3/2P1P3/2N5/PPNQBPPP/R2R2K1 b - - 0 13", pcn: "b6c5")
    try doTestMovePcn(
      title: "2018-WCC: f4", fen: "r2r2k1/pb1pqppp/4pn2/2p1n3/2P1P3/2N5/PPNQBPPP/R2R2K1 w - - 0 14",
      pcn: "f2f4")
    try doTestMovePcn(
      title: "2018-WCC: Ng6",
      fen: "r2r2k1/pb1pqppp/4pn2/2p1n3/2P1PP2/2N5/PPNQB1PP/R2R2K1 b - - 0 14", pcn: "e5g6")
    try doTestMovePcn(
      title: "2018-WCC: Qe3",
      fen: "r2r2k1/pb1pqppp/4pnn1/2p5/2P1PP2/2N5/PPNQB1PP/R2R2K1 w - - 1 15", pcn: "d2e3")
    try doTestMovePcn(
      title: "2018-WCC: d6",
      fen: "r2r2k1/pb1pqppp/4pnn1/2p5/2P1PP2/2N1Q3/PPN1B1PP/R2R2K1 b - - 2 15", pcn: "d7d6")
    try doTestMovePcn(
      title: "2018-WCC: Rd2",
      fen: "r2r2k1/pb2qppp/3ppnn1/2p5/2P1PP2/2N1Q3/PPN1B1PP/R2R2K1 w - - 0 16", pcn: "d1d2")
    try doTestMovePcn(
      title: "2018-WCC: a6", fen: "r2r2k1/pb2qppp/3ppnn1/2p5/2P1PP2/2N1Q3/PPNRB1PP/R5K1 b - - 1 16",
      pcn: "a7a6")
    try doTestMovePcn(
      title: "2018-WCC: Rad1",
      fen: "r2r2k1/1b2qppp/p2ppnn1/2p5/2P1PP2/2N1Q3/PPNRB1PP/R5K1 w - - 0 17", pcn: "a1d1")
    try doTestMovePcn(
      title: "2018-WCC: Qc7",
      fen: "r2r2k1/1b2qppp/p2ppnn1/2p5/2P1PP2/2N1Q3/PPNRB1PP/3R2K1 b - - 1 17", pcn: "e7c7")
    try doTestMovePcn(
      title: "2018-WCC: b3",
      fen: "r2r2k1/1bq2ppp/p2ppnn1/2p5/2P1PP2/2N1Q3/PPNRB1PP/3R2K1 w - - 2 18", pcn: "b2b3")
    try doTestMovePcn(
      title: "2018-WCC: h6",
      fen: "r2r2k1/1bq2ppp/p2ppnn1/2p5/2P1PP2/1PN1Q3/P1NRB1PP/3R2K1 b - - 0 18", pcn: "h7h6")
    try doTestMovePcn(
      title: "2018-WCC: g3",
      fen: "r2r2k1/1bq2pp1/p2ppnnp/2p5/2P1PP2/1PN1Q3/P1NRB1PP/3R2K1 w - - 0 19", pcn: "g2g3")
    try doTestMovePcn(
      title: "2018-WCC: Rd7",
      fen: "r2r2k1/1bq2pp1/p2ppnnp/2p5/2P1PP2/1PN1Q1P1/P1NRB2P/3R2K1 b - - 0 19", pcn: "d8d7")
    try doTestMovePcn(
      title: "2018-WCC: Bf3",
      fen: "r5k1/1bqr1pp1/p2ppnnp/2p5/2P1PP2/1PN1Q1P1/P1NRB2P/3R2K1 w - - 1 20", pcn: "e2f3")
    try doTestMovePcn(
      title: "2018-WCC: Re8",
      fen: "r5k1/1bqr1pp1/p2ppnnp/2p5/2P1PP2/1PN1QBP1/P1NR3P/3R2K1 b - - 2 20", pcn: "a8e8")
    try doTestMovePcn(
      title: "2018-WCC: Qf2",
      fen: "4r1k1/1bqr1pp1/p2ppnnp/2p5/2P1PP2/1PN1QBP1/P1NR3P/3R2K1 w - - 3 21", pcn: "e3f2")
    try doTestMovePcn(
      title: "2018-WCC: Ne7",
      fen: "4r1k1/1bqr1pp1/p2ppnnp/2p5/2P1PP2/1PN2BP1/P1NR1Q1P/3R2K1 b - - 4 21", pcn: "g6e7")
    try doTestMovePcn(
      title: "2018-WCC: h3",
      fen: "4r1k1/1bqrnpp1/p2ppn1p/2p5/2P1PP2/1PN2BP1/P1NR1Q1P/3R2K1 w - - 5 22", pcn: "h2h3")
    try doTestMovePcn(
      title: "2018-WCC: Red8",
      fen: "4r1k1/1bqrnpp1/p2ppn1p/2p5/2P1PP2/1PN2BPP/P1NR1Q2/3R2K1 b - - 0 22", pcn: "e8d8")
    try doTestMovePcn(
      title: "2018-WCC: Bg2",
      fen: "3r2k1/1bqrnpp1/p2ppn1p/2p5/2P1PP2/1PN2BPP/P1NR1Q2/3R2K1 w - - 1 23", pcn: "f3g2")
    try doTestMovePcn(
      title: "2018-WCC: Nc6",
      fen: "3r2k1/1bqrnpp1/p2ppn1p/2p5/2P1PP2/1PN3PP/P1NR1QB1/3R2K1 b - - 2 23", pcn: "e7c6")
    try doTestMovePcn(
      title: "2018-WCC: g4",
      fen: "3r2k1/1bqr1pp1/p1nppn1p/2p5/2P1PP2/1PN3PP/P1NR1QB1/3R2K1 w - - 3 24", pcn: "g3g4")
    try doTestMovePcn(
      title: "2018-WCC: Qa5",
      fen: "3r2k1/1bqr1pp1/p1nppn1p/2p5/2P1PPP1/1PN4P/P1NR1QB1/3R2K1 b - - 0 24", pcn: "c7a5")
    try doTestMovePcn(
      title: "2018-WCC: Na4",
      fen: "3r2k1/1b1r1pp1/p1nppn1p/q1p5/2P1PPP1/1PN4P/P1NR1QB1/3R2K1 w - - 1 25", pcn: "c3a4")
    try doTestMovePcn(
      title: "2018-WCC: Qc7",
      fen: "3r2k1/1b1r1pp1/p1nppn1p/q1p5/N1P1PPP1/1P5P/P1NR1QB1/3R2K1 b - - 2 25", pcn: "a5c7")
    try doTestMovePcn(
      title: "2018-WCC: e5",
      fen: "3r2k1/1bqr1pp1/p1nppn1p/2p5/N1P1PPP1/1P5P/P1NR1QB1/3R2K1 w - - 3 26", pcn: "e4e5")
    try doTestMovePcn(
      title: "2018-WCC: dxe5",
      fen: "3r2k1/1bqr1pp1/p1nppn1p/2p1P3/N1P2PP1/1P5P/P1NR1QB1/3R2K1 b - - 0 26", pcn: "d6e5")
    try doTestMovePcn(
      title: "2018-WCC: Nxc5",
      fen: "3r2k1/1bqr1pp1/p1n1pn1p/2p1p3/N1P2PP1/1P5P/P1NR1QB1/3R2K1 w - - 0 27", pcn: "a4c5")
    try doTestMovePcn(
      title: "2018-WCC: Rxd2",
      fen: "3r2k1/1bqr1pp1/p1n1pn1p/2N1p3/2P2PP1/1P5P/P1NR1QB1/3R2K1 b - - 0 27", pcn: "d7d2")
    try doTestMovePcn(
      title: "2018-WCC: Rxd2",
      fen: "3r2k1/1bq2pp1/p1n1pn1p/2N1p3/2P2PP1/1P5P/P1Nr1QB1/3R2K1 w - - 0 28", pcn: "d1d2")
    try doTestMovePcn(
      title: "2018-WCC: Rxd2",
      fen: "3r2k1/1bq2pp1/p1n1pn1p/2N1p3/2P2PP1/1P5P/P1NR1QB1/6K1 b - - 0 28", pcn: "d8d2")
    try doTestMovePcn(
      title: "2018-WCC: Qxd2",
      fen: "6k1/1bq2pp1/p1n1pn1p/2N1p3/2P2PP1/1P5P/P1Nr1QB1/6K1 w - - 0 29", pcn: "f2d2")
    try doTestMovePcn(
      title: "2018-WCC: Ba8", fen: "6k1/1bq2pp1/p1n1pn1p/2N1p3/2P2PP1/1P5P/P1NQ2B1/6K1 b - - 0 29",
      pcn: "b7a8")
    try doTestMovePcn(
      title: "2018-WCC: fxe5", fen: "b5k1/2q2pp1/p1n1pn1p/2N1p3/2P2PP1/1P5P/P1NQ2B1/6K1 w - - 1 30",
      pcn: "f4e5")
    try doTestMovePcn(
      title: "2018-WCC: Qxe5", fen: "b5k1/2q2pp1/p1n1pn1p/2N1P3/2P3P1/1P5P/P1NQ2B1/6K1 b - - 0 30",
      pcn: "c7e5")
    try doTestMovePcn(
      title: "2018-WCC: Nd7", fen: "b5k1/5pp1/p1n1pn1p/2N1q3/2P3P1/1P5P/P1NQ2B1/6K1 w - - 0 31",
      pcn: "c5d7")
    try doTestMovePcn(
      title: "2018-WCC: Qb2", fen: "b5k1/3N1pp1/p1n1pn1p/4q3/2P3P1/1P5P/P1NQ2B1/6K1 b - - 1 31",
      pcn: "e5b2")
    try doTestMovePcn(
      title: "2018-WCC: Qd6", fen: "b5k1/3N1pp1/p1n1pn1p/8/2P3P1/1P5P/PqNQ2B1/6K1 w - - 2 32",
      pcn: "d2d6")
    try doTestMovePcn(
      title: "2018-WCC: Nxd7", fen: "b5k1/3N1pp1/p1nQpn1p/8/2P3P1/1P5P/PqN3B1/6K1 b - - 3 32",
      pcn: "f6d7")
    try doTestMovePcn(
      title: "2018-WCC: Qxd7", fen: "b5k1/3n1pp1/p1nQp2p/8/2P3P1/1P5P/PqN3B1/6K1 w - - 0 33",
      pcn: "d6d7")
    try doTestMovePcn(
      title: "2018-WCC: Qxc2", fen: "b5k1/3Q1pp1/p1n1p2p/8/2P3P1/1P5P/PqN3B1/6K1 b - - 0 33",
      pcn: "b2c2")
    try doTestMovePcn(
      title: "2018-WCC: Qe8+", fen: "b5k1/3Q1pp1/p1n1p2p/8/2P3P1/1P5P/P1q3B1/6K1 w - - 0 34",
      pcn: "d7e8")
    try doTestMovePcn(
      title: "2018-WCC: Kh7", fen: "b3Q1k1/5pp1/p1n1p2p/8/2P3P1/1P5P/P1q3B1/6K1 b - - 1 34",
      pcn: "g8h7")
    try doTestMovePcn(
      title: "2018-WCC: Qxa8", fen: "b3Q3/5ppk/p1n1p2p/8/2P3P1/1P5P/P1q3B1/6K1 w - - 2 35",
      pcn: "e8a8")
    try doTestMovePcn(
      title: "2018-WCC: Qd1+", fen: "Q7/5ppk/p1n1p2p/8/2P3P1/1P5P/P1q3B1/6K1 b - - 0 35",
      pcn: "c2d1")
    try doTestMovePcn(
      title: "2018-WCC: Kh2", fen: "Q7/5ppk/p1n1p2p/8/2P3P1/1P5P/P5B1/3q2K1 w - - 1 36", pcn: "g1h2"
    )
    try doTestMovePcn(
      title: "2018-WCC: Qd6+", fen: "Q7/5ppk/p1n1p2p/8/2P3P1/1P5P/P5BK/3q4 b - - 2 36", pcn: "d1d6")
    try doTestMovePcn(
      title: "2018-WCC: Kh1", fen: "Q7/5ppk/p1nqp2p/8/2P3P1/1P5P/P5BK/8 w - - 3 37", pcn: "h2h1")
    try doTestMovePcn(
      title: "2018-WCC: Nd4", fen: "Q7/5ppk/p1nqp2p/8/2P3P1/1P5P/P5B1/7K b - - 4 37", pcn: "c6d4")
    try doTestMovePcn(
      title: "2018-WCC: Qe4+", fen: "Q7/5ppk/p2qp2p/8/2Pn2P1/1P5P/P5B1/7K w - - 5 38", pcn: "a8e4")
    try doTestMovePcn(
      title: "2018-WCC: f5", fen: "8/5ppk/p2qp2p/8/2PnQ1P1/1P5P/P5B1/7K b - - 6 38", pcn: "f7f5")
    try doTestMovePcn(
      title: "2018-WCC: gxf5", fen: "8/6pk/p2qp2p/5p2/2PnQ1P1/1P5P/P5B1/7K w - - 0 39", pcn: "g4f5")
    try doTestMovePcn(
      title: "2018-WCC: exf5", fen: "8/6pk/p2qp2p/5P2/2PnQ3/1P5P/P5B1/7K b - - 0 39", pcn: "e6f5")
    try doTestMovePcn(
      title: "2018-WCC: Qe3", fen: "8/6pk/p2q3p/5p2/2PnQ3/1P5P/P5B1/7K w - - 0 40", pcn: "e4e3")
    try doTestMovePcn(
      title: "2018-WCC: Ne6", fen: "8/6pk/p2q3p/5p2/2Pn4/1P2Q2P/P5B1/7K b - - 1 40", pcn: "d4e6")
    try doTestMovePcn(
      title: "2018-WCC: b4", fen: "8/6pk/p2qn2p/5p2/2P5/1P2Q2P/P5B1/7K w - - 2 41", pcn: "b3b4")
    try doTestMovePcn(
      title: "2018-WCC: Ng5", fen: "8/6pk/p2qn2p/5p2/1PP5/4Q2P/P5B1/7K b - - 0 41", pcn: "e6g5")
    try doTestMovePcn(
      title: "2018-WCC: c5", fen: "8/6pk/p2q3p/5pn1/1PP5/4Q2P/P5B1/7K w - - 1 42", pcn: "c4c5")
    try doTestMovePcn(
      title: "2018-WCC: Qf6", fen: "8/6pk/p2q3p/2P2pn1/1P6/4Q2P/P5B1/7K b - - 0 42", pcn: "d6f6")
    try doTestMovePcn(
      title: "2018-WCC: c6", fen: "8/6pk/p4q1p/2P2pn1/1P6/4Q2P/P5B1/7K w - - 1 43", pcn: "c5c6")
    try doTestMovePcn(
      title: "2018-WCC: Ne6", fen: "8/6pk/p1P2q1p/5pn1/1P6/4Q2P/P5B1/7K b - - 0 43", pcn: "g5e6")
    try doTestMovePcn(
      title: "2018-WCC: a4", fen: "8/6pk/p1P1nq1p/5p2/1P6/4Q2P/P5B1/7K w - - 1 44", pcn: "a2a4")
    try doTestMovePcn(
      title: "2018-WCC: Nc7", fen: "8/6pk/p1P1nq1p/5p2/PP6/4Q2P/6B1/7K b - - 0 44", pcn: "e6c7")
    try doTestMovePcn(
      title: "2018-WCC: Qf4", fen: "8/2n3pk/p1P2q1p/5p2/PP6/4Q2P/6B1/7K w - - 1 45", pcn: "e3f4")
    try doTestMovePcn(
      title: "2018-WCC: Ne6", fen: "8/2n3pk/p1P2q1p/5p2/PP3Q2/7P/6B1/7K b - - 2 45", pcn: "c7e6")
    try doTestMovePcn(
      title: "2018-WCC: Qd6", fen: "8/6pk/p1P1nq1p/5p2/PP3Q2/7P/6B1/7K w - - 3 46", pcn: "f4d6")
  }

  func testSan() throws {
    let chess = Chess()

    let pawnMove = try chess.move(
      move:
        MoveRequest(
          from: Square.e2,
          to: Square.e4,
          promotion: nil
        ))

    XCTAssertEqual(pawnMove.san, "e4", "king's pawn opening")

    chess.load(fen: "rnbqkbnr/ppppp1pp/5p2/6P1/8/8/PPPPPP1P/RNBQKBNR w KQkq - 0 1")
    let pawnCapture = try chess.move(
      move:
        MoveRequest(
          from: Square.g5,
          to: Square.f6,
          promotion: nil
        ))

    XCTAssertEqual(pawnCapture.san, "gxf6", "pawn capture on f6")

    chess.load(fen: "rnbqkbnr/ppp1p1pp/5p2/6P1/8/8/PPP1PP1P/RNBQKBNR b KQkq - 0 1")
    let queenCapture = try chess.move(
      move:
        MoveRequest(
          from: Square.d8,
          to: Square.d1,
          promotion: nil
        ))

    XCTAssertEqual(queenCapture.san, "Qxd1+", "queen capture on d1")

    chess.load(fen: "r3k3/8/4K3/8/8/8/8/R7 w - - 0 1")
    let rookCheckmate = try chess.move(
      move:
        MoveRequest(
          from: Square.a1,
          to: Square.a8,
          promotion: nil
        ))

    XCTAssertEqual(rookCheckmate.san, "Rxa8#", "capture checkmate")

    chess.load(fen: "rnbqkbnr/ppp1p1pp/5p2/6P1/8/5NB1/PPP1PP1P/RNBQK2R w KQkq - 0 1")
    let ksideCastling = try chess.move(
      move:
        MoveRequest(
          from: Square.e1,
          to: Square.g1,
          promotion: nil
        ))

    XCTAssertEqual(ksideCastling.san, "O-O", "kingside castling")

    chess.load(fen: "r3kbnr/p2bp2p/1pnq1pp1/2p3P1/8/2N1QNB1/PPPBPP1P/R3K2R w KQkq - 0 1")
    let qsideCastling = try chess.move(
      move:
        MoveRequest(
          from: Square.e1,
          to: Square.c1,
          promotion: nil
        ))

    XCTAssertEqual(qsideCastling.san, "O-O-O", "queenside castling")

    chess.load(fen: "1K2k2r/8/8/1n6/8/5b2/8/8 b k - 0 1")
    let castleIntoCheckmate = try chess.move(
      move:
        MoveRequest(
          from: Square.e8,
          to: Square.g8,
          promotion: nil
        ))

    XCTAssertEqual(castleIntoCheckmate.san, "O-O#", "kingside castle checkmate")
  }

  func testThreefoldRepetition() throws {
    let startFen = "2rr2k1/1p2qpp1/4n2p/p2p4/N1nN4/P3PP2/1P3QPP/3RR1K1 b - - 0 1"
    let moveList = [
      "Qf6",
      "Nb5",
      "Nc7",
      "Nd4",
      "Ne6",
      "Nb5",
      "Nc7",
      "Nd4",
      "Ne6",
    ]
    let chess = Chess(fen: startFen)
    for move in moveList {
      let _ = try chess.move(san: move)
    }
    XCTAssertTrue(
      chess.isThreefoldRepetition(), "Nepo vs. Ding Game 3 FIDE World Championship 2023")
    XCTAssertTrue(chess.isDraw())

    chess.load(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    let euweMoves = [
      "Nc3",
      "Nc6",
      "Nb1",
      "Nb8",
      "Nf3",
      "Nf6",
      "Ng1",
      "Ng8",
    ]
    for move in euweMoves {
      let _ = try chess.move(san: move)
    }
    XCTAssertTrue(
      chess.isThreefoldRepetition(), "Prouhet Thue Morse sequence results in draw")
    XCTAssertTrue(chess.isDraw())

    chess.load(fen: "8/pp3p1k/2p2q1p/3r1P2/5R2/7P/P1P1QP2/7K b - - 2 30")
    let _ = try chess.move(san: "Qe5")
    let _ = try chess.move(san: "Qh5")
    let _ = try chess.move(san: "Qf6")
    let _ = try chess.move(san: "Qe2")
    let _ = try chess.move(san: "Re5")
    let _ = try chess.move(san: "Qd3")
    let _ = try chess.move(san: "Rd5")
    let _ = try chess.move(san: "Qe2")

    XCTAssertTrue(chess.isThreefoldRepetition(), "Fischer - Petrosian, Buenos Aires, 1971")
  }

  func testCastleSan() throws {
    let fenBlack = "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R b KQkq - 0 1"
    let fenWhite = "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
    let chess = Chess(fen: fenWhite)

    let kingsideWhite = try chess.move(san: "O-O")
    XCTAssertEqual(kingsideWhite.pcn, "e1g1", "castling kingside")

    chess.reset()

    chess.load(fen: fenWhite)
    let queensideWhite = try chess.move(san: "O-O-O")
    XCTAssertEqual(queensideWhite.pcn, "e1c1", "castling queenside")

    chess.reset()

    chess.load(fen: fenBlack)
    let kingsideBlack = try chess.move(san: "O-O")
    XCTAssertEqual(kingsideBlack.pcn, "e8g8", "castling kingside")

    chess.reset()

    chess.load(fen: fenBlack)
    let queensideBlack = try chess.move(san: "O-O-O")
    XCTAssertEqual(queensideBlack.pcn, "e8c8", "castling queenside")
  }

  func testMarkEnPassantSquare() throws {
    let fen = "rnbqkbnr/pppp1ppp/4p3/3P4/8/8/PPP1PPPP/RNBQKBNR b KQkq - 0 1"
    let chess = Chess(fen: fen)
    let _ = try chess.move(san: "c5")
    XCTAssertEqual(chess.getEnPassantSquare(), Square.c6, "ep target was updated")
  }

  func testPromotion() throws {
    let fen = "4k3/1P6/8/8/8/8/8/4K3 w - - 0 1"
    let chess = Chess(fen: fen)
    let sanMove = try chess.move(san: "b8=R")
    XCTAssertEqual(sanMove.pcn, "b7b8r", "pawn promotes to rook")

    chess.reset()

    chess.load(fen: fen)
    let pcnMove = try chess.move(pcn: "b7b8b")
    XCTAssertEqual(pcnMove.pcn, "b7b8b", "pawn promotes to bishop")

    chess.load(fen: "8/7k/3p1p1p/7P/5P2/8/4pK2/5N2 b - - 1 49")
    let capturePromotion = try chess.move(san: "exf1=Q")
    XCTAssertEqual(capturePromotion.pcn, "e2f1q", "pawn captures and promotes to queen")
  }

  func testAmbiguousMoves() throws {
    let chess = Chess()

    chess.load(
      fen: "r1bqkbnr/ppp2ppp/2n5/1B1pP3/4P3/8/PPPP2PP/RNBQK1NR b KQkq - 2 4")
    let knightMove = try chess.move(san: "Ne7")
    XCTAssertEqual(
      knightMove.details.from, Square.g8, "moves the right knight since knight on c6 is pinned")
    XCTAssertEqual(knightMove.san, "Ne7")

    chess.load(
      fen: "r1bqkbnr/ppp2ppp/2n5/3pP3/4P3/8/PPPP2PP/RNBQKBNR b KQkq - 0 1")
    let knightMove2 = try chess.move(san: "Nge7")
    XCTAssertEqual(knightMove2.details.from, Square.g8, "disambiguates on the file")
    XCTAssertEqual(knightMove2.san, "Nge7")

    chess.load(fen: "4k3/2n1n3/1n3n2/8/1n3n2/2n1n3/8/7K b - - 0 1")
    let knightChaos = try chess.move(san: "Ne7d5")
    XCTAssertEqual(knightChaos.details.from, Square.e7, "too many knights")
    XCTAssertEqual(knightChaos.san, "Ne7d5")

    chess.load(fen: "4k3/1b6/7P/8/8/1b6/8/4K3 b - - 0 1")
    let bishop = try chess.move(san: "B3d5")
    XCTAssertEqual(bishop.details.from, Square.b3, "disambiguate on the rank")
    XCTAssertEqual(bishop.san, "B3d5")
  }

  func testAmbiguousMovesQueen() throws {
    let chess = Chess()
    chess.load(fen: "r1b5/pp1kbQP1/2n1p3/3p4/6Q1/5K2/1pq2P2/5BNR w - - 2 20")
    let queen = try chess.move(san: "Qgxe6+")
    XCTAssertEqual(queen.details.from, Square.g4, "correct queen moves")
    XCTAssertTrue(chess.isCheck(), "king is in check now")
  }

  func testSanCaptures() throws {
    let fen = "rnbqkbnr/pppp1pp1/7p/4p3/3P4/5N2/PPP1PPPP/RNBQKB1R w KQkq - 0 4"
    let chess = Chess(fen: fen)
    let move = try chess.move(san: "Nxe5")
    XCTAssertEqual(move.details.piece.type, PieceType.knight, "knight capture")
    XCTAssertEqual(move.details.from, Square.f3, "knight capture from f3")
    XCTAssertEqual(move.details.to, Square.e5, "knight capture to e5")
  }

  func testSanCapturesWithPawn() throws {
    let fen = "rnbqkbnr/pppp1pp1/7p/4p3/3P4/5N2/PPP1PPPP/RNBQKB1R w KQkq - 0 4"
    let chess = Chess(fen: fen)
    let move = try chess.move(san: "dxe5")
    XCTAssertEqual(move.details.piece.type, PieceType.pawn, "pawn capture")
    XCTAssertEqual(move.details.from, Square.d4, "pawn capture from d4")
    XCTAssertEqual(move.details.to, Square.e5, "pawn capture to e5")

    let fen2 = "r1bq1rk1/pp4pp/2n1pn2/3pbp2/3P1P2/1P1B2P1/PBPN3P/R2Q1RK1 w - - 0 13"
    chess.load(fen: fen2)
    let move2 = try chess.move(san: "fxe5")
    XCTAssertEqual(move2.details.piece.type, PieceType.pawn, "pawn capture")
    XCTAssertEqual(move2.details.from, Square.f4, "pawn capture from f4")
    XCTAssertEqual(move2.details.to, Square.e5, "pawn capture to e5")
  }

  func testInsufficientMaterial() throws {
    let chess = Chess()

    chess.load(fen: "8/8/8/8/8/8/8/k6K w - - 0 1")
    XCTAssertTrue(chess.isInsufficientMaterial(), "K vs k")

    chess.load(fen: "8/2N5/8/8/8/8/8/k6K w - - 0 1")
    XCTAssertTrue(chess.isInsufficientMaterial(), "KN vs k")

    chess.load(fen: "8/2b5/8/8/8/8/8/k6K w - - 0 1")
    XCTAssertTrue(chess.isInsufficientMaterial(), "K vs kb")

    chess.load(fen: "8/b7/3B4/8/8/8/8/k6K w - - 0 1")
    XCTAssertTrue(chess.isInsufficientMaterial(), "KB vs Kb")

    chess.load(fen: "8/b1B1b1B1/1b1B1b1B/8/8/8/8/1k5K w - - 0 1")
    XCTAssertTrue(chess.isInsufficientMaterial(), "KBBBBB vs Kbb")

    chess.load(fen: "8/2p5/8/8/8/8/8/k6K w - - 0 1")
    XCTAssertFalse(chess.isInsufficientMaterial(), "pawn")

    chess.load(fen: "5k1K/7B/8/6b1/8/8/8/8 b - - 0 1")
    XCTAssertFalse(chess.isInsufficientMaterial(), "opposite colored bishops")

    chess.load(fen: "7K/5k1N/8/6b1/8/8/8/8 b - - 0 1")
    XCTAssertFalse(chess.isInsufficientMaterial(), "KN vs kb")

    chess.load(fen: "7K/5k1N/8/4n3/8/8/8/8 b - - 0 1")
    XCTAssertFalse(chess.isInsufficientMaterial(), "KN vs kn")

    chess.load(fen: "8/8/8/8/1b6/8/B1k5/K7 b - - 0 1")
    XCTAssertFalse(chess.isInsufficientMaterial(), "mate in 1: opposite colored bishops")

    chess.load(fen: "8/8/8/8/1n6/8/B7/K1k5 b - - 2 1")
    XCTAssertFalse(chess.isInsufficientMaterial(), "mate in 1: bishop vs knight")
  }

  func testStalemate() throws {
    let chess = Chess()
    chess.load(fen: "1R6/8/8/8/8/8/7R/k6K b - - 0 1")
    XCTAssertTrue(chess.isStalemate())

    chess.load(fen: "8/8/5k2/p4p1p/P4K1P/1r6/8/8 w - - 0 2")
    XCTAssertTrue(chess.isStalemate())

    chess.load(fen: "8/8/8/8/8/8/B1n5/K1k5 b - - 0 1")
    XCTAssertFalse(chess.isStalemate())
  }

  func testPawnMove() throws {
    let chess = Chess()
    chess.load(fen: "4k3/2pb1p2/1pp1nPr1/p5p1/7p/1P3P1P/PBP3P1/2NR2K1 b - - 4 33")
    let move = try chess.move(san: "c5")
    XCTAssertEqual(move.details.from, Square.c6, "cannot jump a pawn")
  }

  func testBadMoves() throws {
    let chess = Chess()

    XCTAssertThrowsError(
      try chess.move(move: MoveRequest(from: Square.d7, to: Square.d5, promotion: nil))
    ) { error in
      XCTAssertEqual(error as! MoveError, MoveError.notYourTurn)
    }

    chess.load(fen: "rnbqkbnr/pppp1ppp/8/8/8/8/PPPPQPPP/RNB1KBNR b KQkq - 0 1")

    XCTAssertNoThrow(
      try chess.move(move: MoveRequest(from: Square.f8, to: Square.e7, promotion: nil))
    )
  }

  func testUndoMove() throws {
    let startFen = "r3kb1r/p2nqppp/5n2/1B2p1B1/4P3/1Q6/PPP2PPP/R3K2R w KQkq - 2 12"

    let chess = Chess()
    chess.load(fen: startFen)
    let _ = try chess.move(pcn: "e1c1")
    let _ = try chess.undoMove()

    XCTAssertEqual(chess.getTurn(), PieceColor.white, "white's turn again")
    XCTAssertEqual(chess.getEnPassantSquare(), nil, "ep square does not exist")

    let fen = chess.export(fen: true)
    XCTAssertEqual(fen, startFen, "fen is starting fen")

    XCTAssertNoThrow(
      try chess.move(pcn: "e1c1")
    )
  }

  // TODO draw tests

  // TODO isLegalMove test
}
