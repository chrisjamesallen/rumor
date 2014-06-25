#import <Foundation/Foundation.h>
#include "lua.h"
#include "lauxlib.h"
#include "luagl.h"
#import "UKKQueue.h"
#import "AppGLView.h"
#import "emma_math.h"

extern lua_State *L;

@interface Emma : NSObject <UKFileWatcher> {
  @public    
    UKKQueue *kqueue;
    NSURL *scriptURL;
    AppGLView * view;
}

- (void)start;
- (void)startUpLua;
@end
extern void emma_update( lua_State * L, double delta, int64_t time);
extern void emma_draw( lua_State * L );
