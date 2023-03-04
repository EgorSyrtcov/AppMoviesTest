import UIKit
import Combine

struct FavoritesViewModelRouting {
   
}

protocol FavoritesViewModelInput {
   
}

protocol FavoritesViewModelOutput {
   
}

typealias FavoritesViewModel = FavoritesViewModelInput & FavoritesViewModelOutput

final class FavoritesViewModelImpl: FavoritesViewModel {
    
    // MARK: - Private Properties
    
    private var routing: FavoritesViewModelRouting
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Private Subjects
    
    private let errorSubject = PassthroughSubject<(title: String?, subtitle: String?), Never>()
    
    // MARK: - LoginViewModelInput
    
    // MARK: - LoginViewModelOutput

    // MARK: - Initialization
    
    init(routing: FavoritesViewModelRouting) {
        self.routing = routing
        configureBindings()
    }
    
    private func configureBindings() {
        
    }
    
}
