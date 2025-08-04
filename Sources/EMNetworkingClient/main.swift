import _Concurrency
import Foundation
import EMNetworking

Task {
    do {
        let res: Int? = try await networkManager.perform(route: AppAPI.Account.emailLookup(dto: .init(auth: "assafluz+7878@gmail.com")))
//
        print("Response \(String(describing: res))")
    } catch {}
}

CFRunLoopRun()


