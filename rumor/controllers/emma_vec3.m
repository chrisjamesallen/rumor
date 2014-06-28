//
//  emma_vec3.m
//  desky
//
//  Created by Chris Allen on 28/06/2014.
//  Copyright (c) 2014 Chris Allen. All rights reserved.
//

#import "emma_vec3.h"
#import "emma_mat4.h"
#include "lua.h"
#include "lauxlib.h"
#if defined( __APPLE__ ) || defined( OSX )
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif
#import <OpenGL/gl3.h>

static int vec3_index( lua_State* L );
static int vec3_newindex( lua_State* L );
static int vec3_call( lua_State* L );
static int vec3_mul( lua_State* L );
static int vec3_sub( lua_State* L );
static int vec3_gc( lua_State* L );
static int vec3_multiply( lua_State* L );
static int vec3_subtract( lua_State* L );
static int vec3_add( lua_State* L );
static int vec3_translate( lua_State* L );
static int vec3_assign( lua_State* L );
static int vec3_dot( lua_State* L );
static int vec3_cross( lua_State* L );
static int vec3_lerp( lua_State* L );
static int vec3_normalize( lua_State* L );
static int vec3_assign( lua_State* L );
static int vec3_scale( lua_State* L );
static int vec3_areequal( lua_State* L );
static int vec3_zero( lua_State* L );
static int vec3_gethorizontalangle( lua_State* L );
static int vec3_rotationtodirection( lua_State* L );
static int vec3_mulmat4( lua_State* L );
static int vec3_transformnormal( lua_State* L );
static int vec3_transformcoord( lua_State* L );
static int vec3_inversetransform( lua_State* L );
static int vec3_inversetransformnormal( lua_State* L );


float getVec( lua_vec3* vec, float i, char* key );
float setVec( lua_vec3* vec, float val, float i, char* key );

static const struct luaL_Reg luavec3Lib[] = {
    { "__index", vec3_index },
    { "__newindex", vec3_newindex },
    { "__call", vec3_call },
    { "__mul", vec3_mul },
    { "__sub", vec3_sub },
    { "__add", vec3_add },
    { "__gc", vec3_gc },
    { "dot", vec3_dot },
    { "cross", vec3_cross },
    { "lerp", vec3_lerp },
    { "normalize", vec3_normalize },
    { "assign", vec3_assign },
    { "scale", vec3_scale },
    { "areEqual", vec3_areequal },
    { "zero", vec3_zero },
    { "gethorizontalangle", vec3_gethorizontalangle },
    { "rotationToDirection", vec3_rotationtodirection },
    { "multiplyMat4", vec3_mulmat4 },
    { "transformNormal", vec3_transformnormal },
    { "transformCoord", vec3_transformcoord },
    { "inverseTransform", vec3_inversetransform },
    { "inverseTransformNormal", vec3_inversetransformnormal },
    { NULL, NULL }
};


void lua_initVec3( lua_State* L ) {
    lua_settop( L, 0 );
    luaL_newmetatable( L, "vec3" );
    luaL_setfuncs( L, luavec3Lib, 0 );
    lua_newtable( L );
    luaL_setmetatable( L, "vec3" );
    lua_setglobal( L, "vec3" );
}

lua_vec3* vec3_userdata( lua_State* L ) {
    lua_pushvalue( L, 1 ); // put table to top
    lua_pushstring( L, "__ud" );
    lua_rawget( L, -2 );
    lua_remove( L, -2 );
    lua_vec3* ud = (lua_vec3*)lua_touserdata( L, -1 );
    lua_remove( L, -1 );
    return ud;
};

lua_vec3* vec3_userdatap( lua_State* L, int pos ) {
    lua_pushvalue( L, pos ); // put table to top
    lua_pushstring( L, "__ud" );
    lua_rawget( L, -2 );
    lua_remove( L, -2 );
    lua_vec3* ud = (lua_vec3*)lua_touserdata( L, -1 );
    lua_remove( L, -1 );
    return ud;
};

lua_vec3* vec3_create( lua_State* L ) {
    lua_newtable( L );
    lua_pushstring( L, "__ud" );
    lua_vec3* vec3 = lua_newuserdata( L, sizeof( lua_vec3 ) );
    lua_settable( L, -3 );
    luaL_getmetatable( L, "vec3" );
    lua_setmetatable( L, -2 );
    vec3->data = (kmVec3*)malloc( sizeof( kmVec3 ) );
    return vec3;
}

static int vec3_call( lua_State* L ) {
    lua_vec3* vec3;
    float x, y, z;
    vec3 = vec3_create( L );
    if ( lua_isnumber( L, -2 ) ) {
        x = lua_tonumberx( L, -4, NULL );
        y = lua_tonumberx( L, -3, NULL );
        z = lua_tonumberx( L, -2, NULL );
        vec3->data->x = x;
        vec3->data->y = y;
        vec3->data->z = z;
    }

    return 1;
}

static int vec3_index( lua_State* L ) {
    if ( lua_isstring( L, -1 ) ) {
        char* key = lua_tostring( L, -1 );
        if ( *key == 'x' || *key == 'y' || *key == 'z' ) {
            lua_vec3* vec3 = vec3_userdata( L );
            lua_pushnumber( L, getVec( vec3, -1, key ) );
        } else {
            luaL_getmetatable( L, "vec3" );
            lua_getfield( L, -1, key );
        }

    } else {
        lua_vec3* vec3 = vec3_userdata( L );
        int index = lua_tounsignedx( L, 2, NULL );
        index = ( index <= 0 ) ? 0 : index - 1;
        lua_pushnumber( L, getVec( vec3, index, NULL ) );
    }
    return 1;
}

static int vec3_newindex( lua_State* L ) {
    if ( lua_isstring( L, -2 ) ) {
        char* key = lua_tostring( L, -2 );
        if ( *key == 'x' || *key == 'y' || *key == 'z' ) {
            lua_vec3* vec3 = vec3_userdatap( L, -3 );
            float val = lua_tonumber( L, -1 );
            setVec( vec3, val, -1, key );
        } else {
            lua_rawset( L, -3 );
        }
    }
    return 0;
}


static int vec3_mul( lua_State* L ) {
    lua_vec3* vec3;
    lua_vec3* vec3L = vec3_userdatap( L, -2 );
    vec3 = vec3_create( L );

    if ( lua_istable( L, -2 ) ) {
        lua_vec3* vec3R = vec3_userdatap( L, -2 );
        kmVec3Mul( vec3->data, vec3L->data, vec3R->data );
    } else if ( lua_isnumber( L, -2 ) ) {
        float scale = lua_tonumberx( L, -2, NULL );
        kmVec3 scaling;
        kmVec3Fill( &scaling, scale, scale, scale );
        kmVec3Mul( vec3->data, vec3L->data, &scaling );
    }

    return 1;
}

static int vec3_sub( lua_State* L ) {
    lua_vec3* vec3;
    lua_vec3* vec3L = vec3_userdatap( L, -2 );
    lua_vec3* vec3R = vec3_userdatap( L, -1 );
    vec3 = vec3_create( L );
    kmVec3Subtract( vec3->data, vec3L->data, vec3R->data );
    return 1;
}


static int vec3_add( lua_State* L ) {
    lua_vec3* vec3;
    lua_vec3* vec3L = vec3_userdatap( L, -2 );
    lua_vec3* vec3R = vec3_userdatap( L, -1 );
    vec3 = vec3_create( L );
    kmVec3Add( vec3->data, vec3L->data, vec3R->data );
    luaL_getmetatable( L, "vec3" );
    lua_setmetatable( L, -2 );
    return 1;
}


static int vec3_assign( lua_State* L ) {
    lua_vec3* vec3L = vec3_userdatap( L, -2 );
    lua_vec3* vec3R = vec3_userdatap( L, -1 );
    kmVec3Assign( vec3L->data, vec3R->data );
    lua_pushvalue( L, -2 );
    return 1;
}

static int vec3_dot( lua_State* L ) {
    lua_vec3* vec3L = vec3_userdatap( L, -2 );
    lua_vec3* vec3R = vec3_userdatap( L, -1 );
    float dot = kmVec3Dot( vec3L->data, vec3R->data );
    lua_pushnumber( L, dot );
    return 1;
};

static int vec3_cross( lua_State* L ) {
    lua_vec3* vec3L = vec3_userdatap( L, -2 );
    lua_vec3* vec3R = vec3_userdatap( L, -1 );
    lua_vec3* vec3 = vec3_create( L );
    kmVec3Cross( vec3->data, vec3L->data, vec3R->data );
    return 1;
};

static int vec3_lerp( lua_State* L ) {
    lua_vec3* vec3L = vec3_userdatap( L, -3 );
    lua_vec3* vec3R = vec3_userdatap( L, -2 );
    float time = lua_tonumberx( L, -1, NULL );
    lua_vec3* vec3 = vec3_create( L );
    kmVec3Lerp( vec3->data, vec3L->data, vec3R->data, time );
    return 1;
};

static int vec3_normalize( lua_State* L ) {
    lua_vec3* vec3L = vec3_userdatap( L, -2 );
    lua_vec3* vec3R = vec3_userdatap( L, -1 );
    kmVec3Normalize( vec3L->data, vec3R->data );
    lua_pushvalue( L, -2 );
    return 1;
};

// static int vec3_mulmat3 ( lua_State* L ){
//
//    lua_vec3* pOut = vec3_userdatap( L, -2 );
//    lua_vec3* vec3R = vec3_userdatap( L, -1 );
//    kmVec3MultiplyMat3(pOut, const kmVec3 *pV, const struct kmMat3* pM);
//    return 1;
//};

static int vec3_mulmat4( lua_State* L ) {
    lua_vec3* pOut;
    lua_vec3* pV;
    lua_mat4* pM;
    pOut = vec3_userdatap( L, -3 );
    pV = vec3_userdatap( L, -2 );
    pM = mat4_userdatap( L, -1 );
    kmVec3MultiplyMat4( pOut->data, pV->data, pM->data );
    lua_pushvalue( L, 1 );
    return 1;
};


static int vec3_transformnormal( lua_State* L ) {
    lua_vec3* pOut;
    lua_vec3* pV;
    lua_mat4* pM;
    pOut = vec3_userdatap( L, -3 );
    pV = vec3_userdatap( L, -2 );
    pM = mat4_userdatap( L, -1 );
    kmVec3TransformNormal( pOut->data, pV->data,
                           pM->data ); /**Transforms a 3D normal by a given matrix */
    lua_pushvalue( L, 1 );
    return 1;
};
static int vec3_transformcoord( lua_State* L ) {
    lua_vec3* pOut;
    lua_vec3* pV;
    lua_mat4* pM;
    pOut = vec3_userdatap( L, -3 );
    pV = vec3_userdatap( L, -2 );
    pM = mat4_userdatap( L, -1 );
    kmVec3TransformCoord( pOut->data, pV->data,
                          pM->data ); /**Transforms a 3D vector by a given
                                         matrix,projecting the result back into w = 1. */
    lua_pushvalue( L, 1 );
    return 1;
};

static int vec3_scale( lua_State* L ) {
    lua_vec3* v1;
    lua_vec3* v2;
    v1 = vec3_userdatap( L, -3 );
    v2 = vec3_userdatap( L, -2 );
    float scale = lua_tonumber( L, -1 );
    kmVec3Scale( v1->data, v2->data, scale ); /** Scales a vector to length s */
    return 1;
};
static int vec3_areequal( lua_State* L ) {
    lua_vec3* v1;
    lua_vec3* v2;
    v1 = vec3_userdatap( L, -2 );
    v2 = vec3_userdatap( L, -1 );
    kmVec3AreEqual( v1->data, v2->data );
    return 1;
};
static int vec3_inversetransform( lua_State* L ) {
    lua_vec3* pOut;
    lua_vec3* pV;
    lua_mat4* pM;
    pOut = vec3_userdatap( L, -3 );
    pV = vec3_userdatap( L, -2 );
    pM = mat4_userdatap( L, -1 );
    kmVec3InverseTransform( pOut->data, pV->data, pM->data );
    lua_pushvalue( L, 1 );
    return 1;
};
static int vec3_inversetransformnormal( lua_State* L ) {
    lua_vec3* pOut;
    lua_vec3* pV;
    lua_mat4* pM;
    pOut = vec3_userdatap( L, -3 );
    pV = vec3_userdatap( L, -2 );
    pM = mat4_userdatap( L, -1 );
    kmVec3InverseTransformNormal( pOut->data, pV->data, pM->data );
    lua_pushvalue( L, 1 );
    return 1;
};

static int vec3_zero( lua_State* L ) {
    lua_vec3* vec3 = vec3_create( L );
    kmVec3Zero( vec3->data );
    return 1;
};
static int vec3_gethorizontalangle( lua_State* L ) {
    lua_vec3* v1;
    lua_vec3* v2;
    v1 = vec3_userdatap( L, -2 );
    v2 = vec3_userdatap( L, -1 );
    kmVec3GetHorizontalAngle( v1->data, v2->data ); /** Get the rotations
                                                                     that would make a
                                                                     (0,0,1) direction
                                                                     vector point in the
                                                                     same direction as
                                                                     this direction
                                                                     vector. */
    return 1;
};
static int vec3_rotationtodirection( lua_State* L ) {
    lua_vec3* v1;
    lua_vec3* v2;
    lua_vec3* v3;
    v2 = vec3_userdatap( L, -2 );
    v3 = vec3_userdatap( L, -1 );
    v1 = vec3_create( L );
    kmVec3RotationToDirection(
        v1->data, v2->data,
        v3->data ); /** Builds a direction vector from input vector. */
    return 1;
};
// static int vec3_projectontoplane( lua_State* L ) {
//    kmVec3ProjectOnToPlane( kmVec3 * pOut, const kmVec3* point,
//                            const struct kmPlane* plane );
//};


static int vec3_gc( lua_State* L ) {
    // dump shit here
    lua_vec3* vec3 = vec3_userdata( L );
    free( vec3->data );
    printf( "deleted it" );
    return 1;
}


float getVec( lua_vec3* vec, float i, char* key ) {
    float val;
    if ( i == 0 ) {
        val = vec->data->x;
    }
    if ( i == 1 ) {
        val = vec->data->y;
    }
    if ( i == 2 ) {
        val = vec->data->z;
    }
    if ( *key == 'x' ) {
        val = vec->data->x;
    }
    if ( *key == 'y' ) {
        val = vec->data->y;
    }
    if ( *key == 'z' ) {
        val = vec->data->z;
    }
    return val;
}

float setVec( lua_vec3* vec, float val, float i, char* key ) {
    if ( i == 0 ) {
        vec->data->x = val;
    }
    if ( i == 1 ) {
        vec->data->y = val;
    }
    if ( i == 2 ) {
        vec->data->z = val;
    }
    if ( *key == 'x' ) {
        vec->data->x = val;
    }
    if ( *key == 'y' ) {
        vec->data->y = val;
    }
    if ( *key == 'z' ) {
        vec->data->z = val;
    }
    return val;
}
