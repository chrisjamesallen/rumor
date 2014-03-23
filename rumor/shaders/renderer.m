
#import <GLKit/GLKit.h>
#import "renderer.h"


#define GetGLError()									\
{														\
GLenum err = glGetError();							\
while (err != GL_NO_ERROR) {						\
NSLog(@"GLError %s set in File:%s Line:%d\n",	\
GetGLErrorString(err),					\
__FILE__,								\
__LINE__);								\
err = glGetError();								\
}													\
}

static NSMutableDictionary * programs;
static renderer * currentProgram;

@interface renderer (){
    NSString * vsh_name;
    NSString * fsh_name;
    BOOL compiled;
    GLuint vertShader, fragShader;
}
@property(retain) NSMutableDictionary * attributes;
@property(retain) NSMutableDictionary * uniforms;
@end

@implementation renderer

+(NSMutableDictionary*)programs{
    if(programs == nil){
        programs = [[NSMutableDictionary alloc] init];
    }
    return programs;
}

+(renderer *)use:(NSString *)key{
    renderer * prog = [[self programs] valueForKey:key];
    if(prog == nil){
        prog = [[[renderer alloc] initWithVertexShader:key FragmentShader:key] autorelease];
        [[renderer programs] setObject: prog  forKey:key];
        if([key isEqualToString:@"default"]){
            //[prog addAttribute:@"position" atIndex:0];
            //[prog addUniform:@"modelViewProjectionMatrix"];
            //[prog addAttribute:@"texCoordinates" atIndex:1];
            //[prog addUniform:@"texture"];
            //[prog addUniforme:@"textureTwo"];
        }
    }
    [prog use];
    return currentProgram = prog;
}

+(renderer *)default{
    return [renderer use:@"default"];
}

+(renderer *)current{
    [currentProgram use];
    return currentProgram;
}





- (id)initWithVertexShader:(NSString*)vsh FragmentShader:(NSString *)fsh
{
    self = [super init];
    if (self) {
        self->_program = glCreateProgram();
        self.attributes = [NSMutableDictionary dictionary];
        self.uniforms = [NSMutableDictionary dictionary];
        self->vsh_name = [vsh retain];
        self->fsh_name = [fsh retain];
        [self load];
 
    }
    return self;
}

-(BOOL)load{
    if([self loadShaders]){
       return [self link];
    }
    return NO;
}

- (BOOL)loadShaders
{
    
    NSString *vertShaderPathname, *fragShaderPathname;
    //check already compiled...
    if(compiled){ return YES; }
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:self->vsh_name ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:self->fsh_name ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    return YES;
}


-(BOOL)link{
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindFragDataLocation(_program, 0, "outFragColor");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        [self releaseShaders];
        [self deleteProgram];
        return NO;
    }
    
    // Get uniform locations.
    [self addUniform:@"modelViewProjectionMatrix"];
    // Release vertex and fragment shaders.
    [self releaseShaders];
    return compiled = YES;
}

-(void)resetProgram{
    compiled = NO;
    [self releaseShaders];
    [self deleteProgram];
}

-(void)releaseShaders{
    if (vertShader) {
        if(_program){
            glDetachShader(_program, vertShader);
        }
        glDeleteShader(vertShader);
        vertShader = 0;
    }
    if (fragShader) {
        if(_program){
            glDetachShader(_program, fragShader);
        }
        glDeleteShader(fragShader);
        fragShader = 0;
    }
}

-(void)deleteProgram{
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

-(void)addAttribute:(NSString *)key atIndex:(NSInteger) index{
    [self.attributes setObject:[NSNumber numberWithInteger:index] forKey:key];
    //now reset program and add all again...
    [self resetProgram];
    //now reset load shaders
    if([self loadShaders]){
        for(NSString * key in self.attributes){
            glBindAttribLocation(_program, (GLuint)[[self.attributes objectForKey:key] intValue], [key cStringUsingEncoding:NSASCIIStringEncoding]);
        }
    }
    [self link];
}

-(void)addUniform:(NSString *)key{
    GLint loc = glGetUniformLocation(_program, [key cStringUsingEncoding:NSASCIIStringEncoding]);
    [self.uniforms setObject:[NSNumber numberWithInteger:loc] forKey:key];
}


-(GLuint)getAttributeLocWithKey:(NSString*)key{
    return (GLuint) [[self.attributes objectForKey:key] intValue];
}

-(GLuint)getUniformLocWithKey:(NSString*)key{
    return (GLuint) glGetUniformLocation(_program, [key cStringUsingEncoding:NSASCIIStringEncoding]);// [[self.uniforms objectForKey:key] intValue];
}




-(void)use{
    glUseProgram(self->_program);
}


#pragma mark - LOGGING


#pragma mark - DEALLOC

- (void)dealloc
{
    [self.attributes release];
    [self.uniforms release];
    [self resetProgram];
    [super dealloc];
}

@end