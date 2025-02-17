//
//  HashtagTimelineViewModel.swift
//  Mastodon
//
//  Created by BradGao on 2021/3/30.
//

import os.log
import UIKit
import Combine
import CoreData
import CoreDataStack
import GameplayKit
import MastodonSDK
    
final class HashtagTimelineViewModel {
    
    let logger = Logger(subsystem: "HashtagTimelineViewModel", category: "ViewModel")
    
    let hashtag: String
    
    var disposeBag = Set<AnyCancellable>()
    
    var needLoadMiddleIndex: Int? = nil
    
    // input
    let context: AppContext
    let fetchedResultsController: StatusFetchedResultsController
    let isFetchingLatestTimeline = CurrentValueSubject<Bool, Never>(false)
    let timelinePredicate = CurrentValueSubject<NSPredicate?, Never>(nil)
    let hashtagEntity = CurrentValueSubject<Mastodon.Entity.Tag?, Never>(nil)
    let listBatchFetchViewModel = ListBatchFetchViewModel()
    
    // output
    var diffableDataSource: UITableViewDiffableDataSource<StatusSection, StatusItem>?
    let didLoadLatest = PassthroughSubject<Void, Never>()

    // bottom loader
    private(set) lazy var stateMachine: GKStateMachine = {
        // exclude timeline middle fetcher state
        let stateMachine = GKStateMachine(states: [
            State.Initial(viewModel: self),
            State.Reloading(viewModel: self),
            State.Fail(viewModel: self),
            State.Idle(viewModel: self),
            State.Loading(viewModel: self),
            State.NoMore(viewModel: self),
        ])
        stateMachine.enter(State.Initial.self)
        return stateMachine
    }()
    lazy var loadOldestStateMachinePublisher = CurrentValueSubject<State?, Never>(nil)
    
    init(context: AppContext, hashtag: String) {
        self.context  = context
        self.hashtag = hashtag
        self.fetchedResultsController = StatusFetchedResultsController(
            managedObjectContext: context.managedObjectContext,
            domain: nil,
            additionalTweetPredicate: nil
        )
        // end init
        
        context.authenticationService.activeMastodonAuthenticationBox
            .map { $0?.domain }
            .assign(to: \.value, on: fetchedResultsController.domain)
            .store(in: &disposeBag)
    }
    
    deinit {
        os_log(.info, log: .debug, "%{public}s[%{public}ld], %{public}s:", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

