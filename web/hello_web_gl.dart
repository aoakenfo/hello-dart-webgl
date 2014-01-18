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
     1.0, 1.0, 1.0,  -1.0, 1.0, 1.0,  -1.0,-1.0, 1.0,   1.0,-1.0, 1.0,  // v0-v1-v2-v3 front
     1.0, 1.0, 1.0,   1.0,-1.0, 1.0,   1.0,-1.0,-1.0,   1.0, 1.0,-1.0,  // v0-v3-v4-v5 right
     1.0, 1.0, 1.0,   1.0, 1.0,-1.0,  -1.0, 1.0,-1.0,  -1.0, 1.0, 1.0,  // v0-v5-v6-v1 up
    -1.0, 1.0, 1.0,  -1.0, 1.0,-1.0,  -1.0,-1.0,-1.0,  -1.0,-1.0, 1.0,  // v1-v6-v7-v2 left
    -1.0,-1.0,-1.0,   1.0,-1.0,-1.0,   1.0,-1.0, 1.0,  -1.0,-1.0, 1.0,  // v7-v4-v3-v2 down
     1.0,-1.0,-1.0,  -1.0,-1.0,-1.0,  -1.0, 1.0,-1.0,   1.0, 1.0,-1.0   // v4-v7-v6-v5 back 
  ]);
  
  var colors = new Float32List.fromList([
    0.4, 0.4, 1.0,  0.4, 0.4, 1.0,  0.4, 0.4, 1.0,  0.4, 0.4, 1.0,  // v0-v1-v2-v3 front(blue)
    0.4, 1.0, 0.4,  0.4, 1.0, 0.4,  0.4, 1.0, 0.4,  0.4, 1.0, 0.4,  // v0-v3-v4-v5 right(green)
    1.0, 0.4, 0.4,  1.0, 0.4, 0.4,  1.0, 0.4, 0.4,  1.0, 0.4, 0.4,  // v0-v5-v6-v1 up(red)
    1.0, 1.0, 0.4,  1.0, 1.0, 0.4,  1.0, 1.0, 0.4,  1.0, 1.0, 0.4,  // v1-v6-v7-v2 left
    1.0, 1.0, 1.0,  1.0, 1.0, 1.0,  1.0, 1.0, 1.0,  1.0, 1.0, 1.0,  // v7-v4-v3-v2 down
    0.4, 1.0, 1.0,  0.4, 1.0, 1.0,  0.4, 1.0, 1.0,  0.4, 1.0, 1.0   // v4-v7-v6-v5 back
  ]);
  
  var indices = new Uint8List.fromList([
     0, 1, 2,   0, 2, 3,    // front
     4, 5, 6,   4, 6, 7,    // right
     8, 9,10,   8,10,11,    // up
    12,13,14,  12,14,15,    // left
    16,17,18,  16,18,19,    // down
    20,21,22,  20,22,23     // back
  ]);
  
  Buffer vertexBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, vertices, STATIC_DRAW);

  int a_Position = gl.getAttribLocation(program, 'a_Position');
  gl.vertexAttribPointer(a_Position, 3, FLOAT, false, 
      vertices.elementSizeInBytes * 3, 0);
  gl.enableVertexAttribArray(a_Position);
  
  Buffer colorBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, colorBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, colors, STATIC_DRAW);
  
  int a_Color = gl.getAttribLocation(program, 'a_Color');
  gl.vertexAttribPointer(a_Color, 3, FLOAT, false,
      vertices.elementSizeInBytes * 3, 0);
  gl.enableVertexAttribArray(a_Color);
  
  Buffer indexBuffer  = gl.createBuffer();
  gl.bindBuffer(ELEMENT_ARRAY_BUFFER, indexBuffer);
  gl.bufferData(ELEMENT_ARRAY_BUFFER, indices, STATIC_DRAW);
  
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
  //modelMatrix.rotateY(PI );
  
  UniformLocation u_MvpMatrix = gl.getUniformLocation(program, 'u_MvpMatrix');
  Matrix4 mvpMatrix = projMatrix * viewMatrix * modelMatrix;
  gl.uniformMatrix4fv(u_MvpMatrix, false, mvpMatrix.storage);
  
  gl.enable(DEPTH_TEST);
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
  
  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  
  gl.drawElements(TRIANGLES, indices.length, UNSIGNED_BYTE, 0);
}
