//
//  HomeTests.swift
//  CryptoTests
//
//  Created by Rilwanul Huda on 22/07/21.
//

@testable import Crypto

import Mockingbird
import XCTest

class HomeTests: CryptoTests {
    var homeManagerMock: HomeManagerMock!
    var wsServiceMock: WSServiceMock!
    var sut: HomeViewModel!
    var expectedErrorMsg: String!
    var expectedIndexPath: IndexPath!
    var successGetTopList: Bool!
    var successLoadMoreTopList: Bool!
    
    override func setUp() {
        super.setUp()
        homeManagerMock = mock(HomeManager.self).initialize(networkService: networkServiceMock)
        wsServiceMock = mock(WSService.self).initialize()
        sut = HomeViewModel(manager: homeManagerMock, wsService: wsServiceMock)
        sut.delegate = self
    }
    
    override func tearDown() {
        successLoadMoreTopList = nil
        successGetTopList = nil
        expectedErrorMsg = nil
        expectedIndexPath = nil
        homeManagerMock = nil
        sut = nil
        super.tearDown()
    }
    
    func testGetTopListSuccessResponse() {
        let mockSuccessResponse = mockResponse(of: TopListResponseModel.self, filename: .topListSuccessResponse)
        
        given(homeManagerMock.getTopList(model: any(), completion: any())) ~> {
            _, result in
            result(.success(mockSuccessResponse!))
        }
        
        sut.getTopList()
        
        verify(homeManagerMock.getTopList(model: any(), completion: any())).wasCalled()
        
        XCTAssertEqual(sut.topListCoins.count, mockSuccessResponse?.data?.count)
        XCTAssertFalse(sut.topListCoins.isEmpty)
        
        for i in 0..<sut.topListCoins.count {
            let sutCoin = sut.topListCoins[i]
            let expectedCoin = mockSuccessResponse!.data![i]
            
            XCTAssertEqual(sutCoin.id, expectedCoin.coinInfo?.id)
            XCTAssertEqual(sutCoin.symbol, expectedCoin.coinInfo?.name)
            XCTAssertEqual(sutCoin.fullname, expectedCoin.coinInfo?.fullname)
            
            if let usd = expectedCoin.display?.usd {
                let change24HourUSD = usd.change24Hour ?? ""
                let change24Hour = change24HourUSD.replacingOccurrences(of: "$ ", with: "")
                let pctChange24Hour = usd.pctChange24Hour ?? ""
                
                if !change24Hour.contains("-") {
                    let expectedChanges = "+\(change24Hour)(+\(pctChange24Hour)%)"
                    XCTAssertEqual(sutCoin.changes, expectedChanges)
                } else {
                    let expectedChanges = "\(change24Hour)(\(pctChange24Hour)%)"
                    XCTAssertEqual(sutCoin.changes, expectedChanges)
                }
                
                XCTAssertEqual(sutCoin.price, expectedCoin.display?.usd?.price)
                
                let expectedOpenPrice = expectedCoin.display?.usd?.open24Hour?.replacingOccurrences(of: "$ ", with: "")
                XCTAssertEqual(sutCoin.openPrice, Double(expectedOpenPrice ?? "0"))
            } else {
                XCTAssertEqual(sutCoin.price, "n/a")
                XCTAssertEqual(sutCoin.changes, "n/a")
                XCTAssertNil(sutCoin.openPrice)
            }
        }
        
        XCTAssertEqual(successGetTopList, true)
    }
    
    func testGetTopListSuccessResponseNoData() {
        let mockSuccessResponse = mockResponse(of: TopListResponseModel.self, filename: .topListSuccessResponseNoData)
        
        given(homeManagerMock.getTopList(model: any(), completion: any())) ~> {
            _, result in
            result(.success(mockSuccessResponse!))
        }
        
        sut.getTopList()
        
        verify(homeManagerMock.getTopList(model: any(), completion: any())).wasCalled()
        
        XCTAssertEqual(sut.topListCoins.count, mockSuccessResponse?.data?.count)
        XCTAssertTrue(sut.topListCoins.isEmpty)
        XCTAssertEqual(expectedErrorMsg, Messages.noCoinsFound)
    }
    
    func testGetTopListFailed() {
        let errorMsg = Messages.generalError
        
        given(homeManagerMock.getTopList(model: any(), completion: any())) ~> {
            _, result in
            result(.failure(errorMsg))
        }
        
        sut.getTopList()
        
        verify(homeManagerMock.getTopList(model: any(), completion: any())).wasCalled()
        
        XCTAssertEqual(expectedErrorMsg, errorMsg)
        XCTAssertTrue(sut.topListCoins.isEmpty)
    }
    
    func testLoadMoreTopListSuccessResponse() {
        let mockSuccessResponse = mockResponse(of: TopListResponseModel.self, filename: .topListSuccessResponse)
        let mockPageTwoSuccessResponse = mockResponse(of: TopListResponseModel.self, filename: .topListPageTwoSuccessResponse)
        let mockPageThreeSuccessResponse = mockResponse(of: TopListResponseModel.self, filename: .topListPageThreeSuccessResponse)
        var expectedAllCoins: [TopListData] = []
        
        // Initial load page 1
        given(homeManagerMock.getTopList(model: any(), completion: any())) ~> {
            _, result in
            result(.success(mockSuccessResponse!))
        }
        
        sut.getTopList()
        expectedAllCoins += mockSuccessResponse!.data!
        
        verify(homeManagerMock.getTopList(model: any(), completion: any())).wasCalled()
        
        XCTAssertEqual(sut.topListCoins.count, expectedAllCoins.count)
        XCTAssertFalse(sut.topListCoins.isEmpty)
        
        // Start load more page 2
        given(homeManagerMock.getTopList(model: any(), completion: any())) ~> {
            _, result in
            result(.success(mockPageTwoSuccessResponse!))
        }
        
        sut.loadMoreTopList()
        expectedAllCoins += mockPageTwoSuccessResponse!.data!
        
        XCTAssertEqual(sut.page, 2)
        XCTAssertEqual(sut.topListCoins.count, expectedAllCoins.count)
        XCTAssertFalse(sut.topListCoins.isEmpty)
        
        // Start load more page 3
        given(homeManagerMock.getTopList(model: any(), completion: any())) ~> {
            _, result in
            result(.success(mockPageThreeSuccessResponse!))
        }
        
        sut.loadMoreTopList()
        expectedAllCoins += mockPageThreeSuccessResponse!.data!
        
        XCTAssertEqual(sut.page, 3)
        XCTAssertEqual(sut.topListCoins.count, expectedAllCoins.count)
        XCTAssertFalse(sut.topListCoins.isEmpty)
        
        for i in 0..<sut.topListCoins.count {
            let sutCoin = sut.topListCoins[i]
            let expectedCoin = expectedAllCoins[i]
            
            XCTAssertEqual(sutCoin.id, expectedCoin.coinInfo?.id)
            XCTAssertEqual(sutCoin.symbol, expectedCoin.coinInfo?.name)
            XCTAssertEqual(sutCoin.fullname, expectedCoin.coinInfo?.fullname)
            
            if let usd = expectedCoin.display?.usd {
                let change24HourUSD = usd.change24Hour ?? ""
                let change24Hour = change24HourUSD.replacingOccurrences(of: "$ ", with: "")
                let pctChange24Hour = usd.pctChange24Hour ?? ""
                
                if !change24Hour.contains("-") {
                    let expectedChanges = "+\(change24Hour)(+\(pctChange24Hour)%)"
                    XCTAssertEqual(sutCoin.changes, expectedChanges)
                } else {
                    let expectedChanges = "\(change24Hour)(\(pctChange24Hour)%)"
                    XCTAssertEqual(sutCoin.changes, expectedChanges)
                }
                
                XCTAssertEqual(sutCoin.price, expectedCoin.display?.usd?.price)
            } else {
                XCTAssertEqual(sutCoin.price, "n/a")
                XCTAssertEqual(sutCoin.changes, "n/a")
            }
        }
        
        XCTAssertEqual(successLoadMoreTopList, true)
    }
    
    func testLoadMoreTopListFailed() {
        let errorMsg = Messages.generalError
        let mockSuccessResponse = mockResponse(of: TopListResponseModel.self, filename: .topListSuccessResponse)
        
        // Initial load page 1
        given(homeManagerMock.getTopList(model: any(), completion: any())) ~> {
            _, result in
            result(.success(mockSuccessResponse!))
        }
        
        sut.getTopList()
        
        verify(homeManagerMock.getTopList(model: any(), completion: any())).wasCalled()
        
        XCTAssertEqual(sut.topListCoins.count, mockSuccessResponse?.data?.count)
        XCTAssertFalse(sut.topListCoins.isEmpty)
        
        // Start load more page 2
        let currentTopListCount = sut.topListCoins.count
        
        given(homeManagerMock.getTopList(model: any(), completion: any())) ~> {
            _, result in
            result(.failure(errorMsg))
        }
        
        sut.loadMoreTopList()
        
        verify(homeManagerMock.getTopList(model: any(), completion: any())).wasCalled(2)
        
        XCTAssertEqual(sut.page, 2)
        XCTAssertEqual(expectedErrorMsg, errorMsg)
        XCTAssertEqual(sut.topListCoins.count, currentTopListCount)
    }
    
    func testTickerResponse() {
        let mockSuccessResponse = mockResponse(of: TopListResponseModel.self, filename: .topListSuccessResponse)
        
        given(homeManagerMock.getTopList(model: any(), completion: any())) ~> {
            _, result in
            result(.success(mockSuccessResponse!))
        }
        
        sut.getTopList()
        
        verify(homeManagerMock.getTopList(model: any(), completion: any())).wasCalled()
        
        XCTAssertEqual(sut.topListCoins.count, mockSuccessResponse?.data?.count)
        XCTAssertFalse(sut.topListCoins.isEmpty)
        
        let symbol = "TRX"
        let updatedPrice = 0.07798
        let tickerResponse = TickerResponseModel(symbol: symbol, price: updatedPrice)
        sut.didReceiveTickerResponse(response: tickerResponse)
        
        for coin in sut.topListCoins {
            if coin.symbol == symbol {
                XCTAssertEqual(coin.price, "$ \(updatedPrice)")
                return
            }
        }
    }
    
    func testCouldLoadMore() {
        // test could load more true
        sut.currentCoinsCount = 20
        sut.coinsCount = 40
        
        XCTAssertEqual(sut.couldLoadMore(), true)
        
        // test could load more false
        sut.currentCoinsCount = 40
        sut.coinsCount = 40
        
        XCTAssertEqual(sut.couldLoadMore(), false)
    }
    
    func testDidUpdateConnectionStatus() {
        _ = given(wsServiceMock.sendSubscription(action: any(), subscriptions: any()))
        
        sut.didUpdateConnectionStatus(isConnected: true)
        
        verify(wsServiceMock.sendSubscription(action: any(), subscriptions: any())).wasCalled()
    }
}

extension HomeTests: HomeViewModelDelegate {
    func didSuccessGetTopList() {
        successGetTopList = true
    }
    
    func didFailGetTopList(errorMsg: String) {
        expectedErrorMsg = errorMsg
    }
    
    func didSuccessLoadMoreTopList() {
        successLoadMoreTopList = true
    }
    
    func didFailLoadMoreTopList(errorMsg: String) {
        expectedErrorMsg = errorMsg
    }
    
    func refreshCoin(at indexPath: IndexPath) {
        expectedIndexPath = indexPath
    }
}
