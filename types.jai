/*==================================================================================================
File: mc_types.jai
Creation Date: 2023-02-24
Creator: Michael Campagnaro
Notice!: (C) Copyright 2017-2024 by Jelly Pixel, Inc. All Rights Reserved.
================================================================================================*/

f32 :: float32; // Same as float
f64 :: float64;

// TAU / 2
TAU_OVER_2   :: PI;
TAU64_OVER_2 :: PI64;

INVALID_V3_POS :: v3.{FLOAT32_MAX, FLOAT32_MAX, FLOAT32_MAX};
INVALID_V2_POS :: v2.{FLOAT32_MAX, FLOAT32_MAX};

// @note We assume the other components are valid!
is_valid_pos :: inline (pos: $T/PositionVectors) -> bool {
    return (pos.x != INVALID_V2_POS.x);
}

PositionVectors :: Type.[v2, v3]; // @relocate @jai-incomplete

///////////////////////////////
// Floating Point Vector types
///////////////////////////////

// @jai rename these vector types to upper-case V2, etc. will conflict with existing use of vector constructors, e.g. V2()
v2 :: Vector2;
v3 :: Vector3;
v4 :: Vector4;

Vector2i :: v2i;

// Useful to use these throughout the pipeline to ensure gamma correctness.
// @note If you change these from a variant to a normal struct then update the color transform code in vars.jai
Color_Linear  :: #type,isa v4;
Color_SRGB1   :: #type,isa v4;
Color_SRGB255 :: #type,isa v4;
Color_OKLab   :: #type,isa v4;

INVALID_COLOR :: v4.{-1, -1, -1, -1};

color_linear :: inline (c: v3, alpha: f32) -> Color_Linear { return .{ c.x, c.y, c.z, alpha }; }
color_srgb1  :: inline (c: v3, alpha: f32) -> Color_SRGB1  { return .{ c.x, c.y, c.z, alpha }; }


///////////////////////////////
// Integer Vector types
///////////////////////////////

v2i :: struct {
    x, y: s64;
    #place x;
    width, height: s64;
    #place x;
    component: [2] s64 = ---;
}

v2u :: struct {
    x, y: u64;
    #place x;
    width, height: u64;
    #place x;
    component: [2] u64 = ---;
}

v3i :: struct {
    x, y, z: s64;
    #place x;
    xy: v2i = ---;
    #place y;
    yz: v2i = ---;
    #place x;
    component: [3] s64 = ---;
}

v3u :: struct {
    x, y, z: u64;
    #place x;
    xy: v2u = ---;
    #place y;
    yz: v2u = ---;
    #place x;
    component: [3] u64 = ---;
}

v4i :: struct {
    x, y, z, w: s64;
    #place x;
    xy: v2i = ---;
    #place y;
    yz: v2i = ---;
    #place z;
    zw: v2i = ---;
    #place x;
    xyz: v3i = ---;
    #place y;
    yzw: v3i = ---;
    #place x;
    component: [4] s64 = ---;
}

v4u :: struct {
    x, y, z, w: u64;
    #place x;
    xy: v2u = ---;
    #place y;
    yz: v2u = ---;
    #place z;
    zw: v2u = ---;
    #place x;
    xyz: v3u = ---;
    #place y;
    yzw: v3u = ---;
    #place x;
    component: [4] u64 = ---;
}

//
// Vector Operators
//

// v2i
operator + :: (a: v2i, b: v2i) -> v2i {
    return .{a.x+b.x, a.y+b.y};
}

operator - :: (a: v2i, b: v2i) -> v2i {
    return .{a.x-b.x, a.y-b.y};
}

operator - :: (a: v2i) -> v2i {
    return .{-a.x, -a.y};
}

operator * :: (a: v2i, b: v2i) -> v2i {
    // I always found it questionable to overload * as Hadamard product, but, I guess
    // this is what it is for now. We'll see if it causes confusion.
    // One example of potential confusion: * on Quaternion does a totally
    // different thing from * on Vector4.      -jblow, 7 January 2023.

    return .{a.x*b.x, a.y*b.y};
}

operator * :: (a: v2i, k: float) -> v2  #symmetric {
    return .{a.x*k, a.y*k};
}

operator / :: (a: v2i, b: v2i) -> v2i {
    return .{a.x/b.x, a.y/b.y};
}

operator / :: (a: v2i, k: float) -> v2 {
    denom := 1 / k;
    return .{a.x*denom, a.y*denom};
}

operator / :: (k: float, a: v2i) -> v2 {
    return .{k/a.x, k/a.y};
}

//
//

Version :: struct {
    major, minor, build, revision: u32;
}

// @question should I force alignment to 16 bytes?
// @note These are stored COLUMN-MAJOR - e[column][row]!!!
Matrix4_Column :: struct {
    e: [4] [4] f32;
}

Matrix4Inv_Column :: struct {
    forward: Matrix4_Column;
    inverse: Matrix4_Column;
}

// For raycasting
Ray :: struct {
    origin: v3;
    dir:    v3;
}

RaycastHit :: struct {
    hit:       bool;
    distance:  f32;   // Distance to nearest hit.
    entity_id: u32;   // Hit entity id.
    entity:    *void; // Hit entity.
}

Plane :: struct {
    n: v3;
    d: f32;
}

GenVolume :: struct {
    // @note: Volumes include their min and their max. They are inclusive on both ends of the interval.
    min_x, min_y, min_z, max_x, max_y, max_z: s32;
    #place min_x;
    min: v3 = ---;
    #place max_x;
    max: v3 = ---;
}

///////////////////////////////////////////////////////
// Rect
///////////////////////////////////////////////////////

get_rect :: inline (xy: v2, dim: v2) -> MC_Rect {
    r := MC_Rect.{ pos=xy, dim=dim };
    return r;
}

get_rect :: inline (xy: v2, w: f32, h: f32) -> MC_Rect {
    r := MC_Rect.{ pos=xy, dim=.{w, h}};
    return r;
}

get_rect_center_dim :: (center: v2, dim: v2) -> MC_Rect {
    half_dim := dim * 0.5;
    result := MC_Rect.{
        x = center.x - half_dim.x,
        y = center.y - half_dim.y,
        w = dim.x,
        h = dim.y
    };
    return result;
}

get_rect_center :: inline (rect: MC_Rect) -> v2 {
    return rect.pos + rect.dim*0.5;
}

// An extension of the struct used in GetRect. We pass this to the GetRect module for its own use.
// I'm doing it this way instead of modifying the Rect struct in GetRect because if I did that then I can't have the
// rect utility procs above in this file unless I also import GetRect.
MC_Rect :: struct {
    x, y: f32;
    w, h: f32;
    #place x;
    pos: v2 = ---;
    #place w;
    dim: v2 = ---;
}

MC_Rect_i :: struct {
    x, y: s64;
    w, h: s64;
    #place x;
    pos: v2i = ---;
    #place w;
    dim: v2i = ---;
}

rect_i_to_rect :: inline (r: MC_Rect_i) -> MC_Rect {
    result := MC_Rect.{ xx r.x, xx r.y, xx r.w, xx r.h };
    return result;
}

// @jai-incomplete switch to storing x, y, width, height instead, like in GetRect. or just use Rect from GetRect...
Rect2 :: struct {
    x0, y0, x1, y1: f32;
    #place x0;
    min: v2 = ---;
    #place x1;
    max: v2 = ---;
}

Rect3 :: struct {
    x0, y0, z0, x1, y1, z1: f32;
    #place x0;
    min: v3 = ---;
    #place x1;
    max: v3 = ---;
}

Rect3i :: struct {
    x0, y0, z0, x1, y1, z1: s32;
    #place x0;
    min: v3i = ---;
    #place x1;
    max: v3i = ---;
}

// Used by the spatial grid.
GridPos :: struct {
    min: v3i;
    max: v3i;
}

#scope_file

#import "Math";
Basic :: #import "Basic";
