//
//  math.c
//  desky
//
//  Created by Chris Allen on 24/06/2014.
//  Copyright (c) 2014 Chris Allen. All rights reserved.
//

#include <stdio.h>
#import "emma_mat4.h"
#include "lua.h"
#include "lauxlib.h"

#if defined( __APPLE__ ) || defined( OSX )
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif
#import <OpenGL/gl3.h>
#import "emma_vec3.h"

static int mat4_index( lua_State* L );
static int mat4_newindex( lua_State* L );
static int mat4_call( lua_State* L );
static int mat4_mul( lua_State* L );
static int mat4_sub( lua_State* L );
static int mat4_gc( lua_State* L );
static int mat4_projection( lua_State* L );
static int mat4_scale( lua_State* L );
static int mat4_multiply( lua_State* L );
static int mat4_subtract( lua_State* L );
static int mat4_add( lua_State* L );
static int mat4_translate( lua_State* L );
static int mat4_identity( lua_State* L );
static int mat4_assign( lua_State* L );
static int mat4_lookat( lua_State* L );
static const struct luaL_Reg luamat4Lib[] = { { "__index", mat4_index },
                                              { "__newindex", mat4_newindex },
                                              { "__call", mat4_call },
                                              { "__mul", mat4_mul },
                                              { "__sub", mat4_sub },
                                              { "__add", mat4_add },
                                              { "__gc", mat4_gc },
                                              { "CreateProjection", mat4_projection },
                                              { "CreateScale", mat4_scale },
                                              // these assign to own matrix
                                              { "identity", mat4_identity },
                                              { "multiply", mat4_multiply },
                                              { "translate", mat4_translate },
                                              { "assign", mat4_assign },
                                              { "lookAt", mat4_lookat },
                                              { NULL, NULL } };

void lua_initMat4( lua_State* L ) {
    lua_settop( L, 0 );
    luaL_newmetatable( L, "mat4" );
    luaL_setfuncs( L, luamat4Lib, 0 );
    lua_newtable( L );
    luaL_setmetatable( L, "mat4" );
    lua_setglobal( L, "mat4" );
}

lua_mat4* mat4_userdatap( lua_State* L, int pos ) {
    lua_pushvalue( L, pos ); // put table to top
    lua_pushstring( L, "__ud" );
    lua_rawget( L, -2 );
    lua_remove( L, -2 );
    lua_mat4* ud = (lua_mat4*)lua_touserdata( L, -1 );
    lua_remove( L, -1 );
    return ud;
};

lua_mat4* mat4_create( lua_State* L ) {
    lua_newtable( L );
    lua_pushstring( L, "__ud" );
    lua_mat4* mat4 = lua_newuserdata( L, sizeof( lua_mat4 ) );
    lua_settable( L, -3 );
    luaL_getmetatable( L, "mat4" );
    lua_setmetatable( L, -2 );
    mat4->data = (kmMat4*)malloc( sizeof( kmMat4 ) );
    return mat4;
}

static int mat4_index( lua_State* L ) {
    if ( lua_isstring( L, -1 ) ) {
        char* key = lua_tostring( L, -1 );
        luaL_getmetatable( L, "mat4" );
        lua_getfield( L, -1, key );
    } else {
        lua_mat4* mat4 = mat4_userdatap( L, 1 );
        int index = lua_tounsignedx( L, 2, NULL );
        index = ( index <= 0 ) ? 0 : index - 1;
        lua_pushnumber( L, mat4->data->mat[index] );
    }
    return 1;
}

static int mat4_newindex( lua_State* L ) {
    if ( lua_isnumber( L, -2 ) ) {
        lua_mat4* mat4 = mat4_userdatap( L, 1 );
        int index = lua_tounsignedx( L, -2, NULL );
        index = ( index <= 0 ) ? 0 : index - 1;
        float value = lua_tonumberx( L, -1, NULL );
        mat4->data->mat[index] = value;
    } else {
        lua_rawset( L, -3 );
    }

    return 0;
}

static int mat4_call( lua_State* L ) {
    lua_mat4* mat4;
    mat4 = mat4_create( L );
    kmMat4Identity( mat4->data );
    return 1;
}

static int mat4_mul( lua_State* L ) {
    lua_mat4* mat4;
    lua_mat4* mat4L = mat4_userdatap( L, -2 );
    lua_mat4* mat4R = mat4_userdatap( L, -1 );
    mat4 = mat4_create( L );

    if ( lua_isuserdata( L, -1 ) ) {
        kmMat4Multiply( mat4->data, mat4L->data, mat4R->data );
    } else if ( lua_isnumber( L, -1 ) ) {
        float scale = lua_tonumberx( L, -1, NULL );
        kmMat4 scaling;
        kmMat4Scaling( &scaling, scale, scale, scale );
        kmMat4Multiply( mat4->data, mat4L->data, &scaling );
    }
    return 1;
}

static int mat4_sub( lua_State* L ) { return 1; }
static int mat4_add( lua_State* L ) { return 1; }
static int mat4_gc( lua_State* L ) {
    // dump shit here
    lua_mat4* mat4 = mat4_userdatap( L, 1 );
    free( mat4->data );
    // printf( "deleted it" );
    return 1;
}


static int mat4_projection( lua_State* L ) {
    lua_mat4* mat4;
    kmScalar fovY, aspect, zNear, zFar;

    fovY = lua_tonumberx( L, -4, NULL );
    aspect = lua_tonumberx( L, -3, NULL );
    zNear = lua_tonumberx( L, -2, NULL );
    zFar = lua_tonumberx( L, -1, NULL );

    mat4 = mat4_create( L );
    kmMat4PerspectiveProjection( mat4->data, fovY, aspect, zNear, zFar );

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

    mat4 = mat4_create( L );
    kmMat4OrthographicProjection( mat4->data, left, right, bottom, top, nearVal, farVal );
    return 1;
}

static int mat4_scale( lua_State* L ) {
    kmScalar x, y, z;
    lua_mat4* mat1;
    kmMat4 data;

    x = lua_tonumberx( L, -3, NULL );
    y = lua_tonumberx( L, -2, NULL );
    z = lua_tonumberx( L, -1, NULL );

    lua_mat4* mat4L = mat4_userdatap( L, 1 );
    kmMat4Scaling( mat4L->data, x, y, z );
    lua_pushvalue( L, 1 );
    return 1;
}


static int mat4_identity( lua_State* L ) {
    float x, y, z;
    lua_mat4* mat1;

    mat1 = mat4_userdatap( L, 1 );
    kmMat4Identity( mat1->data );
    return 1;
}

static int mat4_assign( lua_State* L ) {
    lua_mat4* mat1;
    lua_mat4* mat2;

    mat1 = mat4_userdatap( L, 1 );
    mat2 = mat4_userdatap( L, 2 );

    kmMat4Assign( mat1->data, mat2->data );

    lua_pushvalue( L, 1 );
    return 1;
}

static int mat4_translate( lua_State* L ) {
    float x, y, z;
    kmMat4 translation;
    lua_mat4* mat1;

    x = lua_tonumberx( L, -3, NULL );
    y = lua_tonumberx( L, -2, NULL );
    z = lua_tonumberx( L, -1, NULL );
    mat1 = mat4_userdatap( L, 1 );
    kmMat4Translation( &translation, x, y, z );
    kmMat4Multiply( mat1->data, mat1->data, &translation );
    lua_pushvalue( L, 1 );
    return 1;
}


static int mat4_multiply( lua_State* L ) {
    lua_mat4* mat1;
    lua_mat4* mat2;
    kmMat4 scaling;

    mat1 = mat4_userdatap( L, 1 );

    if ( !lua_isnumber( L, -1 ) ) {
        mat2 = mat4_userdatap( L, 2 );
        kmMat4Multiply( mat1->data, mat1->data, mat2->data );

    } else {
        float scale = lua_tonumberx( L, -1, NULL );
        kmMat4Scaling( &scaling, scale, scale, scale );
        kmMat4Multiply( mat1->data, mat1->data, &scaling );
    }

    // as we self assigned the left hand matrix, push for result
    lua_pushvalue( L, 1 );
    return 1;
};


static int mat4_lookat( lua_State* L ) {
    lua_mat4* mat1;
    lua_vec3* pEye;
    lua_vec3* pCenter;
    lua_vec3* pUp;

    mat1 = mat4_userdatap( L, 1 );
    pEye = vec3_userdatap( L, -3 );
    pCenter = vec3_userdatap( L, -2 );
    pUp = vec3_userdatap( L, -1 );

    kmMat4LookAt( mat1->data, pEye->data, pCenter->data, pUp->data );
    lua_pushvalue( L, 1 );
    return 1;
};
