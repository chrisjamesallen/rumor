
@interface renderer : NSObject{
    @public
    GLuint _program;
}
+(NSMutableDictionary*)programs;
+(renderer *)use:(NSString *)key;
+(renderer *)default;
+(renderer *)current;
+(NSMutableDictionary*)programs;
-(void)use;
-(BOOL)load;
-(BOOL)link;
-(id)initWithVertexShader:(NSString*)vsh FragmentShader:(NSString *)fsh;
-(GLuint)getAttributeLocWithKey:(NSString*)key;
-(GLuint)getUniformLocWithKey:(NSString*)key;
-(void)addAttribute:(NSString *)key  atIndex:(NSInteger) index;
-(void)addUniform:(NSString *)key;
-(void)createShaderObjects;
-(BOOL)validate;
-(BOOL)loadShaders;
@end