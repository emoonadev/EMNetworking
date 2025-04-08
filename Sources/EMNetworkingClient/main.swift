import _Concurrency
import Foundation
import EMNetworking

Task {
    do {
        let res: Int? = try await networkManager.perform(route: AppAPI.Community.log(header: .init(dictionaryLiteral: ("TESSSSSSSST", -1))))
        
        print("Response \(String(describing: res))")
    } catch {}
}

CFRunLoopRun()


