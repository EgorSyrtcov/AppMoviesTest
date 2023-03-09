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
}

typealias DetailViewModel = DetailViewModelInput & DetailViewModelOutput

final class DetailViewModelImpl: DetailViewModel {
    
    // MARK: - Private Properties
    
    private var routing: DetailViewModelRouting
    private var cancellables: Set<AnyCancellable> = []
    private var movie: Movie
    
    // MARK: - Private Subjects
    private let movieDataSubject = CurrentValueSubject<Movie?, Never>(nil)
    
    // MARK: - LoginViewModelInput
    
    var didTapLikeSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - DetailViewModelOutput
    var movieDataPublisher: AnyPublisher<Movie?, Never> {
        movieDataSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    
    init(routing: DetailViewModelRouting, movie: Movie) {
        self.routing = routing
        self.movie = movie
        self.movieDataSubject.send(movie)
        configureBindings()
    }
    
    private func configureBindings() {
        
    }
}
