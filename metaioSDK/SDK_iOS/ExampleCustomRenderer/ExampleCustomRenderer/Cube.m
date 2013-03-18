#import "Cube.h"

#import <GLKit/GLKit.h>

#define BUFFER_OFFSET(i) ((uint8_t *)NULL + (i))

// Uniform index
enum
{
	UNIFORM_MODELVIEWPROJECTION_MATRIX,
	NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Shader input attribute index
enum
{
	ATTRIB_VERTEX,
	ATTRIB_COLOR,
	NUM_ATTRIBUTES
};

GLfloat gCubeVertexData[216] =
{
	// positionX, positionY, positionZ,	 colorR, colorG, colorB

	// Top (green)
	1.0f,  1.0f, -1.0f,		0.0f, 1.0f, 0.0f,
	-1.0f,  1.0f, -1.0f,		0.0f, 1.0f, 0.0f,
	1.0f,  1.0f,  1.0f,		0.0f, 1.0f, 0.0f,
	1.0f,  1.0f,  1.0f,		0.0f, 1.0f, 0.0f,
	-1.0f,  1.0f, -1.0f,		0.0f, 1.0f, 0.0f,
	-1.0f,  1.0f,  1.0f,		0.0f, 1.0f, 0.0f,

	// Bottom (orange)
	-1.0f, -1.0f, -1.0f,		1.0f, 0.5f, 0.0f,
	1.0f, -1.0f, -1.0f,		1.0f, 0.5f, 0.0f,
	-1.0f, -1.0f,  1.0f,		1.0f, 0.5f, 0.0f,
	-1.0f, -1.0f,  1.0f,		1.0f, 0.5f, 0.0f,
	1.0f, -1.0f, -1.0f,		1.0f, 0.5f, 0.0f,
	1.0f, -1.0f,  1.0f,		1.0f, 0.5f, 0.0f,

	// Front (red)
	1.0f,  1.0f,  1.0f,		1.0f, 0.0f, 0.0f,
	-1.0f,  1.0f,  1.0f,		1.0f, 0.0f, 0.0f,
	1.0f, -1.0f,  1.0f,		1.0f, 0.0f, 0.0f,
	1.0f, -1.0f,  1.0f,		1.0f, 0.0f, 0.0f,
	-1.0f,  1.0f,  1.0f,		1.0f, 0.0f, 0.0f,
	-1.0f, -1.0f,  1.0f,		1.0f, 0.0f, 0.0f,

	// Back (yellow)
	1.0f, -1.0f, -1.0f,		1.0f, 1.0f, 0.0f,
	-1.0f, -1.0f, -1.0f,		1.0f, 1.0f, 0.0f,
	1.0f,  1.0f, -1.0f,		1.0f, 1.0f, 0.0f,
	1.0f,  1.0f, -1.0f,		1.0f, 1.0f, 0.0f,
	-1.0f, -1.0f, -1.0f,		1.0f, 1.0f, 0.0f,
	-1.0f,  1.0f, -1.0f,		1.0f, 1.0f, 0.0f,

	// Left (blue)
	-1.0f,  1.0f, -1.0f,		0.0f, 0.0f, 1.0f,
	-1.0f, -1.0f, -1.0f,		0.0f, 0.0f, 1.0f,
	-1.0f,  1.0f,  1.0f,		0.0f, 0.0f, 1.0f,
	-1.0f,  1.0f,  1.0f,		0.0f, 0.0f, 1.0f,
	-1.0f, -1.0f, -1.0f,		0.0f, 0.0f, 1.0f,
	-1.0f, -1.0f,  1.0f,		0.0f, 0.0f, 1.0f,

	// Right (purple)
	1.0f, -1.0f, -1.0f,		1.0f, 0.0f, 1.0f,
	1.0f,  1.0f, -1.0f,		1.0f, 0.0f, 1.0f,
	1.0f, -1.0f,  1.0f,		1.0f, 0.0f, 1.0f,
	1.0f, -1.0f,  1.0f,		1.0f, 0.0f, 1.0f,
	1.0f,  1.0f, -1.0f,		1.0f, 0.0f, 1.0f,
	1.0f,  1.0f,  1.0f,		1.0f, 0.0f, 1.0f
};

@interface Cube ()

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end

@implementation Cube
{
	GLuint	m_shaderProgram;

	GLuint	m_vertexArray;
	GLuint	m_vertexBuffer;
}

- (id)init
{
	self = [super init];

	if (self)
	{
		[self loadShaders];

		glGenVertexArraysOES(1, &m_vertexArray);
		glBindVertexArrayOES(m_vertexArray);

		glGenBuffers(1, &m_vertexBuffer);
		glBindBuffer(GL_ARRAY_BUFFER, m_vertexBuffer);
		glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);

		glEnableVertexAttribArray(ATTRIB_VERTEX);
		glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
		glEnableVertexAttribArray(ATTRIB_COLOR);
		glVertexAttribPointer(ATTRIB_COLOR, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));

		glBindVertexArrayOES(0);
	}

	return self;
}

- (void)dealloc
{
	glDeleteBuffers(1, &m_vertexBuffer);
	glDeleteVertexArraysOES(1, &m_vertexArray);

	if (m_shaderProgram)
	{
		glDeleteProgram(m_shaderProgram);
		m_shaderProgram = 0;
	}

	[super dealloc];
}

- (void)draw:(GLKMatrix4)modelViewProjectionMatrix
{
	glBindVertexArrayOES(m_vertexArray);

	glUseProgram(m_shaderProgram);

	glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, modelViewProjectionMatrix.m);

	glBindBuffer(GL_ARRAY_BUFFER, m_vertexBuffer);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
	glEnableVertexAttribArray(ATTRIB_COLOR);
	glVertexAttribPointer(ATTRIB_COLOR, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));

	glDrawArrays(GL_TRIANGLES, 0, 36);

	glDisableVertexAttribArray(ATTRIB_VERTEX);
	glDisableVertexAttribArray(ATTRIB_COLOR);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
	GLuint vertShader, fragShader;
	NSString *vertShaderPathname, *fragShaderPathname;

	// Create shader program.
	m_shaderProgram = glCreateProgram();

	// Create and compile vertex shader.
	vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
	if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
	{
		NSLog(@"Failed to compile vertex shader");
		return NO;
	}

	// Create and compile fragment shader.
	fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
	{
		NSLog(@"Failed to compile fragment shader");
		return NO;
	}

	// Attach vertex shader to program.
	glAttachShader(m_shaderProgram, vertShader);

	// Attach fragment shader to program.
	glAttachShader(m_shaderProgram, fragShader);

	// Bind attribute locations.
	// This needs to be done prior to linking.
	glBindAttribLocation(m_shaderProgram, ATTRIB_VERTEX, "position");
	glBindAttribLocation(m_shaderProgram, ATTRIB_COLOR, "color");

	// Link program.
	if (![self linkProgram:m_shaderProgram])
	{
		NSLog(@"Failed to link program: %d", m_shaderProgram);

		if (vertShader)
		{
			glDeleteShader(vertShader);
			vertShader = 0;
		}
		if (fragShader)
		{
			glDeleteShader(fragShader);
			fragShader = 0;
		}
		if (m_shaderProgram)
		{
			glDeleteProgram(m_shaderProgram);
			m_shaderProgram = 0;
		}

		return NO;
	}

	// Get uniform locations.
	uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(m_shaderProgram, "modelViewProjectionMatrix");

	// Release vertex and fragment shaders.
	if (vertShader)
	{
		glDetachShader(m_shaderProgram, vertShader);
		glDeleteShader(vertShader);
	}
	if (fragShader)
	{
		glDetachShader(m_shaderProgram, fragShader);
		glDeleteShader(fragShader);
	}

	return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
	GLint status;
	const GLchar *source;

	source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!source)
	{
		NSLog(@"Failed to load vertex shader");
		return NO;
	}

	*shader = glCreateShader(type);
	glShaderSource(*shader, 1, &source, NULL);
	glCompileShader(*shader);

#if defined(DEBUG)
	GLint logLength;
	glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar *)malloc(logLength);
		glGetShaderInfoLog(*shader, logLength, &logLength, log);
		NSLog(@"Shader compile log:\n%s", log);
		free(log);
	}
#endif

	glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	if (status == GL_FALSE)
	{
		glDeleteShader(*shader);
		return NO;
	}

	return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
	GLint status;
	glLinkProgram(prog);

#if defined(DEBUG)
	GLint logLength;
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program link log:\n%s", log);
		free(log);
	}
#endif

	glGetProgramiv(prog, GL_LINK_STATUS, &status);
	if (status == 0)
		return NO;

	return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
	GLint logLength, status;

	glValidateProgram(prog);
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s", log);
		free(log);
	}

	glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
	if (status == GL_FALSE)
		return NO;

	return YES;
}

@end
