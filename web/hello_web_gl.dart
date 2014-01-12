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
  
  var vertices = new Float32List.fromList([
    // position         // color
    0.0,  1.0,  0.0,    0.0,  0.0,  1.0, // front blue triangle 
   -0.5, -1.0,  0.0,    0.0,  0.0,  1.0,
    0.5, -1.0,  0.0,    0.0,  0.0,  1.0, 
    
    0.0,  1.0, -2.0,    1.0,  1.0,  0.0, // middle yellow triangle
   -0.5, -1.0, -2.0,    1.0,  1.0,  0.0,
    0.5, -1.0, -2.0,    1.0,  1.0,  0.0, 

    0.0,  1.0, -4.0,    0.0,  1.0,  0.0, // back green triangle
   -0.5, -1.0, -4.0,    0.0,  1.0,  0.0,
    0.5, -1.0, -4.0,    0.0,  1.0,  0.0

  ]);
  
  Buffer vertexBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, vertices, STATIC_DRAW);
  
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
  num zFar = 10.0;
  Matrix4 projMatrix = makePerspectiveMatrix(fovYRadians, aspectRatio, zNear, zFar);
  
  Vector3 cameraPosition = new Vector3(0.0, 0.0, 5.0);
  Vector3 cameraFocusPosition = new Vector3(0.0, 0.0, -100.0);
  Vector3 upDirection = new Vector3(0.0, 1.0, 0.0);
  Matrix4 viewMatrix = makeViewMatrix(cameraPosition, cameraFocusPosition, upDirection);
  
  Matrix4 modelMatrix = new Matrix4.identity();
  modelMatrix.setTranslation(new Vector3(-1.0, 0.0, 0.0));
  
  Matrix4 mvpMatrix = projMatrix * viewMatrix * modelMatrix;
  UniformLocation u_MvpMatrix = gl.getUniformLocation(program, 'u_MvpMatrix');
  gl.uniformMatrix4fv(u_MvpMatrix, false, mvpMatrix.storage);

  // try commenting out depth test
  gl.enable(DEPTH_TEST);
  
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
  
  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  gl.drawArrays(TRIANGLES, 0, vertices.length ~/ 6);

  modelMatrix.setTranslation(new Vector3(1.0, 0.0, 0.0));
  mvpMatrix = projMatrix * viewMatrix * modelMatrix;
  gl.uniformMatrix4fv(u_MvpMatrix, false, mvpMatrix.storage);
  gl.drawArrays(TRIANGLES, 0, vertices.length ~/ 6);
}
