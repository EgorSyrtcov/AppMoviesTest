import UIKit
import Combine

enum Section: String {
        case popular = "Popular"
        case upcoming = "Upcoming"
    }

struct MainViewModelRouting {
   
}

protocol MainViewModelInput {
    var filterButtonDidTapSubject: PassthroughSubject<Section, Never> { get }
}

protocol MainViewModelOutput {
    var updateCategoryPublisher: AnyPublisher<Section, Never> { get }
}

typealias MainViewModel = MainViewModelInput & MainViewModelOutput

final class MainViewModelImpl: MainViewModel {
    
    // MARK: - Private Properties
    
    private var routing: MainViewModelRouting
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Private Subjects
    
    private let sectionSubject = PassthroughSubject<Section, Never>()
    private let popularMoviesSubject = PassthroughSubject<[Movie], Never>()
    private let upcomingMoviesSubject = PassthroughSubject<[Movie], Never>()
    private let errorSubject = PassthroughSubject<(title: String?, subtitle: String?), Never>()
    
    // MARK: - LoginViewModelInput
    
    var filterButtonDidTapSubject = PassthroughSubject<Section, Never>()
    
    // MARK: - LoginViewModelOutput
    
    var updateCategoryPublisher: AnyPublisher<Section, Never> {
        sectionSubject
            .map { $0 }
            .eraseToAnyPublisher()
    }

    // MARK: - Initialization
    
    init(routing: MainViewModelRouting) {
        self.routing = routing
        configureBindings()
    }
    
    private func configureBindings() {
        filterButtonDidTapSubject
            .sink { [weak self] sectionType in
                self?.sectionSubject.send(sectionType)
            }
            .store(in: &cancellables)
    }
    
}
