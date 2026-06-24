#import <Foundation/Foundation.h>
#include "RNNSWindow.h"
#include <ReactCommon/CxxTurboModuleUtils.h>

@interface RNNSWindowLoader : NSObject
@end

@implementation RNNSWindowLoader

+ (void)load {
  facebook::react::registerCxxModuleToGlobalModuleMap(
      "NSWindowModule",
      [](std::shared_ptr<facebook::react::CallInvoker> jsInvoker) {
        return std::make_shared<facebook::react::RNNSWindow>(
            std::move(jsInvoker));
      });
}

@end
