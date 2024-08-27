import _Concurrency
import Foundation
import EMNetworking

Task {
    do {
        let emailLookup = EmailLookupReq(auth: "mickael@tinytap.com")
        
        let loginRes: LoginRes? = try await networkManager.perform(route: AppAPI.Account.emailLookup(dto: emailLookup))
        
        
        print(loginRes?.subAccounts)
    } catch {}
}

CFRunLoopRun()
