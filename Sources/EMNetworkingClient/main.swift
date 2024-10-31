import _Concurrency
import Foundation
import EMNetworking

Task {
    do {
        let req = LoginReq(
            languageID: 1
        )
        
        let res: LoginRes? = try await networkManager.perform(route: AppAPI.Community.login(req))
        
        print("Response \(String(describing: res))")
    } catch {}
}

CFRunLoopRun()


