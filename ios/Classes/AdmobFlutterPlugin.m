#import "AdmobFlutterPlugin.h"
#import <admob_flutter/admob_flutter-Swift.h>

@implementation AdmobFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAdmobFlutterPlugin registerWithRegistrar:registrar];
}
@end
