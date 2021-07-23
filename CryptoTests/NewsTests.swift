//
//  NewsTests.swift
//  CryptoTests
//
//  Created by Rilwanul Huda on 22/07/21.
//

@testable import Crypto

import Mockingbird
import XCTest

//class NewsTests: CryptoTests {
//    var newsManagerMock: NewsManagerMock!
//    var interactor: NewsInteractor!
//    var sut: NewsPresenter!
//    
//    override func setUp() {
//        super.setUp()
//        newsManagerMock = mock(NewsManager.self).initialize(networkService: networkServiceMock)
//        sut = NewsPresenter(view: nil)
//        interactor = NewsInteractor(presenter: sut, manager: newsManagerMock)
//    }
//    
//    override func tearDown() {
//        newsManagerMock = nil
//        interactor = nil
//        sut = nil
//        super.tearDown()
//    }
//    
//    func testGetNewsSuccessResponse() {
//        let mockSuccessResponse = mockResponse(of: NewsResponseModel.self, filename: .newsSuccessResponse)
//        
//        given(newsManagerMock.getNews(model: any(), completion: any())) ~> {
//            _, result in
//            result(.success(mockSuccessResponse!))
//        }
//        
//        interactor.getNews()
//        
//        verify(newsManagerMock.getNews(model: any(), completion: any())).wasCalled()
//        
//        XCTAssertEqual(sut.news.count, mockSuccessResponse?.data?.count)
//        XCTAssertFalse(sut.news.isEmpty)
//        
//        for i in 0..<sut.news.count {
//            let sutNews = sut.news[i]
//            let expectedNews = mockSuccessResponse!.data![i]
//            
//            if let title = expectedNews.title {
//                XCTAssertEqual(sutNews.title, title)
//            } else {
//                XCTAssertEqual(sutNews.title, "n/a")
//            }
//            
//            if let body = expectedNews.body {
//                XCTAssertEqual(sutNews.body, body)
//            } else {
//                XCTAssertEqual(sutNews.body, "n/a")
//            }
//            
//            if let source = expectedNews.sourceInfo?.name {
//                XCTAssertEqual(sutNews.source, source)
//            } else {
//                XCTAssertEqual(sutNews.source, "n/a")
//            }
//        }
//    }
//    
//    func testGetNewsSuccessResponseNoData() {
//        let mockSuccessResponse = mockResponse(of: NewsResponseModel.self, filename: .newsSuccessResponseNoData)
//        
//        given(newsManagerMock.getNews(model: any(), completion: any())) ~> {
//            _, result in
//            result(.success(mockSuccessResponse!))
//        }
//        
//        interactor.getNews()
//        
//        verify(newsManagerMock.getNews(model: any(), completion: any())).wasCalled()
//        
//        XCTAssertEqual(sut.news.count, mockSuccessResponse?.data?.count)
//        XCTAssertTrue(sut.news.isEmpty)
//        XCTAssertEqual(sut.errorMsg, Messages.noNewsFound)
//    }
//    
//    func testGetNewsFailed() {
//        let expectedErrorMsg = Messages.generalError
//        
//        given(newsManagerMock.getNews(model: any(), completion: any())) ~> {
//            _, result in
//            result(.failure(expectedErrorMsg))
//        }
//        
//        interactor.getNews()
//        
//        verify(newsManagerMock.getNews(model: any(), completion: any())).wasCalled()
//        
//        XCTAssertTrue(sut.news.isEmpty)
//        XCTAssertEqual(sut.errorMsg, expectedErrorMsg)
//    }
//}
