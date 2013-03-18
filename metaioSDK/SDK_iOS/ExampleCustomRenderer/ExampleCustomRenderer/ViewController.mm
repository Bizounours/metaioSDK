// Define your license here. For more information, please visit http://dev.metaio.com - you can add
// a new application at http://dev.metaio.com/get-developer-key/
#define SDK_LICENSE "gFEbthC5hFUbW881D7MmlryjFWwTqorPoExQyL2JZCo="
#if !defined (SDK_LICENSE)
#error Please provide the license string for your application
#endif

// Make sure that we're building this with an iOS SDK that at least supports iOS5
#ifndef __IPHONE_5_0
#error Please update to an iOS SDK that supports at least iOS5. iOS applications should always be built with the latest SDK
#endif

#import "CameraImageRenderer.h"
#import "Cube.h"
#import "ViewController.h"

@interface ViewController ()
{
	CameraImageRenderer*		m_pCameraImageRenderer;
	
	Cube*						m_pCube;

	GLKMatrix4					m_modelViewProjectionMatrix;

	metaio::IMetaioSDKIOS*		m_pMetaioSDK;
	metaio::ISensorsComponent*	m_pSensors;
	bool						m_SDKReady;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)initMetaioSDK;
- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController

- (void)dealloc
{
	[self tearDownGL];

	if ([EAGLContext currentContext] == self.context)
		[EAGLContext setCurrentContext:nil];
	
	[_context release];

	if (m_pMetaioSDK)
    {
        delete m_pMetaioSDK;
        m_pMetaioSDK = NULL;
    }

    if (m_pSensors)
    {
        delete m_pSensors;
        m_pSensors = NULL;
    }

	[m_pCameraImageRenderer release];

	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];

	if (!self.context)
		NSLog(@"Failed to create ES context");
	
	GLKView *view = (GLKView *)self.view;
	view.context = self.context;
	view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
	
	[self setupGL];

	[self initMetaioSDK];

	m_pCameraImageRenderer = [[CameraImageRenderer alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (m_pMetaioSDK)
	{
		m_pMetaioSDK->startCamera(0, 320, 240);

		// load our tracking configuration
		NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast" ofType:@"xml" inDirectory:@"Assets"];

		if (trackingDataFile)
		{
			bool success = m_pMetaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
			if (!success)
				NSLog(@"Failed to load tracking configuration");
		}
		else
			NSLog(@"Could not find tracking configuration file");
	}

	[self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (m_pMetaioSDK)
        m_pMetaioSDK->stopCamera();

	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (m_pMetaioSDK)
		m_pMetaioSDK->setScreenRotation(metaio::getScreenRotationForInterfaceOrientation(toInterfaceOrientation));

	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];

	if ([self isViewLoaded] && ([[self view] window] == nil))
	{
		self.view = nil;
		
		[self tearDownGL];
		
		if ([EAGLContext currentContext] == self.context)
			[EAGLContext setCurrentContext:nil];
		
		self.context = nil;
	}

	// Dispose of any resources that can be recreated.
}

- (void)initMetaioSDK
{
	// Create metaio SDK instance
	m_pMetaioSDK = metaio::CreateMetaioSDKIOS(SDK_LICENSE);
    if (!m_pMetaioSDK)
    {
        NSLog(@"SDK instance could not be created. Please verify the signature string.");
        return;
    }

    m_pSensors = metaio::CreateSensorsComponent();
    if (!m_pSensors)
    {
        NSLog(@"Could not create the sensors interface");
        return;
    }
    m_pMetaioSDK->registerSensorsComponent(m_pSensors);

	// Set up custom rendering (metaio SDK will only do tracking and not render any objects itself)
	m_pMetaioSDK->initializeRenderer(0, 0, metaio::getScreenRotationForInterfaceOrientation(self.interfaceOrientation), metaio::ERENDER_SYSTEM_NULL, NULL);

    // Register callback method for receiving camera frames and the SDK ready event
    m_pMetaioSDK->registerDelegate(self);
}

- (void)setupGL
{
	[EAGLContext setCurrentContext:self.context];
	
	glEnable(GL_DEPTH_TEST);

	m_pCube = [[Cube alloc] init];
}

- (void)tearDownGL
{
	[EAGLContext setCurrentContext:self.context];
	
	[m_pCameraImageRenderer release];
	m_pCameraImageRenderer = nil;

	[m_pCube release];
	m_pCube = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
	// Note: The metaio SDK itself does not render anything here because we initialized it with
	// the NULL renderer. This call is necessary to get the camera image and update tracking.
	m_pMetaioSDK->render();

	m_pMetaioSDK->requestCameraImage();
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	glClearColor(0, 0, 0, 1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	metaio::TrackingValues trackingValues = m_pMetaioSDK->getTrackingValues(1);

	glDisable(GL_DEPTH_TEST);

	[m_pCameraImageRenderer draw:m_pMetaioSDK->getScreenRotation() renderTargetAspect:(float)rect.size.width/rect.size.height];

	glEnable(GL_DEPTH_TEST);

	if (m_SDKReady && trackingValues.quality > 0)
	{
		float modelMatrix[16];

		// preMultiplyWithStandardViewMatrix=false parameter explained below
		m_pMetaioSDK->getTrackingValues(1, modelMatrix, false, true);

		// With getTrackingValues(..., preMultiplyWithStandardViewMatrix=true), the metaio SDK
		// would calculate a model-view matrix, i.e. a standard look-at matrix (looking from the
		// origin along the negative Z axis) multiplied by the model matrix (tracking pose).
		// Here we use our own view matrix for demonstration purposes (parameter set to false),
		// for instance if you have your own camera implementation. Additionally, the cube is
		// scaled up by factor 40 and translated by 40 units in order to have its back face lie
		// on the tracked image.

		// Use typical view matrix (camera looking along negative Z axis, see previous hint)
		m_modelViewProjectionMatrix = GLKMatrix4Identity;

		// The order is important here: We first want to scale the cube, then put it 40 units
		// higher (because it's rendered from -1 to +1 on all axes, after scaling that's +-40)
		// so that its back face lies on the tracked image and move it into place
		// (transformation to the coordinate system of the tracked image).

		// MODEL_VIEW = LOOK_AT * MODEL
		m_modelViewProjectionMatrix = GLKMatrix4Multiply(m_modelViewProjectionMatrix, GLKMatrix4MakeWithArray(modelMatrix));

		m_modelViewProjectionMatrix = GLKMatrix4Translate(m_modelViewProjectionMatrix, 0, 0, 40);

		// All sides of the cube will have length 80
		m_modelViewProjectionMatrix = GLKMatrix4Scale(m_modelViewProjectionMatrix, 40, 40, 40);

		float projMatrix[16];

		// Use right-handed projection matrix
		m_pMetaioSDK->getProjectionMatrix(projMatrix, true);

		// Since we render the camera image ourselves, and there are devices whose screen aspect
		// ratio does not match the camera aspect ratio, we have to make up for the stretched
		// and cropped camera image. The CameraImageRenderer class gives us values by which
		// pixels should be scaled from the middle of the screen (e.g. getScaleX() > 1 if the
		// camera image is wider than the screen and thus its width is displayed cropped).
		projMatrix[0] *= m_pCameraImageRenderer.scaleX;
		projMatrix[5] *= m_pCameraImageRenderer.scaleY;

		// MVP = P * MV
		m_modelViewProjectionMatrix = GLKMatrix4Multiply(GLKMatrix4MakeWithArray(projMatrix), m_modelViewProjectionMatrix);

		[m_pCube draw:m_modelViewProjectionMatrix];
	}
}

#pragma mark - MetaioSDKDelegate methods

- (void)onNewCameraFrame:(metaio::ImageStruct*)cameraFrame
{
	[m_pCameraImageRenderer updateFrame:cameraFrame];
}

- (void)onSDKReady
{
	m_SDKReady = true;
}

@end
