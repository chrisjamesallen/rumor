//
//  math.h
//  desky
//
//  Created by Chris Allen on 24/06/2014.
//  Copyright (c) 2014 Chris Allen. All rights reserved.
//
//
#include "lua.h"
#include "lauxlib.h"
#import "kazmath.h"

typedef struct lua_mat4 {
    long length;
    kmMat4* data;
} lua_mat4;
void lua_initMat4( lua_State* L );
lua_mat4* mat4_userdatap( lua_State* L, int pos );
lua_mat4* mat4_create( lua_State* L );