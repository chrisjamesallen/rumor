

#import <OpenGL/OpenGL.h>
#import <GLKit/GLKit.h>
#import "mesh.h"
#import "plane_mesh.h"
#import "renderer.h"


@implementation mesh {

}
- (id)init {
    self = [super init];
    if (self) {
        //todo learn pointers so no need for .h import
        modelview = GLKMatrix4Identity;
    }

    return self;
}

- (void)draw {

    glClearColor(0, 0, 0, 0.0);//alphaValue - Value to which you need to clear
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    glFlush();

//    // set model view projection to mesh position
//    int mvp = [self.renderer getUniformLocWithKey:@"modelViewProjectionMatrix"];
//	    int pos = [self.renderer getAttributeLocWithKey:@"position"];
//    NSLog(@"draw foo object %d", pos);
//    //glUniformMatrix4fv(pos, 1, 0, GLKMatrix4Identity.m);     //[self.renderer getAttributeLocWithKey:@"position"]
//	glEnableVertexAttribArray( 0 );
//    glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, (4 * (3+3+2)), &planeVerts);
//    glDrawArrays(GL_TRIANGLES, 0, planeNumVerts);
//    glFlush()

    GLfloat vertices [] = {1.0, -1.0f, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, 1, 0};

    [self.renderer use];
    glGenVertexArrays(1, &vertex_array);
    glBindVertexArray(vertex_array);

    glGenBuffers(1, &vertex_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vertex_vbo);
    glBufferData(GL_ARRAY_BUFFER, 4 * 3 * sizeof(GLfloat), &vertices, GL_STATIC_DRAW);

    int pos = [self.renderer getAttributeLocWithKey:@"position"];
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);


    glBindVertexArray(vertex_array);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

}

- (void)assignRender:(renderer *)render {
    self.renderer = render;
}


- (void)scale {

}

- (void)dealloc {
    [_renderer release];
    [super dealloc];
}

@end