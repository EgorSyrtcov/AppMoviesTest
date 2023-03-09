import Foundation
import RealmSwift

class MovieRealmModel: Object {
    @objc dynamic var adult: Bool = false
    @objc dynamic var backdropPath: String?
    @objc dynamic var id: Int = 0
    @objc dynamic var originalTitle: String = ""
    @objc dynamic var overview: String = ""
    @objc dynamic var popularity: Double = 0.0
    @objc dynamic var posterPath: String?
    @objc dynamic var releaseDate: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var video: Bool = false
    @objc dynamic var voteAverage: Double = 0.0
    @objc dynamic var voteCount: Int = 0
    @objc dynamic var poster: String = ""
    @objc dynamic var genre: String = ""
    
    convenience init(from movie: Movie) {
        self.init()
        adult = movie.adult
        backdropPath = movie.backdropPath
        id = movie.id
        originalTitle = movie.originalTitle
        overview = movie.overview
        popularity = movie.popularity
        posterPath = movie.posterPath
        releaseDate = movie.releaseDate
        title = movie.title
        video = movie.video
        voteAverage = movie.voteAverage
        voteCount = movie.voteCount
        poster = movie.poster
        genre = movie.genre
    }
}

extension Results {
    func toArray() -> [Element] {
      return compactMap {
        $0
      }
    }
 }
