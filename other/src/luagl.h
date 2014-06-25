/******************************************************************************
* Copyright (C) 2003-2004 by Fabio Guerra and Cleyde Marlyse.
* All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
******************************************************************************/
 
#ifndef __LUAGL_H__
#define __LUAGL_H__
 
#ifdef __cplusplus
extern "C" {
#endif
#import "lua.h"
#import "lauxlib.h"
#import "emma_math.h"
int luaopen_luagl( lua_State *L );

#ifdef __cplusplus
}
#endif


#endif
extern void stackDump (lua_State *L);
static const struct  luaL_Reg luagl_lib[];
static int luagl_viewport(lua_State *L);
static int flushing_lu(lua_State *L);
void luagl_flushing(lua_State *L);
void luagl_flushing_done(lua_State *L);
int EMMA_FLUSHING; 