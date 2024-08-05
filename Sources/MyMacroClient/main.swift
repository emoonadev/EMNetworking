import Foundation
import MyMacro
import _Concurrency



Task {
    do {
        let loginReq = LoginReq(auth: "mickaelmacro@tt.it", password: "123456", kidNickName: "nickname", languageID: 1, ageGroupID: 2)
//        try await networkManager.perform(route: AppAPI.Community.configurations)
        try await networkManager.perform(route: AppAPI.User.login(loginReq))
    } catch {
        
    }
}

CFRunLoopRun()
