import 'package:flutter/material.dart';
import 'dart:io' show Platform;

enum DeviceType {
  mobile,  // 모바일
  tablet,  // 태블릿
  desktop, // 노트북/데스크톱
}

enum DeviceOrientation {
  portrait,  // 세로
  landscape, // 가로
}

class DeviceTypeDetector {
  /// 현재 기기의 타입을 반환합니다.
  /// 
  /// [context] - BuildContext (MediaQuery 접근용)
  /// 
  /// 반환값:
  /// - [DeviceType.mobile]: 화면 너비 < 600px
  /// - [DeviceType.tablet]: 화면 너비 600px ~ 1024px
  /// - [DeviceType.desktop]: 화면 너비 > 1024px
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1024) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// 현재 기기가 모바일인지 확인합니다.
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 현재 기기가 태블릿인지 확인합니다.
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// 현재 기기가 데스크톱/노트북인지 확인합니다.
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// 플랫폼 정보를 기반으로 기본 기기 타입을 추정합니다.
  /// 
  /// 주의: 이 메서드는 플랫폼 정보만 사용하므로 정확도가 낮을 수 있습니다.
  /// 가능하면 [getDeviceType]을 사용하는 것을 권장합니다.
  static DeviceType getDeviceTypeFromPlatform() {
    if (Platform.isAndroid || Platform.isIOS) {
      // Android/iOS는 모바일 또는 태블릿일 수 있으므로
      // 화면 크기 정보가 필요합니다.
      // 하지만 플랫폼만으로는 정확히 판단할 수 없으므로
      // 기본값으로 mobile을 반환합니다.
      return DeviceType.mobile;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return DeviceType.desktop;
    }
    return DeviceType.desktop;
  }

  /// 기기 타입에 따른 이름을 반환합니다.
  static String getDeviceTypeName(DeviceType type) {
    switch (type) {
      case DeviceType.mobile:
        return '모바일';
      case DeviceType.tablet:
        return '태블릿';
      case DeviceType.desktop:
        return '데스크톱';
    }
  }

  /// 현재 기기의 방향을 반환합니다.
  /// 
  /// [context] - BuildContext (MediaQuery 접근용)
  /// 
  /// 반환값:
  /// - [DeviceOrientation.portrait]: 세로 방향 (높이 > 너비)
  /// - [DeviceOrientation.landscape]: 가로 방향 (너비 > 높이)
  static DeviceOrientation getDeviceOrientation(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    
    // MediaQuery의 orientation 사용
    if (orientation == Orientation.portrait) {
      return DeviceOrientation.portrait;
    } else {
      return DeviceOrientation.landscape;
    }
  }

  /// 현재 기기가 세로 방향인지 확인합니다.
  static bool isPortrait(BuildContext context) {
    return getDeviceOrientation(context) == DeviceOrientation.portrait;
  }

  /// 현재 기기가 가로 방향인지 확인합니다.
  static bool isLandscape(BuildContext context) {
    return getDeviceOrientation(context) == DeviceOrientation.landscape;
  }

  /// 디바이스 방향에 따른 이름을 반환합니다.
  static String getDeviceOrientationName(DeviceOrientation orientation) {
    switch (orientation) {
      case DeviceOrientation.portrait:
        return '세로';
      case DeviceOrientation.landscape:
        return '가로';
    }
  }
}

