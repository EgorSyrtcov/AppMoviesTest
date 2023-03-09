import UIKit
import Combine

struct FavoritesViewModelRouting {
   
}

protocol FavoritesViewModelInput {
    var updateRealmModelsSubject: PassthroughSubject<Void, Never> { get }
    var deleteRealmModelSubject: PassthroughSubject<MovieRealmModel, Never> { get }
}

protocol FavoritesViewModelOutput {
    var updateMoviesFromRealmPublisher: AnyPublisher<[MovieRealmModel], Never> { get }
}

typealias FavoritesViewModel = FavoritesViewModelInput & FavoritesViewModelOutput

final class FavoritesViewModelImpl: FavoritesViewModel {
    
    // MARK: - Private Properties
    
    private let realmService = RealmService()
    private var routing: FavoritesViewModelRouting
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Private Subjects
    
    var getMovieModelsRealmBaseSubject = PassthroughSubject<[MovieRealmModel], Never>()
    
    // MARK: - FavoritesViewModelInput
    
    let updateRealmModelsSubject = PassthroughSubject<Void, Never>()
    let deleteRealmModelSubject = PassthroughSubject<MovieRealmModel, Never>()
    
    // MARK: - FavoritesViewModelOutput

    var updateMoviesFromRealmPublisher: AnyPublisher<[MovieRealmModel], Never> {
        getMovieModelsRealmBaseSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(routing: FavoritesViewModelRouting) {
        self.routing = routing
        configureBindings()
    }
    
    private func configureBindings() {
        
        updateRealmModelsSubject
            .sink { [weak self] _ in
                let movieModels = self?.realmService.getAllWords().toArray()
                self?.getMovieModelsRealmBaseSubject.send(movieModels ?? [])
            }
            .store(in: &cancellables)
        
        deleteRealmModelSubject
            .sink { [weak self] movie in
                self?.realmService.delete(movie: movie)
                let movieModels = self?.realmService.getAllWords().toArray()
                self?.getMovieModelsRealmBaseSubject.send(movieModels ?? [])
            }
            .store(in: &cancellables)
    }
    
}
