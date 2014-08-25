#import <Foundation/Foundation.h>
#include "lua.h"
#include "lauxlib.h"
#include "luagl.h"
#import "UKKQueue.h"
#import "EmmaGLView.h"
#import "emma_mat4.h"
#import "emma_vec3.h"

// Globals
BOOL fucked;
extern lua_State *L;
extern void emma_update( lua_State *L, double delta, int64_t time );
extern void emma_draw( lua_State *L );


@interface Emma : NSObject <UKFileWatcher> {
  @public
    UKKQueue *kqueue;
    NSURL *scriptURL;
    EmmaGLView *view;
}
- (void)start;
- (void)startUpLua;
@end
