import 'dart:html';
import 'dart:web_gl';

String vertexShaderSource = '''
void main() {
  gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
  gl_PointSize = 10.0;
}
''';

String fragmentShaderSource = '''
void main() {
  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
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
  
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
  gl.clear(COLOR_BUFFER_BIT);
  
  // ignore the warning "Attribute 0 is disabled. This has signficant performance penalty"
  gl.drawArrays(POINTS, 0, 1);
}
