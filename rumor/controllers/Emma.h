#import <Foundation/Foundation.h>
#include "lua.h"
#include "lauxlib.h"
#import "UKKQueue.h"

@interface Emma : NSObject <UKFileWatcher> {
@public
  lua_State *L;
  UKKQueue *kqueue;
}

- (void)start;
- (void)startUpLua;
@end
