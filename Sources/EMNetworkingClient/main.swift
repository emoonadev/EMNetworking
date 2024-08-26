import _Concurrency
import Foundation
import EMNetworking

Task {
    do {
        let loginReq = LoginReq(
            auth: "mickaelmacro@tt.it",
            password: "123456",
            kidNickName: "nickname",
            languageID: 1,
            ageGroupID: 2
        )
        
        let loginRes: LoginRes? = try await networkManager.perform(route: AppAPI.User.login(loginReq))
        
        
        print(loginRes?.subAccounts)
    } catch {}
}

CFRunLoopRun()
