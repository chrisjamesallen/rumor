//
//  emma_vec3.h
//  desky
//
//  Created by Chris Allen on 28/06/2014.
//  Copyright (c) 2014 Chris Allen. All rights reserved.
//

#include "lua.h"
#include "lauxlib.h"
#import "kazmath.h"


typedef struct lua_vec3 {
    long length;
    kmVec3* data;
} lua_vec3;
void lua_initVec3( lua_State* L );
static char lua_vec3T = { 'x', 'y', 'z' };