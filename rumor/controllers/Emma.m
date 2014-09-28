#import <OpenGL/OpenGL.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/CVDisplayLink.h>
#include <time.h>

#import "Emma.h"
#import "emma_vec3.h"
#import "lgpc.h"
#include "lualib.h"

/* : Constants
=================================================== */
const NSString *LUA_PATH = @"/Users/chrisallen/projects/desky/";
const NSString *LUA_MAIN = @"/Users/chrisallen/projects/desky/scripts/main.lua";
const NSString *LUA_APP = @"/Users/chrisallen/projects/desky/scripts/emma/app.lua";
int emma_test( lua_State *L );
CGRect frame;
struct appS {
    BOOL pressed;
    BOOL dragged;
} AppState;

/* : Emma Library
=================================================== */
static int emma_gc( lua_State *L ) {
    stackDump( L );
    puts( "__gc called" );
    return 0;
}

void emma_call( lua_State *L, int args, int returns ) {
    if ( lua_pcall( L, args, returns, 0 ) != 0 ) {
        fucked = true;
        printf( "emma:error calling function %s\n", lua_tostring( L, -1 ) );
    }
}

static const struct luaL_Reg emma[] = { { "delete", emma_gc },
                                        { "__gc", emma_gc },
                                        { NULL, NULL } };

static int emma_new( lua_State *L ) {
    lua_getglobal( L, "newObject" );
    emma_call( L, 0, 0 );
    return 1;
}

void emma_update( lua_State *L, double delta, int64_t time ) {
    lua_plock( L, "" );
    lua_getglobal( L, "update" );
    lua_pushnumber( L, (long)delta );
    lua_pushnumber( L, (long)time );
    emma_call( L, 2, 0 );
    lua_punlock( L, "" );
}

void emma_draw( lua_State *L ) {
    lua_getglobal( L, "draw" );
    emma_call( L, 0, 0 );
}

void emma_reload( lua_State *L ) {
    lua_getglobal( L, "reload" );
    emma_call( L, 0, 0 );
    FLUSHING = NO;
}

void emma_destroy( lua_State *L ) {
    lua_getglobal( L, "destroy" );
    emma_call( L, 0, 0 );
}

/* : System Library
=================================================== */

static int systemTime( lua_State *L ) {
    clock_t clock_t;
    clock_t = clock();
    lua_pushnumber( L, clock_t );
    return 1;
}
static int systemScreen( lua_State *L ) {
    // NSRect frame = [[NSScreen mainScreen] frame];
    lua_newtable( L );
    lua_pushnumber( L, frame.size.width );
    lua_setfield( L, -2, "width" );
    lua_pushnumber( L, frame.size.height );
    lua_setfield( L, -2, "height" );
    return 1;
}
static int systemMouse( lua_State *L ) {
    CGEventRef event = CGEventCreate( NULL );
    CGPoint cursor = CGEventGetLocation( event );
    CFRelease( event );
    lua_newtable( L );
    lua_pushnumber( L, cursor.x );
    lua_setfield( L, -2, "x" );
    lua_pushnumber( L, cursor.y );
    lua_setfield( L, -2, "y" );
    lua_pushboolean( L, AppState.pressed );
    lua_setfield( L, -2, "pressed" );
    lua_pushboolean( L, AppState.dragged );
    lua_setfield( L, -2, "dragging" );
    return 1;
}

static const struct luaL_Reg sys[] = { { "time", systemTime },
                                       { "screen", systemScreen },
                                       { "mouse", systemMouse },
                                       { NULL, NULL } };


void lua_initMain( lua_State *L ) {
    luaL_newmetatable( L, "_Emma" );
    luaL_setfuncs( L, emma, 0 );
    lua_pushcfunction( L, emma_new );
    lua_setglobal( L, "Emma" );
    lua_settop( L, 0 );
    lua_newtable( L );
    luaL_setfuncs( L, sys, 0 );
    lua_setglobal( L, "System" );
}


lua_State *L;

@implementation Emma {
}

- (id)init {
    self = [super init];
    if ( self != nil ) {
    }
    return self;
}

- (void)start {
    frame = view.frame;
    [self setUserInteractionListeners];
    [self setLua];
    [self callLua];
}

- (void)setLua {
    [self setFileListeners];
    L = luaL_newstate();
    luaL_openlibs( L );
    luaopen_luagl( L );
    lua_initMat4( L );
    lua_initVec3( L );
    luaopen_gpc( L );
    lua_initMain( L );
    [self doLuaFile:LUA_MAIN];
}

- (bool)doLuaFile:(NSString *)path {
    const char *c = [path cStringUsingEncoding:NSUTF8StringEncoding];
    if ( luaL_dofile( L, c ) ) {
        fucked = true;
        printf( "cannot run lua! :( %s", lua_tostring( L, -1 ) );
    } else {
        fucked = false;
    }
    return fucked;
}

- (void)callLua {
    lua_settop( L, 0 );
    lua_getglobal( L, "main" );
    emma_call( L, 0, 0 );
    lua_settop( L, 0 );
}

- (void)setFileListeners {

    // add watcher support

    kqueue = [UKKQueue sharedFileWatcher];

    // grab all lua files

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *bundleURL = [NSURL URLWithString:LUA_PATH];
    scriptURL = [[NSURL URLWithString:@"scripts/emma/" relativeToURL:bundleURL] retain];
    NSArray *contents =
        [fileManager contentsOfDirectoryAtURL:scriptURL
                   includingPropertiesForKeys:@[]
                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                        error:nil];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'lua'"];

    // add paths to file watcher object

    for ( NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate] ) {
        // NSLog( @"path %@", [fileURL path] );
        [kqueue addPath:[fileURL path]];
    }

    // add observer for when files are renamed or changed
    // check when renamed

    //    [[[NSWorkspace sharedWorkspace] notificationCenter]
    //        addObserver:self
    //           selector:@selector( onFileChange )
    //               name:UKFileWatcherAccessRevocationNotification
    //             object:nil];

    // check when file is changed..

    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self
           selector:@selector( onFileChange )
               name:UKFileWatcherWriteNotification
             object:nil];
}


- (void)setUserInteractionListeners {

    const int maskDown = NSLeftMouseDownMask | NSRightMouseDown;
    const int maskLift = NSLeftMouseUp | NSRightMouseUp;
    const int maskDrag = NSLeftMouseDragged | NSRightMouseDragged;

    // The global monitoring handler is *not* called for events sent to our
    // application
    [NSEvent addGlobalMonitorForEventsMatchingMask:maskDown
                                           handler:^( NSEvent *event ) {
                                               AppState.pressed = YES;
                                           }];

    [NSEvent addGlobalMonitorForEventsMatchingMask:maskLift
                                           handler:^( NSEvent *event ) {
                                               AppState.pressed = NO;
                                               AppState.dragged = NO;
                                           }];

    // The global monitoring handler is *not* called for events sent to our
    // application
    [NSEvent addGlobalMonitorForEventsMatchingMask:maskDrag
                                           handler:^( NSEvent *event ) {
                                               // get location here...
                                               AppState.dragged = YES;
                                           }];
}

- (void)onFileChange {
    FLUSHING = YES;

    printf( "\n file change... \n" );
    [view.openGLContext makeCurrentContext];
    [self onFileChange_tearDownLua];
    [self onFileChange_checkNewFiles];
    if ( ![self doLuaFile:LUA_APP] ) {
        emma_reload( L );
    }
}

- (void)onFileChange_tearDownLua {
    emma_destroy( L );
}

- (void)onFileChange_checkNewFiles {

    // Get files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents =
        [fileManager contentsOfDirectoryAtURL:scriptURL
                   includingPropertiesForKeys:@[]
                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                        error:nil];
    // Filter to lua files
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'lua'"];

    // Check for new lua files
    for ( NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate] ) {
        BOOL found;
        found = false;
        NSString *path = [fileURL path];
        for ( NSString *p in kqueue->watchedPaths ) {
            if ( [p isEqualToString:path] ) {
                found = true;
            }
        }

        if ( !found ) {
            NSLog( @"newbie lu file %@", [fileURL path] );
            [kqueue addPath:path];
        }
    }
}


@end
