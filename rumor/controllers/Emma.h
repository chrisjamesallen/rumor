#import <Foundation/Foundation.h>
#include "lua.h"
#include "lauxlib.h"
#include "luagl.h"
#import "UKKQueue.h"

extern lua_State *L;

@interface Emma : NSObject <UKFileWatcher> {
  @public    
    UKKQueue *kqueue;
}

- (void)start;
- (void)startUpLua;
@end
extern void emma_update( lua_State * L );
extern void emma_draw( lua_State * L );
 