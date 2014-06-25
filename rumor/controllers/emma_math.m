//
//  math.c
//  desky
//
//  Created by Chris Allen on 24/06/2014.
//  Copyright (c) 2014 Chris Allen. All rights reserved.
//

#include <stdio.h>
#import "emma_math.h"
#include "lua.h"
#include "lauxlib.h"

#if defined( __APPLE__ ) || defined( OSX )
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif
#import <OpenGL/gl3.h>

static int mat4_index( lua_State* L );
static int mat4_newindex( lua_State* L );
static int mat4_call( lua_State* L );
static int mat4_mul( lua_State* L );
static int mat4_sub( lua_State* L );
static int mat4_add( lua_State* L );
static int mat4_gc( lua_State* L );
static int mat4_projection( lua_State* L );
static int mat4_scale( lua_State* L );


static const struct luaL_Reg luamat4Lib[] = { { "__index", mat4_index },
                                              { "__newindex", mat4_newindex },
                                              { "__call", mat4_call },
                                              { "__mul", mat4_mul },
                                              { "__sub", mat4_sub },
                                              { "__add", mat4_add },
                                              { "__gc", mat4_gc },
                                              { "Projection", mat4_projection },
                                              { "Scale", mat4_scale },
                                              { NULL, NULL } };

void lua_initMat4( lua_State* L ) {
    lua_settop( L, 0 );
    luaL_newmetatable( L, "mat4" );
    luaL_setfuncs( L, luamat4Lib, 0 );
    lua_newtable( L );
    luaL_setmetatable( L, "mat4" );
    lua_setglobal( L, "mat4" );
}

static int mat4_index( lua_State* L ) {
    if ( lua_isstring( L, -1 ) ) {
        char* fnName = lua_tostring( L, -1 );
        luaL_getmetatable( L, "mat4" );
        lua_getfield( L, -1, fnName );
    } else {
        lua_mat4* mat4 = (lua_mat4*)luaL_checkudata( L, 1, "mat4" );
        int index = lua_tounsignedx( L, 2, NULL );
        index = ( index <= 0 ) ? 0 : index - 1;
        lua_pushnumber( L, mat4->data->mat[index] );
    }
    return 1;
}
static int mat4_newindex( lua_State* L ) {
    // so called when accessing mat4[index]
    lua_mat4* mat4 = (lua_mat4*)luaL_checkudata( L, 1, "mat4" );
    int index = lua_tounsignedx( L, 2, NULL );
    index = ( index <= 0 ) ? 0 : index - 1;
    float value = lua_tonumberx( L, 3, NULL );
    mat4->data->mat[index] = value;
    return 0;
}
static int mat4_call( lua_State* L ) {
    // called when calling mat4()
    lua_mat4* mat4;
    kmMat4* data = (kmMat4*)malloc( sizeof( kmMat4 ) );
    mat4 = (lua_mat4*)lua_newuserdata( L, sizeof( lua_mat4 ) );
    mat4->data = data;
    kmMat4Identity( data );
    luaL_getmetatable( L, "mat4" );
    lua_setmetatable( L, -2 );
    return 1;
}

static int mat4_mul( lua_State* L ) {
    lua_mat4* mat4;
    lua_mat4* mat4L = (lua_mat4*)luaL_checkudata( L, 1, "mat4" );
    kmMat4* result = (kmMat4*)malloc( sizeof( kmMat4 ) );

    if ( lua_isuserdata( L, -1 ) ) {
        lua_mat4* mat4R = (lua_mat4*)luaL_checkudata( L, 2, "mat4" );
        kmMat4Multiply( result, mat4L->data->mat, mat4R->data->mat );
    } else if ( lua_isnumber( L, -1 ) ) {
        float scale = lua_tonumberx( L, -1, NULL );
        kmMat4 scaling;
        kmMat4Scaling( &scaling, scale, scale, scale );
        kmMat4Multiply( result, mat4L->data->mat, &scaling );
    }

    mat4 = (lua_mat4*)lua_newuserdata( L, sizeof( lua_mat4 ) );
    mat4->data = result;
    luaL_getmetatable( L, "mat4" );
    lua_setmetatable( L, -2 );
    return 1;
}

static int mat4_sub( lua_State* L ) { return 1; }
static int mat4_add( lua_State* L ) { return 1; }
static int mat4_gc( lua_State* L ) {
    // dump shit here
    lua_mat4* mat4 = (lua_mat4*)luaL_checkudata( L, 1, "mat4" );
    printf( "drop mat4" );
    free( mat4->data );
    return 1;
}


static int mat4_projection( lua_State* L ) {
    lua_mat4* mat4;
    kmScalar fovY, aspect, zNear, zFar;

    fovY = lua_tonumberx( L, -4, NULL );
    aspect = lua_tonumberx( L, -3, NULL );
    zNear = lua_tonumberx( L, -2, NULL );
    zFar = lua_tonumberx( L, -1, NULL );

    kmMat4* data = (kmMat4*)malloc( sizeof( kmMat4 ) );
    mat4 = (lua_mat4*)lua_newuserdata( L, sizeof( lua_mat4 ) );
    mat4->data = data;
    luaL_getmetatable( L, "mat4" );
    lua_setmetatable( L, -2 );

    kmMat4PerspectiveProjection( data, fovY, aspect, zNear, zFar );
    return 1;
}

static int mat4_orthoprojection( lua_State* L ) {
    lua_mat4* mat4;
    kmScalar left, right, bottom, top, nearVal, farVal;


    left = lua_tonumberx( L, -6, NULL );
    right = lua_tonumberx( L, -5, NULL );
    bottom = lua_tonumberx( L, -4, NULL );
    top = lua_tonumberx( L, -3, NULL );
    nearVal = lua_tonumberx( L, -2, NULL );
    farVal = lua_tonumberx( L, -1, NULL );

    kmMat4* data = (kmMat4*)malloc( sizeof( kmMat4 ) );
    mat4 = (lua_mat4*)lua_newuserdata( L, sizeof( lua_mat4 ) );
    mat4->data = data;
    luaL_getmetatable( L, "mat4" );
    lua_setmetatable( L, -2 );


    kmMat4OrthographicProjection( data, left, right, bottom, top, nearVal, farVal );
    return 1;
}

static int mat4_scale( lua_State* L ) {
    kmScalar x, y, z;
    lua_mat4* mat4;
    x = lua_tonumberx( L, -3, NULL );
    y = lua_tonumberx( L, -2, NULL );
    z = lua_tonumberx( L, -1, NULL );

    kmMat4 data; // = (kmMat4*)malloc( sizeof( kmMat4 ) );
    mat4 = (lua_mat4*)lua_newuserdata( L, sizeof( lua_mat4 ) );
    mat4->data = &data;
    luaL_getmetatable( L, "mat4" );
    lua_setmetatable( L, -2 );
    kmMat4Scaling( &data, x, y, z );
    return 1;
}
