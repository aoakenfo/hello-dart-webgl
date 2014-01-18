import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

String vertexShaderSource = '''
attribute vec4 a_Position;
attribute vec4 a_Color;
uniform mat4 u_MvpMatrix;
varying vec4 v_Color;
void main() {
  gl_Position = u_MvpMatrix * a_Position;
  v_Color = a_Color;
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
     // position          // color
     1.0,  1.0,  1.0,     1.0,  1.0,  1.0,  // v0 white
    -1.0,  1.0,  1.0,     1.0,  0.0,  1.0,  // v1 magenta
    -1.0, -1.0,  1.0,     1.0,  0.0,  0.0,  // v2 red
     1.0, -1.0,  1.0,     1.0,  1.0,  0.0,  // v3 yellow
     1.0, -1.0, -1.0,     0.0,  1.0,  0.0,  // v4 green
     1.0,  1.0, -1.0,     0.0,  1.0,  1.0,  // v5 cyan
    -1.0,  1.0, -1.0,     0.0,  0.0,  1.0,  // v6 blue
    -1.0, -1.0, -1.0,     0.0,  0.0,  0.0   // v7 black 
  ]);
  
  var indices = new Uint8List.fromList([
     0, 1, 2,   0, 2, 3,  // front
     0, 3, 4,   0, 4, 5,  // right
     0, 5, 6,   0, 6, 1,  // up
     1, 6, 7,   1, 7, 2,  // left
     7, 4, 3,   7, 3, 2,  // down
     4, 7, 6,   4, 6, 5   // back
  ]);
  
  Buffer vertexBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, vertices, STATIC_DRAW);
  
  Buffer indexBuffer  = gl.createBuffer();
  gl.bindBuffer(ELEMENT_ARRAY_BUFFER, indexBuffer);
  gl.bufferData(ELEMENT_ARRAY_BUFFER, indices, STATIC_DRAW);
  
  int a_Position = gl.getAttribLocation(program, 'a_Position');
  gl.vertexAttribPointer(a_Position, 3, FLOAT, false, 
      vertices.elementSizeInBytes * 6, 0);
  gl.enableVertexAttribArray(a_Position);
  
  int a_Color = gl.getAttribLocation(program, 'a_Color');
  gl.vertexAttribPointer(a_Color, 3, FLOAT, false,
      vertices.elementSizeInBytes * 6, vertices.elementSizeInBytes * 3);
  gl.enableVertexAttribArray(a_Color);
  
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
  
  gl.enable(DEPTH_TEST);
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
  
  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  
  gl.drawElements(TRIANGLES, indices.length, UNSIGNED_BYTE, 0);
}
