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
  UniformLocation u_FragColor = gl.getUniformLocation(program, 'u_FragColor');
  
  var points = new List<Point>();
  var colors = [
    [1.0, 0.0, 0.0, 1.0],
    [0.0, 1.0, 0.0, 1.0],
    [0.0, 0.0, 1.0, 1.0]
  ];
  
  void onMouseDown(MouseEvent event) {
    num x = event.client.x;
    num y = event.client.y;
    
    // remove any default styling offset applied to canvas position
    x -= canvas.offsetLeft;
    y -= canvas.offsetTop;
    
    // translate to center
    x -= (canvas.width  / 2);
    y -= (canvas.height / 2);
    
    // scale 0-1
    x /=  (canvas.width  / 2);
    y /= -(canvas.height / 2); // flip y-axis
    
    points.add(new Point(x, y));
    
    gl.clear(COLOR_BUFFER_BIT);
    
    int idx = -1;
    var rgba = null;
    for(int i = 0; i < points.length; ++i) {
      gl.vertexAttrib3f(a_Position, points[i].x, points[i].y, 0.0);
      
      idx = ++idx % colors.length;
      rgba = colors[idx];
      gl.uniform4f(u_FragColor, rgba[0], rgba[1], rgba[2], rgba[3]);
      
      // ignore the warning "Attribute 0 is disabled. This has signficant performance penalty"
      gl.drawArrays(POINTS, 0, 1);
    }
  }
  
  canvas.onMouseDown.listen((e) => onMouseDown(e) );
  
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
  gl.clear(COLOR_BUFFER_BIT);
}
