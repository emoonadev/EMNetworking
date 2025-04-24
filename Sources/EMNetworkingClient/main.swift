import _Concurrency
import Foundation
import EMNetworking

Task {
    do {
        let res: Int? = try await networkManager.perform(route: AppAPI.Account.register(.init(email: "sdafadfdfc@tt.it", password: "edsfdweasd", userType: 1)))
//
        print("Response \(String(describing: res))")
    } catch {}
}

CFRunLoopRun()


