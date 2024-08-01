import Foundation
import MyMacro
import _Concurrency



Task {
    do {
        try await networkManager.perform(route: AppAPI.Community.configurations)
    } catch {
        
    }
}

CFRunLoopRun()
