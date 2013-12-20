import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';

String vertexShaderSource = '''
attribute vec4 a_Position;
attribute vec2 a_TexCoord;
varying vec2 v_TexCoord;
void main() {
  gl_Position = a_Position;
  v_TexCoord = a_TexCoord;
}
''';

String fragmentShaderSource = '''
precision mediump float;
varying vec2 v_TexCoord;
uniform sampler2D u_Sampler;
void main() {
  gl_FragColor = texture2D(u_Sampler, v_TexCoord);
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
    -0.5,  0.5,   0.0, 1.0,
    -0.5, -0.5,   0.0, 0.0,
     0.5,  0.5,   1.0, 1.0,
     0.5, -0.5,   1.0, 0.0
  ]);
  
  Buffer vertexBuffer = gl.createBuffer();
  gl.bindBuffer(ARRAY_BUFFER, vertexBuffer);
  gl.bufferDataTyped(ARRAY_BUFFER, vertices, STATIC_DRAW);
  
  int a_Position = gl.getAttribLocation(program, 'a_Position');
  gl.vertexAttribPointer(a_Position, 2, FLOAT, false, 
      vertices.elementSizeInBytes * 4, 0);
  gl.enableVertexAttribArray(a_Position);
 
  int a_TexCoord = gl.getAttribLocation(program, 'a_TexCoord');
  gl.vertexAttribPointer(a_TexCoord, 2, FLOAT, false,
      vertices.elementSizeInBytes * 4, vertices.elementSizeInBytes * 2);
  gl.enableVertexAttribArray(a_TexCoord);
  
  // to load textures from disk:
  //  Run menu -> Manage Launches
  //  Browser arguments: --allow-file-access-from-files
  Texture texture = gl.createTexture();
  
  ImageElement image = new ImageElement(src:'k.png');
  image.onLoad.listen((e) {
    gl.pixelStorei(UNPACK_FLIP_Y_WEBGL, 1);
    
    gl.activeTexture(TEXTURE0);
    gl.bindTexture(TEXTURE_2D, texture);
    
    gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, LINEAR);
    gl.texImage2D(TEXTURE_2D, 0, RGB, RGB, UNSIGNED_BYTE, image);
    
    UniformLocation u_Sampler = gl.getUniformLocation(program, 'u_Sampler');
    gl.uniform1i(u_Sampler, 0);

    gl.clear(COLOR_BUFFER_BIT);
    gl.drawArrays(TRIANGLE_STRIP, 0, 4);
  });
  
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
}
