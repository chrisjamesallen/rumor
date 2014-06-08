
#import "Emma.h"
#import "chris.h"
#import <OpenGL/OpenGL.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/CVDisplayLink.h>

const NSString *LUA_PATH = @"/Users/chrisallen/projects/desky/scripts/";
const NSString *LUA_MAIN = @"/Users/chrisallen/projects/desky/scripts/main.lua";
static int gl_enable(lua_State *L);
static int gl_clearcolor(lua_State *L);
void loadLuaMetaTable(lua_State *L, const luaL_Reg *table, const char *name) {
  luaL_newmetatable(L, name);
  lua_setfield(L, -1, "__index");
  lua_newtable(L);
  luaL_setfuncs(L, table, 0);
  lua_setglobal(L, "gl");
}
static const struct luaL_Reg gl[] = {{"blendMode", gl_enable},
                                     {"enable", gl_enable},
                                     {"disable", gl_enable},
                                     {"clearColor", gl_clearcolor},
                                     {"flush", gl_enable},
                                     {NULL, NULL}};

static int gl_enable(lua_State *L) {
  // get string

  // set on gl enable...
  return 0;
}

static int gl_clearcolor(lua_State *L) {
  // get all four values

  // set on gl color...
  glClearColor(1, 1, 0, 1);
  glFlush();
  return 0;
}

@implementation Emma {
  chris *shape;
}

- (id)init;
{
  self = [super init];
  if (self != nil) {
    shape = [[chris alloc] init];
  }
  return self;
}

- (void)start {
  //
}

- (void)draw {
  [shape draw];
}

- (void)setupLua {
  [self setupFileWatcher];
  // create global lua state
  L = luaL_newstate();
  luaL_openlibs(L);
  loadLuaMetaTable(L, gl, "gl");
  // execute lua file
  [self executeLuaFile];
}

- (void)setupFileWatcher {

  // add watcher support
  kqueue = [UKKQueue sharedFileWatcher];
  [kqueue addPath:LUA_MAIN];
  // add observer for when files are renamed or changed
  // check when renamed
  [[[NSWorkspace sharedWorkspace] notificationCenter]
      addObserver:self
         selector:@selector(aFileHasBeenChanged)
             name:UKFileWatcherRenameNotification
           object:nil];
  // check when file is changed..
  [[[NSWorkspace sharedWorkspace] notificationCenter]
      addObserver:self
         selector:@selector(aFileHasBeenChanged)
             name:UKFileWatcherAttributeChangeNotification
           object:nil];
}

- (void)executeLuaFile {
  const char *c = [LUA_MAIN cStringUsingEncoding:NSUTF8StringEncoding];
  if (luaL_loadfile(L, c) || lua_pcall(L, 0, 0, 0)) {
    luaL_error(L, "cannot run lua :( %s", lua_tostring(L, -1));
  }
}

- (void)aFileHasBeenChanged {
  NSLog(@"file watch!");
  // TODO reload scripts here
}

@end