<p align="center">
  <h1 align="center"> <code>local_auth</code> </h1>
</p>


This project is developed based on [local_auth@2.2.0](https://pub.dev/packages/local_auth/versions/2.2.0).

## 1. Installation and Usage

### 1.1 Installation

Enter the project directory and add the following dependency in `pubspec.yaml`:

<!-- tabs:start -->

#### pubspec.yaml

```yaml
dependencies:
  local_auth:
    git:
      url: https://gitcode.com/openharmony-tpc/flutter_packages.git
      path: packages/local_auth/local_auth
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usag

For use cases [ohos/example](./example)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;
2. Flutter: 3.22.1-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

### 2.2 **Permission Requirements**

Since this plugin relies on the `ohos.permission.ACCESS_BIOMETRIC` permission to function properly, it is necessary to request this permission.

####  2.2.1 **Add permissions to the module.json5 file in the entry directory.**

Open  `entry/src/main/module.json5` and add the following information:

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

#### 2.2.2 **Add the reason for applying for the preceding permission to the entry directory.**

Open  `entry/src/main/resources/base/element/string.json` and add the following information:

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

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### LocalAuthentication API

| Name                     | Return                      | Description                                      | Type     | ohos Support |
| ------------------------ | --------------------------- | ------------------------------------------------ | -------- | ------------ |
| deviceSupportsBiometrics | Future<bool>                | Check if biometric hardware is supported         | function | yes          |
| isDeviceSupported        | Future<bool>                | Check if local authentication is supported       | function | yes          |
| getEnrolledBiometrics    | Future<List<BiometricType>> | Get the types of biometrics registered on device | function | yes          |
| authenticate             | Future<bool>                | Perform authentication                           | function | yes          |
| stopAuthentication       | Future<bool>                | Cancel current authentication                    | function | yes          |

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### BiometricType

| Name        | Description      | Type | ohos Support |
| ----------- | ---------------- | ---- | ------------ |
| face        | Face recognition | enum | yes          |
| fingerprint | Fingerprint      | enum | yes          |
| weak        | Weak biometric   | enum | yes          |
| strong      | Strong biometric | enum | yes          |

### AuthenticationOptions

| Name            | Description                                               | Type | ohos Support |
| --------------- | --------------------------------------------------------- | ---- | ------------ |
| biometricOnly   | Whether to use biometrics only                            | bool | yes          |
| useErrorDialogs | Whether to use default error dialog boxes                 | bool | yes          |
| stickyAuth      | Whether to maintain auth status after app goes background | bool | yes          |

## 5. Known Issues

None

## 6. Others

## 7. License

This project is licensed under [BSD 3-Clause License](https://gitcode.com/openharmony-tpc/flutter_packages/blob/master/packages/local_auth/local_auth_ohos/LICENSE), please feel free to enjoy and participate in open source.
