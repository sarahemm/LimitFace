using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Timer as Timer;
using Toybox.Time as Time;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Time.Gregorian as Gregorian;

class LimitFaceView extends Ui.WatchFace {
	var asleep = false;
	
	// Needed for arc drawing
	var deg2rad = Math.PI/180;
	var CLOCKWISE = -1;
	var COUNTERCLOCKWISE = 1;
	
    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        // Get and show the current time
        var clockTime = Sys.getClockTime();
        var hourString = Lang.format("$1$", [clockTime.hour.format("%02d")]);
        var minString = Lang.format("$1$", [clockTime.min.format("%02d")]);
        var hourView = View.findDrawableById("HourLabel");
        var minView = View.findDrawableById("MinuteLabel");
        // FIXME: these should use the actual font, but it fails with a confusing error
        var hourWidth = dc.getTextWidthInPixels(hourString, Gfx.FONT_NUMBER_THAI_HOT);
        var minWidth = dc.getTextWidthInPixels(minString, Gfx.FONT_NUMBER_THAI_HOT);
		var centerOffset = hourWidth - minWidth;
        hourView.setText(hourString);
        minView.setText(minString);
        hourView.setLocation(dc.getWidth()/2 + centerOffset, hourView.locY);
        minView.setLocation(dc.getWidth()/2 + centerOffset, hourView.locY);
                
        // Get and show the current date
		var now = Time.now();
 		var dateInfo = Gregorian.info(now, Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$ $2$", [dateInfo.month.toUpper(), dateInfo.day]);
        var dateView = View.findDrawableById("DateLabel");
        dateView.setText(dateString);
        
        // Get and show how much distance we have left today
		var activity = ActivityMonitor.getInfo();
		var leftString = "";
		var cmGoal = 0;
		var kmLeftToday = 0;
		if(activity.distance > 0) {
			var cmPerStep = activity.distance.toFloat() / activity.steps.toFloat();
			cmGoal = activity.stepGoal.toFloat() * cmPerStep;
			kmLeftToday = (cmGoal - activity.distance.toFloat()) / (100 * 1000);
			leftString = Lang.format("$1$", [kmLeftToday.abs().format("%0.2f")]);
        }
        var leftView = View.findDrawableById("kmLeftLabel");
		leftView.setText(leftString);
		var leftDescView = View.findDrawableById("kmLeftDesc");
		if(leftString.equals("")) {
			leftDescView.setText("");
		} else if(kmLeftToday > 0) {
			leftDescView.setText("km left");
			leftView.setColor(Gfx.COLOR_GREEN);
			leftDescView.setColor(Gfx.COLOR_GREEN);
		} else {
			leftDescView.setText("km too far");
			leftView.setColor(Gfx.COLOR_RED);
			leftDescView.setColor(Gfx.COLOR_RED);
		}
		
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        if(activity.distance == 0) {
        	// we can't do anything else until we have nonzero distance
        	return;
        }
        	
        // Draw an arc to represent distance walked and how much is still available
    	var screenWidth = dc.getWidth();
    	var screenHeight = dc.getHeight();
    	var kmWalkedDegrees = 360 - (kmLeftToday / (cmGoal / (100*1000)) * 360);
    	if(kmWalkedDegrees > 359.9) {
    		// TODO: do something to make it really obvious that we've gone too far
			kmWalkedDegrees = 359.9;
		}

		var arcColor;
		if(kmWalkedDegrees < 180) {
			arcColor = Gfx.COLOR_GREEN;
		} else if(kmWalkedDegrees < 270) {
			arcColor = Gfx.COLOR_YELLOW;
		} else if(kmWalkedDegrees <= 359) {
			arcColor = Gfx.COLOR_ORANGE;	
		} else {
			arcColor = Gfx.COLOR_RED;
		}
		if(kmWalkedDegrees > 359 && !asleep && (clockTime.sec % 2 == 0)) {
			// if we're awake, flash the circle one a second
			arcColor = Gfx.COLOR_BLACK;
		}
		drawPolygonArc(dc, screenWidth/2, screenHeight/2, screenWidth/2, 10, kmWalkedDegrees, 0, arcColor, CLOCKWISE);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }
    	
    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    	asleep = false;
    	// Refresh the UI as soon as they look at the watch
    	Ui.requestUpdate();
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    	asleep = true;
    }
        
	//! Arc drawing function from https://forums.garmin.com/showthread.php?231881-Arc-Function
	function drawPolygonArc(dc, x, y, radius, thickness, angle, offsetIn, color, direction) {    	
		var curAngle;
		direction = direction*-1;
		var ptCnt = 30;
	
		if(angle > 0f) {
			var pts = new [ptCnt*2+2];
			var offset = 90f*direction+offsetIn;
			var dec = angle / ptCnt.toFloat();
			for(var i=0,angle=0; i <= ptCnt; angle+=dec) {
				curAngle = direction*(angle-offset)*deg2rad;
				pts[i] = [x+radius*Math.cos(curAngle), y+radius*Math.sin(curAngle)];
				i++;
			}
			for(var i=ptCnt+1; i <= ptCnt*2+1; angle-=dec) {
				curAngle = direction*(angle-offset)*deg2rad;
				pts[i] = [x+(radius-thickness)*Math.cos(curAngle), y+(radius-thickness)*Math.sin(curAngle)];
				i++;
			}
			dc.setColor(color,Gfx.COLOR_TRANSPARENT);
			dc.fillPolygon(pts);
		}
	}
}
