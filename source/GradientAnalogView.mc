using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time.Gregorian;

class SimpleAnalogView extends WatchUi.WatchFace {
    var lowPower = false;
	var offScreenBuffer;
    var is24;
	var isDistanceMetric;
    var clip;
	var partialUpdates = false;
	var showTicks;
	var mainFont;
	var iconFont;
	var needsProtection = true;
	var lowMemDevice = true;
	var RBD = 0;
	var version;
	var showBoxes;
	var background_color_1;
	var background_color_2;
	var background_image;
	var use_background_image;
	var foreground_color;
	var box_color;
	var second_hand_color;
	var hour_min_hand_color;
	var text_color;
	var tick_style;
	var show_min_ticks;
	var ssloc = [100, 100];
	var xmult = 1.2;
	var ymult = 1.1;
	
    //relative to width percentage
	var relative_tick_stroke = .01;
    var relative_hour_tick_length = .08;
    var relative_min_tick_length = .04;
    var relative_hour_tick_stroke = .04;
    var relative_min_tick_stroke = .04;
	var relative_min_circle_tick_size = .01;
	var relative_hour_circle_tick_size = .02;
	var relative_hour_triangle_tick_size = .04;
	var relative_min_triangle_tick_size = .02;
    
    var relative_hour_hand_length = .20;
    var relative_min_hand_length = .40;
    var relative_sec_hand_length = .42;
    var relative_hour_hand_stroke = .013;
    var relative_min_hand_stroke = .013;
    var relative_sec_hand_stroke = .01;

	var relative_padding = .03;
    var relative_padding2 = .01;
    
    var relative_center_radius = .025;

	var text_padding = [1, 2];
	var box_padding = 2;
	var dow_size = [44, 19];
	var date_size = [24, 19];
	var time_size = [48, 19];
	var floors_size = [40, 19];
	var battery_size = [32, 19];
	var status_box_size = [94, 19];

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {

			//increase the size of resources so they are visible on the Venu
		mainFont = WatchUi.loadResource(Rez.Fonts.BigFont);
		iconFont = WatchUi.loadResource(Rez.Fonts.BigIconFont);
		dow_size = [44 * 1.5, 19* 1.5];
		date_size = [24* 1.5, 19* 1.5];
		time_size = [48* 1.5, 19* 1.5];
		floors_size = [48* 1.5, 19* 1.5];
		battery_size = [32*1.5, 19*1.5];
		status_box_size = [94*1.5, 19*1.5];

		updateValues(dc.getWidth());
    }

    // Update the view
    function onUpdate(dc) {
		if(needsProtection && lowPower) {
			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
			dc.clearClip();
			dc.clear();
			updateValues(dc.getWidth());
			drawScreenSaver(dc);
		} else {
			var clockTime = System.getClockTime();
			var hours = clockTime.hour;
			var minutes = clockTime.min;
			var seconds = clockTime.sec;
			var width = dc.getWidth();

			updateValues(dc.getWidth());

			drawBackground(dc);
				

			if(partialUpdates && ((!lowMemDevice && !lowPower) || (!lowMemDevice && lowPower))) {
				dc.setColor(second_hand_color, Graphics.COLOR_TRANSPARENT);
				drawSecondHandClip(dc, 60, seconds, relative_sec_hand_length*width, relative_sec_hand_stroke*width);
			} else if(lowMemDevice && !lowPower) {
				dc.setColor(second_hand_color, Graphics.COLOR_TRANSPARENT);
				drawHand(dc, 60, seconds, relative_sec_hand_length*width, relative_sec_hand_stroke*width);
			}

			dc.setColor(box_color, Graphics.COLOR_TRANSPARENT);
			dc.fillCircle(dc.getWidth()/2-1, dc.getHeight()/2-1, relative_center_radius*width);
		}
    }
    
	//use this to update values controlled by settings
	function updateValues(width) {
		var UMF = Application.getApp().getProperty("Use24HourFormat");
		if(UMF == 0) {
			is24 = true;
		}
		if(UMF == 1) {
			is24 = false;
		}
		if(UMF == 2) {
			is24 = System.getDeviceSettings().is24Hour;
		}

		var distanceMetric = System.getDeviceSettings().distanceUnits;
		if(distanceMetric == System.UNIT_METRIC) {
			isDistanceMetric = true;
		} else {
			isDistanceMetric = false;
		}

		showTicks = Application.getApp().getProperty("ShowTicks");
		RBD = Application.getApp().getProperty("RightBoxDisplay1");
		showBoxes = Application.getApp().getProperty("ShowBoxes");
		
		if(!showTicks) {
			relative_sec_hand_length = .46;
			relative_hour_hand_length = .23;
			relative_min_hand_length = .46;
		} else {
			relative_hour_hand_length = .20;
   			relative_min_hand_length = .40;
			relative_sec_hand_length = .42;
		}
		var total_colors = 14;

		background_color_1 = getColor(Application.getApp().getProperty("BackgroundColor"));
		background_color_2 = getColor(Application.getApp().getProperty("BackgroundColor1"));
		foreground_color = getColor(Application.getApp().getProperty("ForegroundColor"));
		box_color = getColor(Application.getApp().getProperty("BoxColor"));
		second_hand_color = getColor(Application.getApp().getProperty("SecondHandColor"));
		hour_min_hand_color = getColor(Application.getApp().getProperty("HourMinHandColor"));
		text_color = getColor(Application.getApp().getProperty("TextColor"));
		tick_style = Application.getApp().getProperty("TickStyle");
		show_min_ticks = Application.getApp().getProperty("ShowMinTicks");
	}

	function drawBackground(dc) {
		var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        var seconds = clockTime.sec;
        var width = dc.getWidth();
        var height = dc.getHeight();
        
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    	dc.clear();

		drawGradient(getRGB(background_color_1), getRGB(background_color_2), dc);

		// for(var i = 0; i < width*2; i++) {
		// 	dc.setColor(i*3, 0x000000 + i);
		// 	dc.drawLine(width, i, i, width);
		// }
    	
		if(tick_style == 1) {
    		dc.setColor(foreground_color, Graphics.COLOR_TRANSPARENT);
			if(show_min_ticks) {
				drawTicks(dc, relative_hour_tick_length*width, relative_hour_tick_stroke*width, 12);
    			drawTicks(dc, relative_min_tick_length*width, relative_min_tick_stroke*width, 60);
			} else {
				drawTicks(dc, relative_min_tick_length*width, relative_min_tick_stroke*width, 12);
			}
		} else if(tick_style == 2) {
			dc.setColor(foreground_color, Graphics.COLOR_TRANSPARENT);
			if(show_min_ticks) {
				drawTicksCircle(dc, relative_hour_circle_tick_size*width, 1, 12);
    			drawTicksCircle(dc, relative_min_circle_tick_size*width, 1, 60);
			} else {
				drawTicksCircle(dc, relative_min_circle_tick_size*width, 1, 12);
			}
		} else if(tick_style == 3) {
			dc.setColor(foreground_color, Graphics.COLOR_TRANSPARENT);
			if(show_min_ticks) {
				drawTicksTriangle(dc, relative_hour_triangle_tick_size*width, 1, 12);
    			drawTicksTriangle(dc, relative_min_triangle_tick_size*width, 1, 60);
			} else {
				drawTicksTriangle(dc, relative_min_triangle_tick_size*width, 1, 12);
			}
		}

    	drawDate(dc, centerOnLeft(dc, dow_size[0] + 4 + date_size[0]), width/2 - dow_size[1]/2);	
		drawBox(dc);
		drawStatusBox(dc, width/2, centerOnLeft(dc, status_box_size[1]));
    	
    	dc.setColor(hour_min_hand_color, Graphics.COLOR_TRANSPARENT);
    	drawHandOffset(dc, 12.00, 60.00, hours, minutes, relative_hour_hand_length*width, relative_hour_hand_stroke*width);

    	drawHand(dc, 60, minutes, relative_min_hand_length*width, relative_min_hand_stroke*width);
	}

	//These functions center an object between the end of the hour tick and the edge of the center circle
	function centerOnLeft(dc, size) {
		var width = dc.getWidth();
		if(showTicks) {
			return relative_hour_tick_length * width + ((((relative_hour_tick_length * width) - (width/2 - (relative_center_radius * width)))/2).abs() - size/2);
		}
		return ((((width/2 - (relative_center_radius * width)))/2).abs() - size/2);		
	}

	function centerOnRight(dc, size) {
		var width = dc.getWidth();
		if(showTicks) {
			return width - relative_hour_tick_length * width - ((((width - relative_hour_tick_length * width) - (width/2 + (relative_center_radius * width)))/2).abs() + size/2);
		}
		return width - ((((width) - (width/2 + (relative_center_radius * width)))/2).abs() + size/2);
	}

	//takes a number from settings and converts it to the assosciated color
	function getColor(num) {
		if(num == 0) {
			return Graphics.COLOR_BLACK;
		}

		if(num == 1) {
			return Graphics.COLOR_WHITE;
		}

		if(num == 2) {
			return Graphics.COLOR_LT_GRAY;
		}

		if(num == 3) {
			return Graphics.COLOR_DK_GRAY;
		}

		if(num == 4) {
			return Graphics.COLOR_BLUE;
		}

		if(num == 5) {
			return 0x02084f;
		}

		if(num == 6) {
			return Graphics.COLOR_RED;
		}

		if(num == 7) {
			return 0x730000;
		}

		if(num == 8) {
			return Graphics.COLOR_GREEN;
		}

		if(num == 9) {
			return 0x004f15;
		}

		if(num == 10) {
			return 0xAA00FF;
		}

		if(num == 11) {
			return Graphics.COLOR_PINK;
		}

		if(num == 12) {
			return Graphics.COLOR_ORANGE;
		}

		if(num == 13) {
			return Graphics.COLOR_YELLOW;
		}

		return null;
	}

	function getRGB(color) {
		var color1 = color.format("%X");
		var r = 0;
		var g = 0;
		var b = 0;

		if(color1.length() <= 2 && color1.length() > 0) {
			r = 0;
			g = 0;
			b = color1.toLongWithBase(16);
		} else if(color1.length() == 3) {
			r = 0;
			g = color1.substring(0, 1).toLongWithBase(16);
			b = color1.substring(1, 3).toLongWithBase(16);
		} else if(color1.length() == 4){
			r = 0;
			g = color1.substring(0, 2).toLongWithBase(16);
			b = color1.substring(2, 4).toLongWithBase(16);
		} else if(color1.length() == 5) {
			r = color1.substring(0, 1).toLongWithBase(16);
			g = color1.substring(1, 3).toLongWithBase(16);
			b = color1.substring(3, 5).toLongWithBase(16);
		} else if(color1.length() == 6) {
			r = color1.substring(0, 2).toLongWithBase(16);
			g = color1.substring(2, 4).toLongWithBase(16);
			b = color1.substring(4, 6).toLongWithBase(16);
		}

		return [r, g, b];
	}

	function drawGradient(start, end, dc){
		var width = dc.getWidth();

		var rincrement = (end[0].toFloat() - start[0].toFloat())/(width*2);
		var gincrement = (end[1].toFloat()-start[1].toFloat())/(width*2);
		var bincrement = (end[2].toFloat()-start[2].toFloat())/(width*2);

		var r = start[0];
		var g = start[1];
		var b = start[2];

		for(var i = 0; i < width*2; i++) {
			var rstr = r.format("%X");
			var gstr = g.format("%X");
			var bstr = b.format("%X");

			while(rstr.length() < 2) {
				rstr = "0" + rstr;
			}

			while(gstr.length() < 2) {
				gstr = "0" + gstr;
			}

			while(bstr.length() < 2) {
				bstr = "0" + bstr;
			}

			dc.setColor((rstr + gstr + bstr).toLongWithBase(16), 0x000000);
			dc.drawLine(0, i, i, 0);
			r += rincrement;
			g += gincrement;
			b += bincrement;
		}
	}
	
	function drawBox(dc) {
		var width = dc.getWidth();
		if(RBD == 1) {
			var x = centerOnRight(dc, time_size[0]);
    		var y = dc.getWidth()/2 - (time_size[1])/2;
			drawTimeBox(dc, x, y);
		}

		if(RBD == 2) {
			var x = centerOnRight(dc, time_size[0]);
    		var y = dc.getWidth()/2 - (time_size[1])/2;
			drawStepBox(dc, x, y);
		}

		if(RBD == 3) {
			var x = centerOnRight(dc, floors_size[0]);
    		var y = dc.getWidth()/2 - (floors_size[1])/2;
			drawFloorsBox(dc, x, y);
		}

		if(RBD == 4) {
			var x = centerOnRight(dc, time_size[0]);
    		var y = dc.getWidth()/2 - (time_size[1])/2;
			drawCaloriesBox(dc, x, y);
		}

		if(RBD == 5) {
			var x = centerOnRight(dc, time_size[0]);
    		var y = dc.getWidth()/2 - (time_size[1])/2;
			drawDistanceBox(dc, x, y);
		}

		if(RBD == 6) {
			var x = centerOnRight(dc, battery_size[0]);
    		var y = dc.getWidth()/2 - (battery_size[1])/2;
			drawBatteryBox(dc, x, y);
		}
	}
    
    function drawTicks(dc, length, stroke, num) {
		dc.setPenWidth(dc.getWidth() * relative_tick_stroke);
    	var tickAngle = 360/num;
    	var center = dc.getWidth()/2;
    	for(var i = 0; i < num; i++) {
    		var angle = Math.toRadians(tickAngle * i);
    		var x1 = center + Math.round(Math.cos(angle) * (center-length));
    		var y1 = center + Math.round(Math.sin(angle) * (center-length));
    		//2x^2 = 20
    		//x=10^0.5
    		var x2 = center + Math.round(Math.cos(angle) * (center));
    		var y2 = center + Math.round(Math.sin(angle) * (center));
    		
    		dc.drawLine(x1, y1, x2, y2);
    	}
    }

	function drawTicksCircle(dc, size, stroke, num) {
		dc.setPenWidth(dc.getWidth() * relative_tick_stroke);
    	var tickAngle = 360/num;
    	var center = dc.getWidth()/2;
    	for(var i = 0; i < num; i++) {
    		var angle = Math.toRadians(tickAngle * i);
    		var x1 = center + Math.round(Math.cos(angle) * (center - size - 1)) - 1;
    		var y1 = center + Math.round(Math.sin(angle) * (center - size - 1)) - 1;    		
    		dc.fillEllipse(x1, y1, size, size);
    	}
	}

	function drawTicksTriangle(dc, length, stroke, num) {
		dc.setPenWidth(dc.getWidth() * relative_tick_stroke);
    	var tickAngle = 360/num;
    	var center = dc.getWidth()/2;
    	for(var i = 0; i < num; i++) {
    		var angle = Math.toRadians(tickAngle * i);
			var offset = Math.toRadians(2);
    		var x1 = center + Math.round(Math.cos(angle) * (center-length));
    		var y1 = center + Math.round(Math.sin(angle) * (center-length));
    		//2x^2 = 20
    		//x=10^0.5
    		var x2 = center + Math.round(Math.cos(angle - offset) * (center));
    		var y2 = center + Math.round(Math.sin(angle - offset) * (center));

			var x3 = center + Math.round(Math.cos(angle + offset) * (center));
    		var y3 = center + Math.round(Math.sin(angle + offset) * (center));
    		
    		dc.fillPolygon([[x1, y1], [x2, y2], [x3, y3]]);
    	}
    }

    function drawHand(dc, num, time, length, stroke) {
    	var angle = Math.toRadians((360/num) * time) - Math.PI/2;
    	
    	var center = dc.getWidth()/2;
    	
    	dc.setPenWidth(stroke);
    	
    	var x = center + Math.round((Math.cos(angle) * length));
    	var y = center + Math.round((Math.sin(angle) * length));
    	
    	dc.drawLine(center, center, x, y);
    	
    }
    
    function drawSecondHandClip(dc, num, time, length, stroke) {
		dc.drawBitmap(0, 0, offScreenBuffer);

    	var angle = Math.toRadians((360/num) * time) - Math.PI/2;
    	var center = dc.getWidth()/2;
    	dc.setPenWidth(stroke);
    	
    	var cosval = Math.round(Math.cos(angle) * length);
    	var sinval = Math.round(Math.sin(angle) * length);
    	
    	var x = center + cosval;
    	var y = center + sinval;
    	var width = dc.getWidth();
    	var height = dc.getHeight();
    	var width2 = (center-x).abs();
    	var height2 = (center-y).abs();
    	var padding = width * relative_padding;
    	var padding2 = width * relative_padding2;
    	
    	if(cosval < 0 && sinval > 0) {
    		dc.setClip(center-width2-padding2, center-padding, width2+padding+padding2, height2+padding+padding2);
    	}
    	
    	if(cosval < 0 && sinval < 0) {
    		dc.setClip(center-width2-padding2, center-height2-padding2, width2+padding+padding2, height2+padding+padding2);
    	}
    	
    	if(cosval > 0 && sinval < 0) {
    		dc.setClip(center-padding, center-height2-padding2, width2+padding+padding2, height2+padding+padding2);
    	}
    	
    	if(cosval > 0 && sinval > 0) {
	    	dc.setClip(center-padding, center-padding, width2+padding+padding2, height2+padding+padding2);
    	}
    	

    	dc.setColor(second_hand_color, Graphics.COLOR_TRANSPARENT);
    	dc.drawLine(center, center, x, y);    	
    }
    
	//Draws a hand with an offset for a seperate time set (eg. hour hand)
    function drawHandOffset(dc, num, offsetNum, time, offsetTime, length, stroke) {
    	var angle = Math.toRadians((360/num) * time ) - Math.PI/2;
    	var section = 360.00/num/offsetNum;
    	
    	angle += Math.toRadians(section * offsetTime);
    	
    	var center = dc.getWidth()/2;
    	
    	dc.setPenWidth(stroke);
    	
    	var x = center + Math.round(Math.cos(angle) * length);
    	var y = center + Math.round(Math.sin(angle) * length);
    	
    	dc.drawLine(center, center, x, y);
    }

    function drawStatusBox(dc, x, y) {
		var status_string = "";
		var settings = System.getDeviceSettings();
		var status = System.getSystemStats();

		if(settings.phoneConnected) {
			status_string += "K";
		}

		if(settings.alarmCount > 0) {
			status_string += "H";
		}

		if (settings has :doNotDisturb) {
			if(settings.doNotDisturb) {
				status_string += "I";
			}
		}

		if(settings.notificationCount > 0) {
			status_string += "J";
		}

		if(status has :charging && status.charging) {
			status_string += "A";
		} else if(status.battery > 86) {
			status_string += "G";
		} else if(status.battery > 72) {
			status_string += "F";
		} else if(status.battery > 56) {
			status_string += "E";
		} else if(status.battery > 40) {
			status_string += "D";
		} else if(status.battery > 24) {
			status_string += "C";
		} else {
			status_string += "B";
		}

		dc.setPenWidth(2);
    	dc.setColor(box_color, Graphics.COLOR_WHITE);
		if(showBoxes) {
   			// dc.drawRoundedRectangle(x - status_box_size[0]/2, y, status_box_size[0], status_box_size[1], box_padding);
		}
    	
		var boxText = new WatchUi.Text({
            :text=>status_string,
            :color=>text_color,
            :font=>iconFont,
            :locX =>x + text_padding[0],
            :locY=>y,
			:justification=>Graphics.TEXT_JUSTIFY_CENTER
        });

		boxText.draw(dc);
    }

	function drawDate(dc, x, y) {
		var width = dc.getWidth();
		var height = dc.getHeight();
    	var info = Gregorian.info(Time.now(), Time.FORMAT_LONG);
		var dowString = info.day_of_week;
		
		drawTextBox(dc, dowString, x, y, dow_size[0], dow_size[1]);
		drawTextBox(dc, info.day.toString(), x + dow_size[0] + 4, y, date_size[0], date_size[1]);
    }
    
    function drawTimeBox(dc, x, y) {
		var width = dc.getWidth();
    	var info = Gregorian.info(Time.now(), Time.FORMAT_LONG);
    	var clockTime = System.getClockTime();
		var hours = clockTime.hour.format("%02d").toNumber();
		var hourString = hours;

		if(!is24 && hours > 12) {
			hours -= 12;
			hourString = hours;
		}

		if(hours < 10) {
			hourString = " " + hourString;
		}

		drawTextBox(dc, hourString + ":" + clockTime.min.format("%02d"), x, y, time_size[0], time_size[1]);
    }
	
	function drawStepBox(dc, x, y) {
		var width = dc.getWidth();
		var steps = ActivityMonitor.getInfo().steps;
		var stepString;
		if(steps > 99999) {
			stepString = "99+k";
		} else {
			stepString = (steps.toDouble()/1000).format("%.1f") + "k";
		}
		// System.out.println(steps);

		drawTextBox(dc, stepString, x, y, time_size[0], time_size[1]);
	}

	function drawFloorsBox(dc, x, y) {
		var width = dc.getWidth();
		var floors;
		var floorString;

		if(ActivityMonitor.getInfo() has :floorsClimbed) {
			floors = ActivityMonitor.getInfo().floorsClimbed;

			if(floors > 999) {
				floorString = "999+";
			} else {
				floorString = floors.toString();
			}
		} else {
			floorString = "NA";
		}

		drawTextBox(dc, floorString, x, y, floors_size[0], floors_size[1]);
	}

	function drawCaloriesBox(dc, x, y) {
		var width = dc.getWidth();
		var calories;
		calories = ActivityMonitor.getInfo().calories;

		var calorieString;
		if(calories > 99999) {
			calorieString = "99+k";
		} else {
			calorieString = (calories.toDouble()/1000).format("%0.1f") + "k";
		}

		// System.out.println(steps);

		drawTextBox(dc, calorieString, x, y, time_size[0], time_size[1]);
	}

	function drawDistanceBox(dc, x, y) {
		var width = dc.getWidth();
		var distance;
		distance = ActivityMonitor.getInfo().distance/1000000;
		System.println(distance);
		if(!isDistanceMetric) {
			distance *= .621371;
		} 
		var distanceString;
		if(distance > 999) {
			distanceString = "999+";
		} else {
			distanceString = (distance).format("%.1f");
		}

		drawTextBox(dc, distanceString, x, y, time_size[0], time_size[1]);
	}

	function drawBatteryBox(dc, x, y) {
		var width = dc.getWidth();
		var battery = System.getSystemStats().battery;

		var batteryString = battery.format("%.0f");

		drawTextBox(dc, batteryString, x, y, battery_size[0], battery_size[1]);
	}

	function drawTextBox(dc, text, x, y, width, height) {
		dc.setPenWidth(2);
    	dc.setColor(box_color, Graphics.COLOR_WHITE);
		if(showBoxes) {
   			dc.drawRoundedRectangle(x, y, width, height, box_padding);
		}
    	
		var boxText = new WatchUi.Text({
            :text=>text,
            :color=>text_color,
            :font=>mainFont,
            :locX =>x + text_padding[0],
            :locY=>y,
			:justification=>Graphics.TEXT_JUSTIFY_LEFT
        });

		boxText.draw(dc);
	}

    //Draws a text box with the time at a random point on the screen
	//Used for AMOLED devices to prevent burn-in
	function drawScreenSaver(dc) {
			var clockTime = System.getClockTime();
			var timeString = clockTime.hour + ":" + clockTime.min.format("%02d");
			var hour = clockTime.hour;
			var width = dc.getWidth();

			if(!is24 && hour > 12) {
				hour -= 12;
				timeString = hour + ":" + clockTime.min.format("%02d");
			}

			if(hour < 10) {
				timeString = "  " + timeString;
			}

			var pad = 150;
			ssloc[0] += status_box_size[0] * xmult;
			ssloc[1] += (status_box_size[1] + time_size[1]) * ymult;

			if(ssloc[0] <= pad) {
				ssloc[0] = pad;
				xmult *= -1;
			} else if(ssloc[0] >= width-pad) {
				ssloc[0] = width-pad;
				xmult *= -1;
			}

			if(ssloc[1] <= pad) {
				ssloc[1] = pad;
				ymult *= -1;
			} else if(ssloc[1] >= width-pad) {
				ssloc[1] = width-pad;
				ymult *= -1;
			}


			drawStatusBox(dc, ssloc[0], ssloc[1]);
			drawTextBox(dc, timeString, ssloc[0] - (time_size[0]/2), ssloc[1] - time_size[1], time_size[0], time_size[1]);
	}

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
		lowPower = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
		lowPower = true;
    }

}
