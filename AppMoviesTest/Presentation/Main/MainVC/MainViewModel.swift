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
    var didPullToRefreshSubject: PassthroughSubject<Void, Never> { get }
    var scrollLoadingMoreSubject: PassthroughSubject<Void, Never> { get }
    var searchTextSubject: PassthroughSubject<String?, Never> { get set }
}

protocol MainViewModelOutput {
    var updateCategoryPublisher: AnyPublisher<Section, Never> { get }
    var updatePopularMoviesPublisher: AnyPublisher<[Movie], Never> { get }
    var updateUncomingMoviesPublisher: AnyPublisher<[Movie], Never> { get }
    var searchMoviesPublisher: AnyPublisher<[Movie], Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<(title: String?, subtitle: String?), Never> { get }
}

typealias MainViewModel = MainViewModelInput & MainViewModelOutput

final class MainViewModelImpl: MainViewModel {
    
    // MARK: - Private Properties
    
    private var routing: MainViewModelRouting
    private var cancellables: Set<AnyCancellable> = []
    private let service = Service()
    
    // MARK: - Private Subjects
    
    private let sectionSubject = CurrentValueSubject<Section, Never>(.popular)
    private let popularMoviesSubject = CurrentValueSubject<[Movie], Never>([])
    private let upcomingMoviesSubject = PassthroughSubject<[Movie], Never>()
    private let errorSubject = CurrentValueSubject<(title: String?, subtitle: String?), Never>((title: nil, subtitle: nil))
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private var popularMoviesTemp = [Movie]()
    private var upcomingMoviesTemp = [Movie]()
    private var genresTemp = [Genre]()
    private var maxPopularPage = 1
    private var maxUpcomingPage = 1
    private var currentPopularPage = 1
    private var currentUpcomingPage = 1
    
    // MARK: - LoginViewModelInput
    
    var filterButtonDidTapSubject = PassthroughSubject<Section, Never>()
    var didPullToRefreshSubject = PassthroughSubject<Void, Never>()
    var scrollLoadingMoreSubject = PassthroughSubject<Void, Never>()
    var searchTextSubject = PassthroughSubject<String?, Never>()
    
    // MARK: - LoginViewModelOutput
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    var updateCategoryPublisher: AnyPublisher<Section, Never> {
        sectionSubject
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    var updatePopularMoviesPublisher: AnyPublisher<[Movie], Never> {
        popularMoviesSubject
            .map { movies in
                movies.map { self.genreMovie(movie: $0)}
            }
            .eraseToAnyPublisher()
    }
    
    var updateUncomingMoviesPublisher: AnyPublisher<[Movie], Never> {
        upcomingMoviesSubject
            .map { movies in
                movies.map { self.genreMovie(movie: $0)}
            }
            .eraseToAnyPublisher()
    }
    
    var searchMoviesPublisher: AnyPublisher<[Movie], Never> {
        
        switch self.sectionSubject.value {
        case .upcoming:
            return searchTextSubject
                .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
                .removeDuplicates()
                .flatMap { searchText -> AnyPublisher<[Movie], Never> in
                    if let searchText = searchText, !searchText.isEmpty {
                        return self.upcomingMoviesSubject
                            .map { movies in
                                return movies.filter { movie in
                                    return movie.title.lowercased().contains(searchText.lowercased())
                                }
                            }
                            .eraseToAnyPublisher()
                    } else {
                        return self.upcomingMoviesSubject
                            .eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
            
        case .popular:
            return searchTextSubject
                .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
                .removeDuplicates()
                .flatMap { searchText -> AnyPublisher<[Movie], Never> in
                    if let searchText = searchText, !searchText.isEmpty {
                        return self.popularMoviesSubject
                            .map { movies in
                                return movies.filter { movie in
                                    return movie.title.lowercased().contains(searchText.lowercased())
                                }
                            }
                            .eraseToAnyPublisher()
                    } else {
                        return self.popularMoviesSubject
                            .eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        }
    }
    
    var errorPublisher: AnyPublisher<(title: String?, subtitle: String?), Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(routing: MainViewModelRouting) {
        self.routing = routing
        configureBindings()
        
        Task {
            try? await requestMovies(page: currentPopularPage)
        }
    }
    
    private func configureBindings() {
        
        filterButtonDidTapSubject
            .sink { [weak self] sectionType in
                guard let self = self else { return }
                self.sectionSubject.send(sectionType)
                
                Task {
                    try? await self.requestUncomingMovies(page: self.currentUpcomingPage)
                }
            }
            .store(in: &cancellables)
        
        didPullToRefreshSubject
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                switch self.sectionSubject.value {
                case .popular:
                    self.currentPopularPage = 1
                    self.popularMoviesTemp = []
                    self.popularMoviesSubject.send([])
                    
                    Task {
                        try? await self.requestMovies(page: self.currentPopularPage)
                    }
                case .upcoming:
                    self.currentUpcomingPage = 1
                    self.upcomingMoviesTemp = []
                    self.upcomingMoviesSubject.send([])
                    
                    Task {
                        try? await self.requestUncomingMovies(page: self.currentUpcomingPage)
                    }
                }
            }
            .store(in: &cancellables)
        
        scrollLoadingMoreSubject
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                switch self.sectionSubject.value {
                case .popular:
                    
                    guard self.currentPopularPage >= self.maxPopularPage else { return }
                    self.currentPopularPage+=1
                    
                    Task {
                        try? await self.requestMovies(page: self.currentPopularPage)
                    }
                case .upcoming:
                    guard self.currentUpcomingPage >= self.maxUpcomingPage else { return }
                    self.currentUpcomingPage+=1
                    
                    Task {
                        try? await self.requestUncomingMovies(page: self.currentUpcomingPage)
                    }
                }
                
            }
            .store(in: &cancellables)
    }
    
    private func requestMovies(page: Int) async throws {
        
        isLoadingSubject.send(true)
        
        let genre: GenreModel?
        let movie: MovieModel?
        
        do {
            genre = try await service.execute(.getGenreMovieRequest(), expecting: GenreModel.self)
        }
        catch {
            errorSubject.send((title: error.localizedDescription, subtitle: "Try again"))
            isLoadingSubject.send(false)
            return
        }
        
        do {
            movie = try await service.execute(.getPopularMovieRequest(pageNumber: page), expecting: MovieModel.self)
        }
        catch {
            isLoadingSubject.send(false)
            errorSubject.send((title: error.localizedDescription, subtitle: "Try again"))
            return
        }
        
        await MainActor.run { [weak self] in
            self?.maxPopularPage = movie?.page ?? 1
            self?.genresTemp = genre?.genres.compactMap { $0 } ?? []
            self?.popularMoviesTemp.append(contentsOf: movie?.movies ?? [])
            self?.popularMoviesSubject.send(popularMoviesTemp)
            isLoadingSubject.send(false)
        }
    }
    
    private func genreMovie(movie: Movie) -> Movie {
        
        let genresName = Array(Set(movie.genreIDS.compactMap { genre in
            genresTemp.first { $0.id == genre }?.name
        })).joined(separator: ", ")
        
        return Movie(adult: movie.adult, backdropPath: movie.backdropPath, genreIDS: movie.genreIDS, id: movie.id, originalTitle: movie.originalTitle, overview: movie.overview, popularity: movie.popularity, posterPath: movie.posterPath, releaseDate: movie.releaseDate, title: movie.title, video: movie.video, voteAverage: movie.voteAverage, voteCount: movie.voteCount, genre: genresName)
    }
    
    private func requestUncomingMovies(page: Int) async throws {
        
        isLoadingSubject.send(true)
        
        let upcomingMovie: MovieModel?
        
        do {
            upcomingMovie = try await service.execute(.getUpcomingMovieRequest(pageNumber: currentUpcomingPage), expecting: MovieModel.self)
        }
        catch {
            isLoadingSubject.send(false)
            errorSubject.send((title: error.localizedDescription, subtitle: "Try again"))
            return
        }
        
        await MainActor.run { [weak self] in
            self?.maxUpcomingPage = upcomingMovie?.page ?? 1
            self?.upcomingMoviesTemp.append(contentsOf: upcomingMovie?.movies ?? [])
            self?.upcomingMoviesSubject.send(upcomingMoviesTemp)
            isLoadingSubject.send(false)
        }
    }
    
}
