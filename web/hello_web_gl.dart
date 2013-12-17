import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';

String vertexShaderSource = '''
attribute vec4 a_Position;
uniform mat4 u_ModelMatrix;
void main() {
  gl_Position = u_ModelMatrix * a_Position;
}
''';

String fragmentShaderSource = '''
precision mediump float;
uniform vec4 u_FragColor;
void main() {
  gl_FragColor = u_FragColor;
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
    -0.5, -0.5,
     0.0,  0.5,
     0.5, -0.5
  ]);
  
  Buffer vertexBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, vertices, STATIC_DRAW);
  
  int a_Position = gl.getAttribLocation(program, 'a_Position');
  gl.vertexAttribPointer(a_Position, 2, FLOAT, false, 0, 0);
  gl.enableVertexAttribArray(a_Position);
  
  var Tx = 0.0;
  var Ty = 0.5;
  var Tz = 0.0;
  // column major order
  var modelMatrix = new Float32List.fromList([
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      Tx,  Ty,  Tz,  1.0
  ]);
  
  UniformLocation u_ModelMatrix = gl.getUniformLocation(program, 'u_ModelMatrix');
  gl.uniformMatrix4fv(u_ModelMatrix, false, modelMatrix);
  
  UniformLocation u_FragColor = gl.getUniformLocation(program, 'u_FragColor');
  gl.uniform4f(u_FragColor, 1.0, 0.0, 0.0, 1.0);
  
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
  gl.clear(COLOR_BUFFER_BIT);
  
  gl.drawArrays(TRIANGLES, 0, 3); 
}
