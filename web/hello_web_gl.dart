import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'dart:async';

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
uniform sampler2D u_Sampler0;
uniform sampler2D u_Sampler1;
void main() {
  vec4 color0 = texture2D(u_Sampler0, v_TexCoord);
  vec4 color1 = texture2D(u_Sampler1, v_TexCoord);
  gl_FragColor = color0 * color1;
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
  Texture texture0 = gl.createTexture();
  Texture texture1 = gl.createTexture();

  ImageElement image1 = new ImageElement(src:'k.png');
  ImageElement image2 = new ImageElement(src:'h.png');
  
  Future.wait([image1.onLoad.first, image2.onLoad.first])
    .then((_) {
      
      gl.pixelStorei(UNPACK_FLIP_Y_WEBGL, 1);
      
      gl.activeTexture(TEXTURE0);
      gl.bindTexture(TEXTURE_2D, texture0);
      gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, LINEAR);
      gl.texImage2D(TEXTURE_2D, 0, RGB, RGB, UNSIGNED_BYTE, image1);
      UniformLocation u_Sampler0 = gl.getUniformLocation(program, 'u_Sampler0');
      gl.uniform1i(u_Sampler0, 0);
      
      gl.activeTexture(TEXTURE1);
      gl.bindTexture(TEXTURE_2D, texture1);
      gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, LINEAR);
      gl.texImage2D(TEXTURE_2D, 0, RGB, RGB, UNSIGNED_BYTE, image2);
      UniformLocation u_Sampler1 = gl.getUniformLocation(program, 'u_Sampler1');
      gl.uniform1i(u_Sampler1, 1);

      gl.clear(COLOR_BUFFER_BIT);
      gl.drawArrays(TRIANGLE_STRIP, 0, 4);
    
    });
  
  gl.clearColor(0.5, 0.5, 0.5, 1.0);
}
