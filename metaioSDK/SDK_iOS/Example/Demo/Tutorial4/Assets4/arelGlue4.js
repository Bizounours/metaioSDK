var timer;
var timer_is_on=0;

arel.sceneReady(function()
{
	console.log("sceneReady");

	//set a listener to tracking to get information about when the image is tracked
	arel.Events.setListener(arel.Scene, function(type, param){trackingHandler(type, param);});

    // Check initial state of tracking (we could already be tracking without trackingHandler being
    // called because it was registered too late)
    arel.Scene.getTrackingValues(function(trackingValues) {
        if (trackingValues.length > 0)
        {
            $('#info').fadeOut("fast");
            if (!timer_is_on)
            {
                timer_is_on = 1;
                arel.Scene.getTrackingValues(receiveCurrentTrackingValues);
            }
        }
    });

    //get the metaio man model reference
    var metaioMan = arel.Object.Model3D.create("1","Assets4/metaioman.md2","Assets4/metaioman.png");
    metaioMan.setCoordinateSystemID(1);
    metaioMan.setScale(new arel.Vector3D(4.0,4.0,4.0));
    arel.Scene.addObject(metaioMan);

    //set a listener on the metaio man
    arel.Events.setListener(metaioMan, function(obj, type, params){handleMetaioManEvents(obj, type, params);});

});

function trackingHandler(type, param)
{
	//check if there is tracking information available
	if(param[0] !== undefined)
	{
		//if the pattern is found, hide the information to hold your phone over the pattern
		if(type && type == arel.Events.Scene.ONTRACKING && param[0].getState() == arel.Tracking.STATE_TRACKING)
		{
			$('#info').fadeOut("fast");
            if (!timer_is_on)
            {
                timer_is_on=1;
                arel.Scene.getTrackingValues(function(tv){receiveCurrentTrackingValues(tv);});
            }
		}
		//if the pattern is lost tracking, show the information to hold your phone over the pattern
		else if(type && type == arel.Events.Scene.ONTRACKING && param[0].getState() == arel.Tracking.STATE_NOTTRACKING)
		{
			$('#info').fadeIn("fast");
            if (timer_is_on)
            {
                clearTimeout(timer);
                timer_is_on=0;
            }
		}
	}
};

function handleMetaioManEvents(obj, type, param)
{
	console.log("fubar");

	//check if there is tracking information available
	if(type && type === arel.Events.Object.ONTOUCHSTARTED)
	{
		obj.startAnimation("shock_down");
	}
	else if(type && type === arel.Events.Object.ONANIMATIONENDED && param.animationname == "shock_down")
	{
		obj.startAnimation("shock_idle");
	}
    else if(type && type === arel.Events.Object.ONANIMATIONENDED && param.animationname == "shock_idle")
	{
		obj.startAnimation("shock_up");
	}
};

function receiveCurrentTrackingValues(tv)
{
    if(tv[0] !== undefined)
    {
        var quality = tv[0].getQuality();
        if (parseFloat(quality) > 0.0)
        {

            var poseTranslation = tv[0].getTranslation();
            var threshold = 800.0;


            var distanceToTarget = Math.sqrt(poseTranslation.getX() * poseTranslation.getX() + poseTranslation.getY() * poseTranslation.getY() +poseTranslation.getZ() * poseTranslation.getZ());

            if(parseFloat(distanceToTarget) < threshold)
            {
                arel.Scene.getObject("1").startAnimation("close_up");
            }

        }
        timer = setTimeout(function(){arel.Scene.getTrackingValues(function(tv){receiveCurrentTrackingValues(tv);});}, 1000);
    }

};