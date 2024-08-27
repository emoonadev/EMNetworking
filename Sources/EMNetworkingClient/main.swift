import _Concurrency
import Foundation
import EMNetworking

Task {
    do {
        let emailLookup = EmailLookupReq(auth: "mickael@tinytap.com")
        
        let loginRes: Int? = try await networkManager.perform(route: AppAPI.Account.emailLookup(dto: emailLookup))
        
        
        print(loginRes)
    } catch {}
}

CFRunLoopRun()
