import Foundation
import RealmSwift

final class RealmService {

    private var realm: Realm {
        do {
            return try Realm()
        } catch {
            fatalError("Failed to create Realm instance: \(error)")
        }
    }

    func save(movie: MovieRealmModel) {
        do {
            try realm.write {
                realm.add(movie)
            }
        } catch {
            fatalError("Failed to save movie: \(error)")
        }
    }

    func getAllWords() -> Results<MovieRealmModel> {
        return realm.objects(MovieRealmModel.self)
    }

    func delete(movie: MovieRealmModel) {
        do {
            try realm.write {
                realm.delete(movie)
            }
        } catch {
            fatalError("Failed to delete movie: \(error)")
        }
    }

    func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            fatalError("Failed to delete all movies: \(error)")
        }
    }
}
