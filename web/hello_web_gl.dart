import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';

String vertexShaderSource = '''
attribute vec4 a_Position;
void main() {
  gl_Position = a_Position;
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
    -0.5,  0.5,
    -0.5, -0.5,
     0.5,  0.5,
     0.5, -0.5
  ]);
  
  Buffer vertexBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, vertices, STATIC_DRAW);
  
  int a_Position = gl.getAttribLocation(program, 'a_Position');
  gl.vertexAttribPointer(a_Position, 2, FLOAT, false, 0, 0);
  gl.enableVertexAttribArray(a_Position);
  
  UniformLocation u_FragColor = gl.getUniformLocation(program, 'u_FragColor');
  gl.uniform4f(u_FragColor, 1.0, 0.0, 0.0, 1.0);
  
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
  gl.clear(COLOR_BUFFER_BIT);
  
  var idx = 0;
  var modes = [TRIANGLE_STRIP, TRIANGLE_FAN];
  
  canvas.onMouseDown.listen((e){
    idx = ++idx % modes.length;

    gl.clear(COLOR_BUFFER_BIT);
    gl.drawArrays(modes[idx], 0, vertices.length ~/ 2); 
  });

  gl.drawArrays(modes[idx], 0, vertices.length ~/ 2); 
}
