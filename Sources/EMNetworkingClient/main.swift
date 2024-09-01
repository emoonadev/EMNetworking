import _Concurrency
import Foundation
import EMNetworking

Task {
    do {
        let req = LoginReq(
            auth: "mickael@tinytap.com",
            password: "capoeifgcbfvra",
            kidNickName: "nickname",
            languageID: 1,
            ageGroupID: 2,
            userType: 1
        )
        
        let res: LoginRes? = try await networkManager.perform(route: AppAPI.Community.login(req))
        
        print(res)
    } catch {}
}

CFRunLoopRun()


