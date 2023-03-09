import UIKit
import Combine

struct DetailViewModelRouting {
    let backButtonDidTapSubject = PassthroughSubject<Void, Never>()
}

protocol DetailViewModelInput {
    var didTapLikeSubject: PassthroughSubject<Void, Never> { get }
}

protocol DetailViewModelOutput {
    var movieDataPublisher: AnyPublisher<Movie?, Never> { get }
    var showAlertSaveRealmBasePublisher: AnyPublisher<(title: String?, subtitle: String?), Never> { get }
}

typealias DetailViewModel = DetailViewModelInput & DetailViewModelOutput

final class DetailViewModelImpl: DetailViewModel {
    
    // MARK: - Private Properties
    
    private var routing: DetailViewModelRouting
    private let realmService = RealmService()
    private var cancellables: Set<AnyCancellable> = []
    private var movie: Movie
    
    // MARK: - Private Subjects
    private let movieDataSubject = CurrentValueSubject<Movie?, Never>(nil)
    private let alertSaveToRealmSubject = PassthroughSubject<(title: String?, subtitle: String?), Never>()
    
    // MARK: - LoginViewModelInput
    
    var didTapLikeSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - DetailViewModelOutput
    var movieDataPublisher: AnyPublisher<Movie?, Never> {
        movieDataSubject.eraseToAnyPublisher()
    }
    
    var showAlertSaveRealmBasePublisher: AnyPublisher<(title: String?, subtitle: String?), Never> {
        alertSaveToRealmSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    
    init(routing: DetailViewModelRouting, movie: Movie) {
        self.routing = routing
        self.movie = movie
        self.movieDataSubject.send(movie)
        configureBindings()
    }
    
    private func configureBindings() {
        didTapLikeSubject
            .sink { [weak self] in
                guard let movie = self?.movieDataSubject.value else { return }

                let movieRealmModel = MovieRealmModel(from: movie)
                
                // Check if the movie is already in the database
                let isMovieAlreadySaved = self?.realmService.getAllWords().contains(where: { $0.id == movie.id }) ?? false
                
                // Save the movie only if it's not already in the database
                if !isMovieAlreadySaved {
                    self?.realmService.save(movie: movieRealmModel)
                    self?.alertSaveToRealmSubject.send((title: "Great!", subtitle: "Your movie has been added to favorites"))
                } else {
                    self?.alertSaveToRealmSubject.send((title: "Error", subtitle: "Movie is already in the Favorites"))
                }
            }
            .store(in: &cancellables)
    }
}
