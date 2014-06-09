
#import "Emma.h"
#import "chris.h"
#import <OpenGL/OpenGL.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/CVDisplayLink.h>

const NSString *LUA_PATH = @"/Users/chrisallen/projects/desky/scripts/";
const NSString *LUA_MAIN = @"/Users/chrisallen/projects/desky/scripts/main.lua";


/*
static int gl_enable( lua_State *L );
static int gl_clearcolor( lua_State *L );
void loadLuaMetaTable( lua_State *L, const luaL_Reg *table, const char *name ) {
    luaL_newmetatable( L, name );
    lua_setfield( L, -1, "__index" );
    lua_newtable( L );
    luaL_setfuncs( L, table, 0 );
    lua_setglobal( L, name );
}

static int luagl_viewport(lua_State *L)
{
    
    return 0;
}

static const struct luaL_Reg gl[] = { { "blendMode", gl_enable },
                                      { "enable", gl_enable },
                                      { "disable", gl_enable },
                                      { "clearColor", gl_clearcolor },
                                      { "Viewport", luagl_viewport },
                                      { NULL, NULL } };

static int gl_enable( lua_State *L ) {
    // get string

    // set on gl enable...
    return 0;
}



static int gl_clearcolor( lua_State *L ) {
    // set on gl color...
    glClearColor( 1, 0, 0, 1 );
    glFlush();
    return 0;
}
 
 */


void emma_call( lua_State * L, int args, int returns ){
    if(lua_pcall(L,args,returns,0) !=0)
        printf("emma:error calling function %s", lua_tostring(L, -1) );
}

void emma_draw( lua_State * L ){
    lua_getglobal(L, "main");
    lua_getfield(L,-1,"draw");
    lua_pushvalue(L,-2);
    lua_remove(L,-3);
    emma_call(L,1,0);
    //todo push time delays here...
}

//init lua emma
void emma_init( lua_State * L ){
    lua_settop(L,0);
    lua_getglobal(L, "main");
    lua_getfield(L, -1, "init");
    lua_pushvalue(L, -2);
    stackDump(L);
    lua_remove(L,-3);
    stackDump(L);
    emma_call(L,1,0);
    lua_settop(L,0);
}


lua_State *L;

@implementation Emma {
    chris *shape;
}

- (id)init;
{
    self = [super init];
    if ( self != nil ) {
        shape = [[chris alloc] init];
    }
    return self;
}

- (void)start {
    [self setupLua];
    emma_init(L);
}

- (void)draw {
    [shape draw];
}

- (void)setupLua {
    [self setupFileWatcher];
    // create global lua state
    L = luaL_newstate();
    luaopen_luagl(L);
    // execute lua file
    [self executeLuaFile];
}

- (void)setupFileWatcher {

    // add watcher support
    kqueue = [UKKQueue sharedFileWatcher];

    // grab all lua files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *bundleURL = [[NSBundle mainBundle] resourceURL];
    NSURL *scriptURL = [NSURL URLWithString:@"scripts/emma/" relativeToURL:bundleURL];
    NSArray *contents =
        [fileManager contentsOfDirectoryAtURL:scriptURL
                   includingPropertiesForKeys:@[]
                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                        error:nil];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'lua'"];

    // add paths to file watcher object
    for ( NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate] ) {
        [kqueue addPath:[fileURL path]];
    }

    // add observer for when files are renamed or changed
    // check when renamed
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self
           selector:@selector( aFileHasBeenChanged )
               name:UKFileWatcherRenameNotification
             object:nil];
    // check when file is changed..
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self
           selector:@selector( aFileHasBeenChanged )
               name:UKFileWatcherWriteNotification
             object:nil];
}

- (void)executeLuaFile {
    const char *c = [LUA_MAIN cStringUsingEncoding:NSUTF8StringEncoding];
    if ( luaL_loadfile( L, c ) || lua_pcall( L, 0, 0, 0 ) ) {
        printf("cannot run lua :( %s", lua_tostring( L, -1 ) );
        //luaL_error( L, "cannot run lua :( %s", lua_tostring( L, -1 ) );
    }
}

- (void)aFileHasBeenChanged {
    NSLog( @"file watch!" );
    // TODO reload scripts here
}

@end