//
//  NewsTests.swift
//  CryptoTests
//
//  Created by Rilwanul Huda on 22/07/21.
//

@testable import Crypto

import Mockingbird
import XCTest

class NewsTests: CryptoTests {
    var newsManagerMock: NewsManagerMock!
    var sut: NewsViewModel!
    var successGetNews: Bool!
    var expectedErrorMsg: String!
    
    override func setUp() {
        super.setUp()
        newsManagerMock = mock(NewsManager.self).initialize(networkService: networkServiceMock)
        sut = NewsViewModel(manager: newsManagerMock)
        sut.delegate = self
    }
    
    override func tearDown() {
        newsManagerMock = nil
        sut = nil
        super.tearDown()
    }
    
    func testGetNewsSuccessResponse() {
        let mockSuccessResponse = mockResponse(of: NewsResponseModel.self, filename: .newsSuccessResponse)
        
        given(newsManagerMock.getNews(model: any(), completion: any())) ~> {
            _, result in
            result(.success(mockSuccessResponse!))
        }
        
        sut.getNews()
        
        verify(newsManagerMock.getNews(model: any(), completion: any())).wasCalled()
        
        XCTAssertEqual(sut.news.count, mockSuccessResponse?.data?.count)
        XCTAssertFalse(sut.news.isEmpty)
        
        for i in 0 ..< sut.news.count {
            let sutNews = sut.news[i]
            let expectedNews = mockSuccessResponse!.data![i]
            
            if let title = expectedNews.title {
                XCTAssertEqual(sutNews.title, title)
            } else {
                XCTAssertEqual(sutNews.title, "n/a")
            }
            
            if let body = expectedNews.body {
                XCTAssertEqual(sutNews.body, body)
            } else {
                XCTAssertEqual(sutNews.body, "n/a")
            }
            
            if let source = expectedNews.sourceInfo?.name {
                XCTAssertEqual(sutNews.source, source)
            } else {
                XCTAssertEqual(sutNews.source, "n/a")
            }
        }
        
        XCTAssertEqual(successGetNews, true)
    }
    
    func testGetNewsSuccessResponseNoData() {
        let errorMsg = Messages.noNewsFound
        let mockSuccessResponse = mockResponse(of: NewsResponseModel.self, filename: .newsSuccessResponseNoData)
        
        given(newsManagerMock.getNews(model: any(), completion: any())) ~> {
            _, result in
            result(.success(mockSuccessResponse!))
        }
        
        sut.getNews()
        
        verify(newsManagerMock.getNews(model: any(), completion: any())).wasCalled()
        
        XCTAssertEqual(sut.news.count, mockSuccessResponse?.data?.count)
        XCTAssertTrue(sut.news.isEmpty)
        XCTAssertEqual(expectedErrorMsg, errorMsg)
    }
    
    func testGetNewsFailed() {
        let errorMsg = Messages.generalError
        
        given(newsManagerMock.getNews(model: any(), completion: any())) ~> {
            _, result in
            result(.failure(errorMsg))
        }
        
        sut.getNews()
        
        verify(newsManagerMock.getNews(model: any(), completion: any())).wasCalled()
        
        XCTAssertTrue(sut.news.isEmpty)
        XCTAssertEqual(expectedErrorMsg, errorMsg)
    }
}

extension NewsTests: NewsViewModelDelegate {
    func didSuccessGetNews() {
        successGetNews = true
    }
    
    func didFailGetNews(errorMsg: String) {
        expectedErrorMsg = errorMsg
    }
}
