import Foundation

enum Endpoint: String {
    case getPopularMovie = "api.themoviedb.org/3/movie/popular"
    case getGenre = "api.themoviedb.org/3/genre/movie/list"
    case getUpcomingMovie = "api.themoviedb.org/3/movie/upcoming"
}
