
#import "Emma.h"
#import "chris.h"
#import <OpenGL/OpenGL.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/CVDisplayLink.h>
#include <time.h>

const NSString *LUA_PATH = @"/Users/chrisallen/projects/desky/";
const NSString *LUA_MAIN = @"/Users/chrisallen/projects/desky/scripts/main.lua";
const NSString *LUA_APP = @"/Users/chrisallen/projects/desky/scripts/emma/app.lua";
int emma_test( lua_State *L );



struct  appS {
    BOOL pressed;
    BOOL dragged;
    // emma lua struct
    // mouse position
} AppState;

static int emma_gc( lua_State *L ) {
    stackDump( L );
    puts( "__gc called" );
    // call obj destroy method
    return 0;
}


void emma_call( lua_State *L, int args, int returns ) {
    if ( lua_pcall( L, args, returns, 0 ) != 0 )
        printf( "emma:error calling function %s", lua_tostring( L, -1 ) );
}

static const struct luaL_Reg emma[] = {
    { "delete", emma_gc }, { "foo", emma_gc }, { "__gc", emma_gc }, { NULL, NULL }
};


static int emma_new( lua_State *L ) {
    lua_getglobal( L, "newObject" );
    emma_call( L, 0, 0 );
    //    lua_newtable( L );
    //    lua_newtable( L );
    //    luaL_getmetatable(L,"_Emma");
    //    lua_setfield( L, -2, "__index" );
    //    lua_setmetatable(L, -2);//pop and apply foo metatable to block, return block
    return 1;
}

static int systemTime( lua_State *L ) {
    clock_t clock_t;
    clock_t = clock();
    lua_pushnumber( L, clock_t );
    return 1;
}
static int systemScreen( lua_State *L ) {
    NSRect frame = [[NSScreen mainScreen] frame];
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
    lua_pushboolean(L, AppState.pressed);
    lua_setfield( L, -2, "pressed");
    lua_pushboolean(L, AppState.dragged);
    lua_setfield( L, -2, "dragging");
    return 1;
}

static const struct luaL_Reg sys[] = { { "time", systemTime },
                                       { "screen", systemScreen },
                                       { "mouse", systemMouse },
                                       { NULL, NULL } };

void emma_update( lua_State *L, double delta, int64_t time ) {
    lua_plock(L, "");
    lua_getglobal( L, "update" );
    lua_pushnumber( L, delta );
    lua_pushnumber( L, (long)time );
    emma_call( L, 2, 0 );
    lua_punlock(L, "");
}

void emma_draw( lua_State *L ) {
    lua_getglobal( L, "draw" );
    emma_call( L, 0, 0 );
}

void emma_reload( lua_State *L ) {
    lua_getglobal( L, "reload" );
    emma_call( L, 0, 0 );
}

void emma_destroy( lua_State *L ) {
    lua_getglobal( L, "destroy" );
    emma_call( L, 0, 0 );
}

void main_init( lua_State *L ) {
    // set obj global
    // assign constructor init and destroy
    luaL_newmetatable( L, "_Emma" );
    luaL_setfuncs( L, emma, 0 );
    // create constructor
    lua_pushcfunction( L, emma_new );
    lua_setglobal( L, "Emma" );
    lua_settop( L, 0 );

    lua_newtable( L );
    luaL_setfuncs( L, sys, 0 );
    lua_setglobal( L, "System" );
}

void main_start( lua_State *L ) {

    lua_settop( L, 0 );
    lua_getglobal( L, "main" );
    emma_call( L, 0, 0 );
    lua_settop( L, 0 );
}


lua_State *L;


@implementation Emma {
    chris *shape;
}

- (id)init;{
    self = [super init];
    if ( self != nil ) {
      //  shape = [[chris alloc] init];
    }
    return self;
}

- (void)start {
    [self setupLua];
    [self setMouse];
    main_start( L );
}

- (void)setMouse {
    const int maskDown = NSLeftMouseDownMask | NSRightMouseDown;
    const int maskLift = NSLeftMouseUp | NSRightMouseUp;
    const int maskDrag = NSLeftMouseDragged | NSRightMouseDragged;
    // The global monitoring handler is *not* called for events sent to our application
    [NSEvent addGlobalMonitorForEventsMatchingMask:maskDown handler:^(NSEvent* event) {
        AppState.pressed  = YES;
    }];
    
    [NSEvent addGlobalMonitorForEventsMatchingMask:maskLift handler:^(NSEvent* event) {
        AppState.pressed = NO;
        AppState.dragged = NO;
    }];
    
    // The global monitoring handler is *not* called for events sent to our application
    [NSEvent addGlobalMonitorForEventsMatchingMask:maskDrag handler:^(NSEvent* event) {
        //get location here...
        AppState.dragged = YES;
    }];
}

- (void)draw {
//    [shape draw];
}


- (void)setupLua {
    [self setupFileWatcher];
    // create global lua state
    L = luaL_newstate();
    luaL_openlibs( L );
    luaopen_luagl( L );
    main_init( L );
    [self executeLuaFile];
}

- (void)setupFileWatcher {

    // add watcher support
    kqueue = [UKKQueue sharedFileWatcher];

    // grab all lua files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *bundleURL =
        [NSURL URLWithString:LUA_PATH]; //[[NSBundle mainBundle] resourceURL];
    scriptURL = [[NSURL URLWithString:@"scripts/emma/" relativeToURL:bundleURL] retain];
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
        printf( "cannot run lua :( %s", lua_tostring( L, -1 ) );
        // luaL_error( L, "cannot run lua :( %s", lua_tostring( L, -1 ) );
    }
}

- (void)aFileHasBeenChanged {
    // NSLog( @"file change!" );
    printf("file change");
    [view->condition lock];
        [view.openGLContext makeCurrentContext];
        FLUSHING = YES;
        emma_destroy( L );
        FLUSHING = NO;
    [view->condition signal];
    [view->condition unlock];
    
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents =
        [fileManager contentsOfDirectoryAtURL:scriptURL
                   includingPropertiesForKeys:@[]
                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                        error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'lua'"];

    // add paths to file watcher object
    for ( NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate] ) {
        NSString *path = [fileURL path];
        BOOL found = false;
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

    const char *c = [LUA_APP cStringUsingEncoding:NSUTF8StringEncoding];
    if ( luaL_loadfile( L, c ) || lua_pcall( L, 0, 0, 0 ) ) {
        printf( "cannot run lua :( %s", lua_tostring( L, -1 ) );
    }
    emma_reload( L );
}

@end