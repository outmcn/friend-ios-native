# Friend iOS Native

完全脱离 DCloud 的原生 iOS 客户端工程。

## 原项目

原 Uni-app 源码保留在：

```text
/opt/tanxiao/uni-app
```

本目录不修改原 Uni-app 源码。

## 当前目标

- Swift / SwiftUI + UIKit
- Bundle ID：`com.outmcn.Friend`
- API：`https://cp.outmcn.net/api/msfastcommunity`
- WebSocket：`wss://cp.outmcn.net/ws`
- 保留账号密码登录、注册、动态、关注、评论、视频匹配、语音/视频通话
- 通过 GitHub Actions 编译未签名 TrollStore IPA
- 不使用 DCloud AppID、AppKey、HBuilderX 或 DCloud iOS SDK

## 当前阶段

项目初始化阶段。先建立 API、认证、页面导航和数据模型，再接入腾讯云原生 SDK。
