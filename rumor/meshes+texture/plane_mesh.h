/*
created with obj2opengl.pl

source file    : ./circle.obj
vertices       : 48
faces          : 46
normals        : 0
texture coords : 0


 
// set input data to arrays
glVertexPointer(3, GL_FLOAT, 0, circleVerts);

// draw data
glDrawArrays(GL_TRIANGLES, 0, circleNumVerts);
*/
#pragma once

#ifndef PLANE_INCLUDED
#define PLANE_INCLUDED
unsigned int planeNumVerts =  6;

float planeVerts[] = {
	/*v:*/-1.000000, -1.000000, -0.000000,  /*n:*/ 0.0, 0.0, -1.0,  /*t:*/ 0.0, 0.0, //bottomleft
    /*v:*/-1.000000, 1.000000, -0.000000,  /*n:*/ 0.0, 0.0, -1.0,  /*t:*/ 0.0, 1.0, //top left
    /*v:*/1.000000, 1.000000, -0.000000,  /*n:*/ 0.0, 0.0, -1.0,  /*t:*/ 1.0, 1.0, //top right
    
    /*v:*/1.000000, 1.000000, -0.000000,  /*n:*/ 0.0, 0.0, -1.0,  /*t:*/ 1.0, 1.0, //top right
  	/*v:*/1.000000, -1.000000, -0.000000,  /*n:*/ 0.0, 0.0, -1.0,  /*t:*/ 1.0, 0.0, //bottom right
  	/*v:*/-1.000000, -1.000000, -0.000000,  /*n:*/ 0.0, 0.0, -1.0,  /*t:*/ 0.0, 0.0, //bottomleft
    
};

float planeTex[] = {
  /*t:*/ 0.0, 0.0, //bottomleft
 /*t:*/ 0.0, 1.0, //top left
/*t:*/ 1.0, 1.0, //top right

/*t:*/ 1.0, 1.0, //top right
 /*t:*/ 1.0, 0.0, //bottom right
  /*t:*/ 0.0, 0.0 //bottomleft
    
};


#endif
