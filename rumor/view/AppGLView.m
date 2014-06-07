#import "AppGLView.h"

const NSString * LUA_PATH = @"/Users/chrisallen/projects/rumor/scripts/";
const NSString * LUA_MAIN = @"/Users/chrisallen/projects/rumor/scripts/main.lua";
static int gl_enable(lua_State *L);
static int gl_clearcolor(lua_State *L);
void loadLuaMetaTable(lua_State * L, const luaL_Reg *table, const char * name){
    luaL_newmetatable(L, name);
    lua_setfield(L, -1, "__index");
    lua_newtable(L);
    luaL_setfuncs(L, table, 0);
    lua_setglobal(L, "gl");
}
static const struct luaL_Reg gl [] = {
    {"blendMode", gl_enable},
    {"enable", gl_enable},
    {"disable", gl_enable},
    {"clearColor", gl_clearcolor},
    {"flush", gl_enable},
    {NULL, NULL}
};

static int gl_enable(lua_State *L){
    //get string

    //set on gl enable...
    return 0;
}

static int gl_clearcolor(lua_State *L){
    //get all four values
    
    //set on gl color...
    glClearColor(1, 1, 0, 1);
    glFlush();
    return 0;
}

@implementation AppGLView


- (void)mouseUp:(NSEvent *)theEvent{
    NSLog(@"mouseup");
    [self startUpLua];
	[self.director start];
	[self.openGLContext flushBuffer];
    
    //lets read a file
}

-(void)startUpLua {
    L = luaL_newstate();
    luaL_openlibs(L);
    //setenv("LUA_PATH", "/Users/chrisallen/projects/rumor/scripts/", 1);
    //add watcher support
    kqueue = [UKKQueue sharedFileWatcher];
    [kqueue addPath:LUA_MAIN];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(fileWatch) name:UKFileWatcherRenameNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(fileWatch) name:UKFileWatcherAttributeChangeNotification object:nil];
    //read main file...
    loadLuaMetaTable(L, gl,"gl");

    [self loadLuaFile];
    //add open personal libraries
}

-(void)fileWatch{
    NSLog(@"file watch!");
    //reload scripts here
}

-(void)loadLuaFile{
    const char * c = [LUA_MAIN cStringUsingEncoding:NSUTF8StringEncoding];
    if(luaL_loadfile(L, c) || lua_pcall(L,0,0,0)){
        luaL_error(L, "cannot run lua :( %s", lua_tostring(L, -1));
    }
}

- (void)drawRect:(NSRect)bounds {
    NSLog(@"draw rect") ;
	[self clearContent];
    glViewport(0,0, windowSize.width, windowSize.height);
	glEnable (GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //glColorMask(FALSE, FALSE, FALSE, TRUE);//This ensures that only alpha will be effected
    //glClearColor(0, 0, 0, 0.0);//alphaValue - Value to which you need to clear
    glClear(GL_COLOR_BUFFER_BIT);
    glFlush();
}

- (void)clearContent
{
	[[NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha:0.2] set];
	NSRectFill([self bounds]);
}

- (void) setup {
    NSLog(@"setup app gl view");
    // create a new pixel format?
    NSOpenGLPixelFormatAttribute pixelFormats[] = {
            NSOpenGLPFAColorSize, 32,
            NSOpenGLPFADepthSize, 32,
			NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAStencilSize, 8,
            NSOpenGLPFAAccelerated,
            NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
            0

    };

    NSOpenGLPixelFormat * format = [[[NSOpenGLPixelFormat alloc] initWithAttributes: pixelFormats] autorelease];
    NSOpenGLContext * context = [[[NSOpenGLContext alloc] initWithFormat:format shareContext:nil] autorelease];
    int aValue = 0;
    [context setValues:&aValue forParameter:NSOpenGLCPSurfaceOpacity];
	[[self window] setOpaque:NO];

    [self setOpenGLContext:context];
   [self.openGLContext makeCurrentContext];
}


- (void) reshape {
    NSLog(@"reshape");
    glViewport(0,0, windowSize.width, windowSize.height);
}

-(NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize{
    windowSize = frameSize;
    self.frame = CGRectMake(0, 0, frameSize.width, frameSize.height);
    return frameSize;
}

- (void)prepareOpenGL {
    NSLog(@"prepareOpenGL >>> version %s", glGetString(GL_VERSION));
}



- (void)dealloc {
    [_director release];
    [super dealloc];
}


@end