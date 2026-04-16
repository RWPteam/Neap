<p align="center">
  <h1 align="center"> <code>local_auth</code> </h1>
</p>


本项目基于 [local_auth@2.2.0](https://pub.dev/packages/local_auth/versions/2.2.0) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 `pubspec.yaml` 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
dependencies:
  local_auth:
    git:
      url: https://gitcode.com/openharmony-tpc/flutter_packages.git
      path: packages/local_auth/local_auth
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [ohos/example](./example)

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

### 2.2 权限要求

由于本插件需求 `ohos.permission.ACCESS_BIOMETRIC` 权限实现功能，需要申请权限。

####  2.2.1 在 entry 目录下的module.json5中添加权限

打开 `entry/src/main/module.json5`，添加：

```diff
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.ACCESS_BIOMETRIC",
        "reason": "$string:EntryAbility_accessBiometricReason",
        "usedScene": {
          "abilities": [
            "EntryAbility"
          ],
          "when": "inuse"
        }
      }
    ]
  }
}
```

#### 2.2.2 在 entry 目录下添加申请以上权限的原因

打开 `entry/src/main/resources/base/element/string.json`，添加：

```diff
{
  "string": [
    {
      "name": "EntryAbility_accessBiometricReason",
      "value": "Verify User"
    }
  ]
}
```

## 3. API

> [!TIP] “**ohos Support**”列为 **yes** 表示 ohos 平台支持该属性；**no** 表示不支持；**partially** 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

| Name                     | Return                      | Description                    | Type     | ohos Support |
| ------------------------ | --------------------------- | ------------------------------ | -------- | ------------ |
| deviceSupportsBiometrics | Future<bool>                | 检查是否支持生物识别硬件       | function | yes          |
| isDeviceSupported        | Future<bool>                | 检查是否支持本地认证           | function | yes          |
| getEnrolledBiometrics    | Future<List<BiometricType>> | 获取设备上已注册的生物识别类型 | function | yes          |
| authenticate             | Future<bool>                | 执行身份验证                   | function | yes          |
| stopAuthentication       | Future<bool>                | 取消当前认证                   | function | yes          |

## 4. 属性

> [!TIP] “**ohos Support**”列为 **yes** 表示 ohos 平台支持该属性；**no** 表示不支持；**partially** 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

### BiometricType

| Name        | Description | Type | ohos Support |
| ----------- | ----------- | ---- | ------------ |
| face        | 面容识别    | enum | yes          |
| fingerprint | 指纹识别    | enum | yes          |
| weak        | 弱生物识别  | enum | yes          |
| strong      | 强生物识别  | enum | yes          |

### AuthenticationOptions

| Name            | Description                  | Type | ohos Support |
| --------------- | ---------------------------- | ---- | ------------ |
| biometricOnly   | 是否仅使用生物识别           | bool | yes          |
| useErrorDialogs | 是否使用默认错误提示对话框   | bool | yes          |
| stickyAuth      | 应用退后台后是否维持认证状态 | bool | yes          |

## 5. 遗留问题

无

## 6. 其他

## 7. 开源协议

本项目基于 [BSD 3-Clause License](https://gitcode.com/openharmony-tpc/flutter_packages/blob/master/packages/local_auth/local_auth_ohos/LICENSE)，请自由地享受和参与开源。
