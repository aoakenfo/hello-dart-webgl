import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

String vertexShaderSource = '''
attribute vec4 a_Position;
attribute vec4 a_Color;
attribute vec4 a_Normal;
uniform mat4 u_MvpMatrix;
uniform vec3 u_LightColor;
uniform vec3 u_LightDirection;
uniform vec3 u_AmbientLightColor;
varying vec4 v_Color;

void main() {
  gl_Position = u_MvpMatrix * a_Position;
  
  vec3 normal = normalize(a_Normal.xyz);
  
  // dot product of light direction against orientation of surface (normal)
  // a negative dot product means θ is more than 90° and light is hitting the back of the surface
  float nDotL = max(dot(u_LightDirection, normal), 0.0);
  
  // take the surface color and mixin light color with intensity determined by angle
  vec3 diffuseColor = u_LightColor * a_Color.rgb * nDotL;

  // take the surface color and mix with ambient color
  vec3 ambientColor = u_AmbientLightColor * a_Color.rgb;

  // add colors together for final surface value
  v_Color = vec4(diffuseColor + ambientColor, a_Color.a);
}
''';

String fragmentShaderSource = '''
precision mediump float;
varying vec4 v_Color;
void main() {
  gl_FragColor = v_Color;
}
''';

void main() {
  
  CanvasElement canvas = querySelector('#canvas');
  RenderingContext gl = canvas.getContext3d();
  
  Shader vertexShader = gl.createShader(VERTEX_SHADER);
  gl.shaderSource(vertexShader, vertexShaderSource);
  gl.compileShader(vertexShader);
  print(gl.getShaderInfoLog(vertexShader));
  
  Shader fragmentShader = gl.createShader(FRAGMENT_SHADER);
  gl.shaderSource(fragmentShader, fragmentShaderSource);
  gl.compileShader(fragmentShader);
  
  Program program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);
  gl.useProgram(program);
  
  //    v6----- v5
  //   /|      /|
  //  v1------v0|
  //  | |     | |
  //  | |v7---|-|v4
  //  |/      |/
  //  v2------v3
  var vertices = new Float32List.fromList([
    1.0, 1.0, 1.0,  -1.0, 1.0, 1.0,  -1.0,-1.0, 1.0,   1.0,-1.0, 1.0,   // v0-v1-v2-v3 front
    1.0, 1.0, 1.0,   1.0,-1.0, 1.0,   1.0,-1.0,-1.0,   1.0, 1.0,-1.0,   // v0-v3-v4-v5 right
    1.0, 1.0, 1.0,   1.0, 1.0,-1.0,  -1.0, 1.0,-1.0,  -1.0, 1.0, 1.0,   // v0-v5-v6-v1 up
   -1.0, 1.0, 1.0,  -1.0, 1.0,-1.0,  -1.0,-1.0,-1.0,  -1.0,-1.0, 1.0,   // v1-v6-v7-v2 left
   -1.0,-1.0,-1.0,   1.0,-1.0,-1.0,   1.0,-1.0, 1.0,  -1.0,-1.0, 1.0,   // v7-v4-v3-v2 down
    1.0,-1.0,-1.0,  -1.0,-1.0,-1.0,  -1.0, 1.0,-1.0,   1.0, 1.0,-1.0    // v4-v7-v6-v5 back
  ]);
  
  var colors = new Float32List.fromList([
    1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,  1.0, 0.0, 0.0,    // v0-v1-v2-v3 front
    1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,  1.0, 0.0, 0.0,    // v0-v3-v4-v5 right
    1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,  1.0, 0.0, 0.0,    // v0-v5-v6-v1 up
    1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,  1.0, 0.0, 0.0,    // v1-v6-v7-v2 left
    1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,  1.0, 0.0, 0.0,    // v7-v4-v3-v2 down
    1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,  1.0, 0.0, 0.0     // v4-v7-v6-v5 back
  ]);
  
  var normals = new Float32List.fromList([
    0.0, 0.0, 1.0,   0.0, 0.0, 1.0,   0.0, 0.0, 1.0,   0.0, 0.0, 1.0,   // v0-v1-v2-v3 front
    1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   // v0-v3-v4-v5 right
    0.0, 1.0, 0.0,   0.0, 1.0, 0.0,   0.0, 1.0, 0.0,   0.0, 1.0, 0.0,   // v0-v5-v6-v1 up
   -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,   // v1-v6-v7-v2 left
    0.0,-1.0, 0.0,   0.0,-1.0, 0.0,   0.0,-1.0, 0.0,   0.0,-1.0, 0.0,   // v7-v4-v3-v2 down
    0.0, 0.0,-1.0,   0.0, 0.0,-1.0,   0.0, 0.0,-1.0,   0.0, 0.0,-1.0    // v4-v7-v6-v5 back                                                                          
  ]);
  
  var indices = new Uint8List.fromList([
     0, 1, 2,   0, 2, 3,    // front
     4, 5, 6,   4, 6, 7,    // right
     8, 9,10,   8,10,11,    // up
    12,13,14,  12,14,15,    // left
    16,17,18,  16,18,19,    // down
    20,21,22,  20,22,23     // back
  ]);
  
  // vertices --------------------------------------------------
  Buffer vertexBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, vertices, STATIC_DRAW);

  int a_Position = gl.getAttribLocation(program, 'a_Position');
  gl.vertexAttribPointer(a_Position, 3, FLOAT, false, 
      vertices.elementSizeInBytes * 3, 0);
  gl.enableVertexAttribArray(a_Position);
  
  // colors -----------------------------------------------------
  Buffer colorBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, colorBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, colors, STATIC_DRAW);
  
  int a_Color = gl.getAttribLocation(program, 'a_Color');
  gl.vertexAttribPointer(a_Color, 3, FLOAT, false,
      colors.elementSizeInBytes * 3, 0);
  gl.enableVertexAttribArray(a_Color);
  
  // normals ----------------------------------------------------
  Buffer normalBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, normalBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, normals, STATIC_DRAW);
  
  int a_Normal = gl.getAttribLocation(program, 'a_Normal');
  gl.vertexAttribPointer(a_Normal, 3, FLOAT, false,
      normals.elementSizeInBytes * 3, 0);
  gl.enableVertexAttribArray(a_Normal);

  // indices ---------------------------------------------------
  Buffer indexBuffer  = gl.createBuffer();
  gl.bindBuffer(ELEMENT_ARRAY_BUFFER, indexBuffer);
  gl.bufferData(ELEMENT_ARRAY_BUFFER, indices, STATIC_DRAW);
  
  // uniforms --------------------------------------------------
  UniformLocation u_LightColor = gl.getUniformLocation(program, 'u_LightColor');
  gl.uniform3f(u_LightColor, 1.0, 1.0, 1.0);
  
  UniformLocation u_LightDirection = gl.getUniformLocation(program, 'u_LightDirection');
  Vector3 lightDir = new Vector3(0.5, 3.0, 4.0);
  lightDir.normalize();
  gl.uniform3fv(u_LightDirection, lightDir.storage);
  
  UniformLocation u_AmbientLightColor = gl.getUniformLocation(program, 'u_AmbientLightColor');
  gl.uniform3f(u_AmbientLightColor, 0.2, 0.2, 0.2);
  
  // mvp -------------------------------------------------------
  num fovYRadians = PI / 4;
  num aspectRatio = canvas.width / canvas.height;
  num zNear = 1.0;
  num zFar = 100.0;
  Matrix4 projMatrix = makePerspectiveMatrix(fovYRadians, aspectRatio, zNear, zFar);
  
  Vector3 cameraPosition = new Vector3(3.0, 3.0, 7.0);
  Vector3 cameraFocusPosition = new Vector3(0.0, 0.0, 0.0);
  Vector3 upDirection = new Vector3(0.0, 1.0, 0.0);
  Matrix4 viewMatrix = makeViewMatrix(cameraPosition, cameraFocusPosition, upDirection);
  
  Matrix4 modelMatrix = new Matrix4.identity();
  
  UniformLocation u_MvpMatrix = gl.getUniformLocation(program, 'u_MvpMatrix');
  Matrix4 mvpMatrix = projMatrix * viewMatrix * modelMatrix;
  gl.uniformMatrix4fv(u_MvpMatrix, false, mvpMatrix.storage);
  
  // render ----------------------------------------------------
  gl.enable(DEPTH_TEST);
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  gl.drawElements(TRIANGLES, indices.length, UNSIGNED_BYTE, 0);
}
