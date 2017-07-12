module Sprite exposing (..)

import WebGL as GL exposing (..)
import Math.Vector3 as Vec3 exposing (..)
import Math.Vector2 as Vec2 exposing (..)


type alias Vertex =
    { position : Vec2
    , color : Vec3
    }


type alias Varying =
    { vColor : Vec3
    }


spriteMesh : Mesh Vertex
spriteMesh =
    GL.triangles
        [ ( (Vertex (vec2 -1 1) (vec3 1 0 0))
          , (Vertex (vec2 1 1) (vec3 0 1 0))
          , (Vertex (vec2 -1 -1) (vec3 0 0 1))
          )
        , ( (Vertex (vec2 -1 -1) (vec3 1 0 0))
          , (Vertex (vec2 1 -1) (vec3 0 1 0))
          , (Vertex (vec2 1 1) (vec3 0 0 1))
          )
        ]


vertexShader : Shader Vertex {} Varying
vertexShader =
    [glsl|
      precision mediump float;
      attribute vec2 position;
      attribute vec3 color;
      varying vec3 vColor;
      void main () {
        gl_Position = vec4(position, 0.0, 1.0);
        vColor = color;
      }
    |]


fragmentShader : Shader {} {} Varying
fragmentShader =
    [glsl|
      precision mediump float;
      varying vec3 vColor;
      void main () {
        gl_FragColor = vec4(vColor, 1.);
      }
    |]


spriteEntity : Entity
spriteEntity =
    GL.entity
        vertexShader
        fragmentShader
        spriteMesh
        {}
