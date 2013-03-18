
using UnityEngine;
using System.Collections;


public class MainMenu : MonoBehaviour {
	
	public enum TUTORIALS {SIMPLE_TUTORIALS = 0, HELLO_WORLD = 1, ADVANCE_TRACKING = 2, LOCATION_BASED = 3, DEGREES_360 = 4, ADVANCED_TUTORIALS = 5, MOVING_OBJ_OR_CAM = 6, SLAM_3D = 7};
	private TUTORIALS currentTutorial = TUTORIALS.HELLO_WORLD;
	
	private int numberOfTutorials = 0;
	
	private enum STATES {LISTVIEW, TUTORIAL};
	private STATES state = STATES.LISTVIEW;
	
	public GUIStyle helloWorldPreview;
	public GUIStyle AdvancedTrackingPreview;
	public GUIStyle LocationBasedPreview;
	public GUIStyle Degrees360Preview;
	public GUIStyle MovingCamPreview;
	public GUIStyle InstantTrackingPreview;
	
	public GUIStyle bigHeadlineStyle;
	public GUIStyle headlineTextStyle;
	public GUIStyle descriptionTextStyle;
	public GUIStyle buttonTextStyle;
	
	private float scrollPosition = 0;
	private float resistance = 1;
	
	private float maxScrollPosition = 0;
	private float minScrollPosition = 0;
	private float scrollHeight = 0;
	private float deltaY = 0;
	private float startTime;
	private bool isScrolling = false;
	
	private float SizeFactor;
	
	private ScrollViewItem[] scrollViewItems;
	
	// Use this for initialization
	void Start () {
		
		numberOfTutorials = System.Enum.GetValues(typeof(TUTORIALS)).Length;
		
		scrollViewItems = new ScrollViewItem[numberOfTutorials];
		
		SizeFactor = GUIUtilities.SizeFactor;
		
		foreach(int tut in System.Enum.GetValues(typeof(TUTORIALS)))
		{
			if(tut == 0)
			{
				scrollViewItems[tut] = new HeadlineScrollItem("Basic Tutorials", bigHeadlineStyle);	
			}
			else if(tut == 5)
			{
				scrollViewItems[tut] = new HeadlineScrollItem("Advanced Tutorials", bigHeadlineStyle);
			}
			else
			{
				scrollViewItems[tut] = new TutorialScrollItem(
					getTutorialIcon((TUTORIALS)tut),
					headlineTextStyle,
					descriptionTextStyle,
					getTutorialName((TUTORIALS)tut),
					getTutorialDescription((TUTORIALS)tut),
					(TUTORIALS)tut,
					this);
			}
			minScrollPosition -= scrollViewItems[tut].getHeight();
			scrollHeight += scrollViewItems[tut].getHeight();
		}
		
		minScrollPosition += Screen.height;
		
		if(PlayerPrefs.HasKey("currentTutorial") && PlayerPrefs.HasKey("backFromARScene"))
		{
			if(PlayerPrefs.GetInt("backFromARScene") == 1)
				goToTutorial((TUTORIALS)PlayerPrefs.GetInt("currentTutorial"));
			
			PlayerPrefs.DeleteKey("currentTutorial");
			PlayerPrefs.DeleteKey("backFromARScene");
		}
	}
	
	private void calcSizes () {
		maxScrollPosition = 0;
		minScrollPosition = 0;
		scrollHeight = 0;
			
		foreach(int tut in System.Enum.GetValues(typeof(TUTORIALS)))
		{
		
			minScrollPosition -= scrollViewItems[tut].getHeight();
			scrollHeight += scrollViewItems[tut].getHeight();
		}
		
		minScrollPosition += Screen.height;
	
	}
	
	// Update is called once per frame
	void Update () {
		
		if (Input.GetKeyDown(KeyCode.Escape))
		{
			if(state == STATES.LISTVIEW)
				Application.Quit();
			else
				state = STATES.LISTVIEW;
		}
		
		
		SizeFactor = GUIUtilities.SizeFactor;
		
		calcSizes();
		
		if(state == STATES.LISTVIEW)
		{
			float oldScrollPosition = scrollPosition;
	
	
			if (Input.touchCount > 0) {	
				Touch touch = Input.GetTouch (0);
	         	if (touch.phase == TouchPhase.Moved) {
	
					deltaY = (touch.deltaPosition * (Time.deltaTime / touch.deltaTime)).y;
					scrollPosition = Mathf.Clamp ((scrollPosition - deltaY), minScrollPosition, maxScrollPosition);
					startTime = Time.time;
					isScrolling = true;
	         	}
			}
		 
			if (Input.touchCount < 1) {	
				deltaY = Mathf.Lerp (deltaY, 0, (Time.time - startTime)) * resistance;
				scrollPosition = Mathf.Clamp ((scrollPosition - deltaY), minScrollPosition, maxScrollPosition);
			}
			
			
			if ((Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Ended))
				isScrolling = false;
		}
	}
	
	
	void OnGUI () {
		
		//GUI.Label(new Rect(Screen.width - Screen.height*2, 0, Screen.height*2, Screen.height),"", backGround);
		
		switch(state)
		{
			case STATES.LISTVIEW:
				renderListview();
				break;
				
			case STATES.TUTORIAL:
				renderTutorialview();
				break;
		}
	}
	
	private void renderTutorialview(){
		
		if(GUIUtilities.ButtonWithText(new Rect(
			Screen.width - 200*SizeFactor,
			Screen.height - 100*SizeFactor,
			200*SizeFactor,
			100*SizeFactor),"Back",null,buttonTextStyle)) {
				state = STATES.LISTVIEW;
			}
		
		if(GUIUtilities.ButtonWithText(new Rect(
			0,
			Screen.height - 100*SizeFactor,
			300*SizeFactor,
			100*SizeFactor),"Start",null,buttonTextStyle)) {
			
				PlayerPrefs.SetInt("currentTutorial", (int)currentTutorial);
				Application.LoadLevel(getSceneName(currentTutorial));
			}
		
			
		GUI.Label(new Rect(
			40*SizeFactor,
			40*SizeFactor,
			220*SizeFactor,
			220*SizeFactor),"",getTutorialIcon(currentTutorial));
		
		GUIUtilities.Text(new Rect(
			300*SizeFactor,
			50*SizeFactor,  
			Screen.width - (300*SizeFactor), 
			GUIUtilities.getSize(headlineTextStyle,new GUIContent(getTutorialName(currentTutorial))).y)
			,getTutorialName(currentTutorial), headlineTextStyle);
		

		GUIUtilities.Text(new Rect(
			300*SizeFactor, 
			(50+20)*SizeFactor + GUIUtilities.getSize(headlineTextStyle,new GUIContent(getTutorialName(currentTutorial))).y*2,
			Screen.width - (300*SizeFactor),
			10),getTutorialDescription(currentTutorial), descriptionTextStyle);
		
		
		switch (currentTutorial) {
			
		case TUTORIALS.HELLO_WORLD:
			
			break;
			
		case TUTORIALS.LOCATION_BASED:
			
			break;
		
		case TUTORIALS.ADVANCE_TRACKING:
			
			break;
			
		case TUTORIALS.MOVING_OBJ_OR_CAM:
			
			break;
			
		case TUTORIALS.SLAM_3D:
			
			break;
			
		case TUTORIALS.DEGREES_360:
			
			break;
				
		}
	}
	
	private void renderListview()
	{
					
		GUI.BeginGroup (new Rect (0,scrollPosition, Screen.width, scrollHeight));
		
		int index = 0;
		int height = 0;
		
		foreach(int tut in System.Enum.GetValues(typeof(TUTORIALS)))
		{
			
			GUI.BeginGroup(new Rect(0, height, Screen.width, scrollViewItems[tut].getHeight()));
			scrollViewItems[tut].renderMe(isScrolling);
			GUI.EndGroup();
			
			height += scrollViewItems[tut].getHeight();
			index++;
		}
		
		GUI.EndGroup();	
	
	}
	
	public void goToTutorial(TUTORIALS tutorial)
	{
		state = STATES.TUTORIAL;
		currentTutorial = tutorial;
	}
			
	private string getTutorialName(TUTORIALS tutorial)
	{
		switch (tutorial) {
			
		case TUTORIALS.HELLO_WORLD:
			return "Hello, World!";
		case TUTORIALS.ADVANCE_TRACKING:
			return "Tracking samples";
		case TUTORIALS.DEGREES_360:
			return "360 Degrees";
		case TUTORIALS.LOCATION_BASED:
			return "Location based AR";
		case TUTORIALS.MOVING_OBJ_OR_CAM:
			return "Moving the Camera";
		case TUTORIALS.SLAM_3D:
			return "Instant tracking";
		}
		
		return "name not defined";
	}
	
	private string getTutorialDescription(TUTORIALS tutorial)
	{
		switch (tutorial) {
			
		case TUTORIALS.HELLO_WORLD:
			return "Here you will learn how to assign content to tracking reference.";
		case TUTORIALS.ADVANCE_TRACKING:
			return "Learn different tracking reference types.";
		case TUTORIALS.DEGREES_360:
			return "Learn how to position the objects around you.";
		case TUTORIALS.LOCATION_BASED:
			return "Learn about LLA coordinates and POI.";
		case TUTORIALS.MOVING_OBJ_OR_CAM:
			return "Moving the Camera to be able to use unity's physics engine.";
		case TUTORIALS.SLAM_3D:
			return "Introduction to instant 2D and 3D tracking.";
		}
		
		return "name not defined";
	}
	
	private GUIStyle getTutorialIcon(TUTORIALS tutorial)
	{
		switch (tutorial) {
			
		case TUTORIALS.HELLO_WORLD:
			return helloWorldPreview;
		case TUTORIALS.ADVANCE_TRACKING:
			return AdvancedTrackingPreview;
		case TUTORIALS.DEGREES_360:
			return Degrees360Preview;
		case TUTORIALS.LOCATION_BASED:
			return LocationBasedPreview;
		case TUTORIALS.MOVING_OBJ_OR_CAM:
			return MovingCamPreview;
		case TUTORIALS.SLAM_3D:
			return InstantTrackingPreview;
		}
		
		return helloWorldPreview;
	}

	private string getSceneName(TUTORIALS tutorial)
	{
		switch (tutorial) {
			
		case TUTORIALS.HELLO_WORLD:
			return "HelloWorld";
		case TUTORIALS.ADVANCE_TRACKING:
			return "AdvancedTracking";
		case TUTORIALS.DEGREES_360:
			return "360Degrees";
		case TUTORIALS.LOCATION_BASED:
			return "LocationBasedTracking";
		case TUTORIALS.MOVING_OBJ_OR_CAM:
			return "MovingCamera";
		case TUTORIALS.SLAM_3D:
			return "Slam3D";
		}
		
		return "";
	}
}

public abstract class ScrollViewItem
{
	public abstract void renderMe(bool isScrolling);
	public abstract int getHeight();
}

public class HeadlineScrollItem : ScrollViewItem
{
	private string headLine;
	private GUIStyle bigHeadlineStyle;
	
	public HeadlineScrollItem (string headLine, GUIStyle bigHeadlineStyle)
	{
		this.headLine = headLine;
		this.bigHeadlineStyle = bigHeadlineStyle;
	}
	
	public override void renderMe (bool isScrolling)
	{
		GUIUtilities.Text(new Rect(
			10*GUIUtilities.SizeFactor,
			30*GUIUtilities.SizeFactor,
			Screen.width,
			GUIUtilities.getSize(bigHeadlineStyle, new GUIContent(headLine)).y)
			, this.headLine, bigHeadlineStyle);
	}
	
	public override int getHeight ()
	{
		return (int)(GUIUtilities.getSize(bigHeadlineStyle, new GUIContent(headLine)).y + 50 * GUIUtilities.SizeFactor);
	}	
}

public class TutorialScrollItem : ScrollViewItem
{
	private GUIStyle icon;
	private GUIStyle headlineStyle;
	private GUIStyle descriptionStyle;
	private string headline;
	private string description;
	private MainMenu.TUTORIALS tutorial;
	private MainMenu mainMenu;
	
	public TutorialScrollItem (GUIStyle icon, GUIStyle headlineStyle, GUIStyle descriptionStyle, string headline, string description, MainMenu.TUTORIALS tutorial, MainMenu mainMenu)
	{
		this.icon = icon;
		this.headlineStyle = headlineStyle;
		this.descriptionStyle = descriptionStyle;
		this.headline = headline;
		this.description = description;
		this.tutorial = tutorial;
		this.mainMenu = mainMenu;
	}
	
	public override void renderMe (bool isScrolling)
	{
		if(GUI.Button(new Rect(10*GUIUtilities.SizeFactor,
			0, 
			Screen.width - 20*GUIUtilities.SizeFactor, 
			300 * GUIUtilities.SizeFactor)
			, "") && !isScrolling )
		{
			mainMenu.goToTutorial(tutorial);
		}
		
		GUI.Label(new Rect(
			40*GUIUtilities.SizeFactor,
			40*GUIUtilities.SizeFactor,
			220*GUIUtilities.SizeFactor,
			220*GUIUtilities.SizeFactor),"",icon);
		
		GUIUtilities.Text(new Rect(
			300*GUIUtilities.SizeFactor,
			50*GUIUtilities.SizeFactor,  
			Screen.width - (300*GUIUtilities.SizeFactor), 
			GUIUtilities.getSize(headlineStyle,new GUIContent(this.headline)).y),this.headline, this.headlineStyle);
		
		
		
		GUIUtilities.Text(new Rect(
			300*GUIUtilities.SizeFactor, 
			(50+20)*GUIUtilities.SizeFactor + GUIUtilities.getSize(headlineStyle,new GUIContent(this.headline)).y*2,
			Screen.width - (300*GUIUtilities.SizeFactor),
			10),this.description, descriptionStyle);
	}

	public override int getHeight ()
	{
		return (int)(300 * GUIUtilities.SizeFactor);
	}
	
	
	
}