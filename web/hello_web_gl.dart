import 'dart:html';
import 'dart:web_gl';

String vertexShaderSource = '''
attribute vec4 a_Position;
void main() {
  gl_Position = a_Position;
  gl_PointSize = 10.0;
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
  
  int a_Position = gl.getAttribLocation(program, 'a_Position');
  gl.vertexAttrib3f(a_Position, 0.0, 0.0, 0.0);
  
  UniformLocation u_FragColor = gl.getUniformLocation(program, 'u_FragColor');
  gl.uniform4f(u_FragColor, 1.0, 0.0, 0.0, 1.0);
  
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
  gl.clear(COLOR_BUFFER_BIT);
  
  // ignore the warning "Attribute 0 is disabled. This has signficant performance penalty"
  gl.drawArrays(POINTS, 0, 1);
}
