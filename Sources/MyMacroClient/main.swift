import _Concurrency
import Foundation
import MyMacro

Task {
    do {
        let loginReq = LoginReq(
            auth: "mickaelmacro@tt.it",
            password: "123456",
            kidNickName: "nickname",
            languageID: 1,
            ageGroupID: 2
        )
        
        let loginRes: LoginRes? = try await networkManager.perform(route: AppAPI.User.login(loginReq, queryItems: ["queryItem1": 123, "item2" : "value2"]))
        
        
        print(loginRes?.subAccounts)
    } catch {}
}

CFRunLoopRun()
