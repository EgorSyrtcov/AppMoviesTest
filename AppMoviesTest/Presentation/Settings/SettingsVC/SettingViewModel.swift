import UIKit
import Combine

struct SettingsViewModelRouting {
   
}

protocol SettingsViewModelInput {
   
}

protocol SettingsViewModelOutput {
   
}

typealias SettingsViewModel = SettingsViewModelInput & SettingsViewModelOutput

final class SettingsViewModelImpl: SettingsViewModel {
    
    // MARK: - Private Properties
    
    private var routing: SettingsViewModelRouting
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Private Subjects
    
    private let errorSubject = PassthroughSubject<(title: String?, subtitle: String?), Never>()
    
    // MARK: - LoginViewModelInput
    

    // MARK: - LoginViewModelOutput

    
    // MARK: - Initialization
    
    init(routing: SettingsViewModelRouting) {
        self.routing = routing
        configureBindings()
    }
    
    private func configureBindings() {
        
    }
    
}


