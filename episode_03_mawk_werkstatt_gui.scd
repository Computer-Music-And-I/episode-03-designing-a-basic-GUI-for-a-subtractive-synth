// MAWK Werkstatt GUI
(
// start server
s.waitForBoot({

	var size = 64;

	var w, startButton, noteControl, cutoffControl, resonControl;
	var balanceControl, ampControl;
	var node, cmdPeriodFunc;

	// Werkstatt - 01
	var werkstattLabel, typeLabel, brandLabel;

	var vcoLabel;
	var vcoFreqControl, vcoWaveButton, vcoPWMControl;
	var vcoFreqLabel, vcoWaveLabel, vcoPWMLabel;

	var vcoModSourceButton, vcoModAmountControl, vcoModDestButton;

	var lfoRateControl, lfoWaveButton;

	var vcfLabel;
	var vcfCutoffControl, vcfResonanceControl;

	var vcaLabel;
	var vcaModeButton;

	var vcfModsourceButton, vcfModAmountControl, vcfModPolarityButton;
	var envSustainButton, envAttackControl, envDecayControl;

	var glideControl;
	var key60Button,
	key61Button,
	key62Button,
	key63Button,
	key64Button,
	key65Button,
	key66Button,
	key67Button,
	key68Button,
	key69Button,
	key70Button,
	key71Button,
	key72Button;

	// gui helper functions

	var makeControl = {
		arg window, px, py, size, text;
		var c,l;

		c = Knob.new(window, Rect(px, py, size, size));
		c.action_({|v,x,y,m| postf("action func called: %\n", v.value); });

		l = StaticText(window, Rect(px - (size / 2), py+(size*1.2), size*2, 20));
		l.background = Color.clear;
		l.stringColor  =Color.white;
		l.align = \center;
		l.font = Font("Monaco", 14);
		l.string = text;

		c;
	};

	var makeButton = {
		arg window, px, py, size, text, s1Text, s2Text;
		var states = Array.newClear(0);
		var b,l;

		states = states.add([s1Text, Color.white, Color.gray],);
		states = states.add([s2Text, Color.white, Color.gray],);

		b = Button(window, Rect(px, py + (size/3), size*1, 20));
		b.states = states;
		b.action = {|view| postf("button action func called: %\n", view.value);};

		l = StaticText(window, Rect(px - (size / 2), py+(size*1.2), size*2, 20));
		l.background = Color.clear;
		l.stringColor = Color.white;
		l.align = \center;
		l.font = Font("Monaco", 14);
		l.string = text;

		b;
	};

	var makeKey = {
		arg window, px, py, s1Text;
		var states = Array.newClear(0);
		var b;
		states = states.add([s1Text, Color.white, Color.gray],);

		b = Button(window, Rect(px, py, 20, 20 ));
		b.font = Font("Monaco", 10);
		b.states = states;
		b.action = {|view| postf("key action func called: %\n", view.value);};

		b;
	};


	var drawRect = {
		arg px, py, w, h;

		Pen.fillColor = Color.clear;
		Pen.strokeColor = Color.white;
		Pen.line(px@py, (px+w)@py);
		Pen.line((px+w)@py, (px+w)@(py+h));
		Pen.line((px+w)@(py+h), px@(py+h));
		Pen.line(px@(py+h), px@py);
		Pen.fillStroke;

	};

	var drawBranding = {
		arg window, px, py, size, text, fontSize=14;

		var l = StaticText(window, Rect(px, py, size, 20));
		l.background = Color.clear;
		l.stringColor =Color.white;
		l.align = \left;
		l.font = Font("Monaco", fontSize);
		l.string = text;
	};


	var drawLabel = {
		arg window, px, py, size, text, fontSize=14;

		var l = StaticText(window, Rect(px, py, size, 20));
		l.background = Color.white;
		l.stringColor =Color.grey;
		l.align = \center;
		l.font = Font("Monaco", fontSize);
		l.string = text;
	};

	// SynthDef
	// we will later define a synth
	SynthDef("mawk_werkstatt", { |out, note = 36, fc = 1000, rq = 0.25, bal=0, amp=0.4, gate = 1|
		var x;
        x = Mix.fill(8, {
            LFSaw.ar((note + {0.1.rand2}.dup).midicps, 0, 0.02)
        });
        x = RLPF.ar(x, fc, rq).softclip;
        x = RLPF.ar(x, fc, rq, amp).softclip;
		x = Balance2.ar(x[0], x[1], bal);
        x = x * EnvGen.kr(Env.cutoff, gate, doneAction: Done.freeSelf);
        Out.ar(out, x);
    }, [0.1, 0.1, 0.1, 0.1, 0.1, 0]
	).add;


	// SETUP the GUI

	Window.closeAll;

	// make the window
	w = Window("WERKSTATT - 01", Rect(100, 0, 900, 640));
	w.background = Color.black;
	w.front; // make window visible and front window.

	// add a button to start and stop the sound.
	startButton = Button(w, Rect(10,50,75,20));
	startButton.states = [
		["Start", Color.black, Color.green(0.7)],
		["Stop", Color.white, Color.red(0.7)]
	];
	startButton.action = {|view|
		if (view.value == 1) {
			// start sound
            node = Synth( "mawk_werkstatt", [
				"note", noteControl.value,
                "fc", cutoffControl.value,
                "rq", resonControl.value,
                "bal", balanceControl.value,
                "amp", ampControl.value.dbamp ]);
        } {
            // set gate to zero to cause envelope to release
            node.release; node = nil;
		};
};

	// create controls for all parameters
	// Draw Background
	w.drawFunc = { |v|
		var r = 15;
		var uLx = (136 - (size / 2));

		drawRect.value(uLx, 50, (437 - uLx), (204-50));
		drawRect.value(437, 50, (700-437), (204-50));
		drawRect.value(700, 50, (850-700), (204-50));

		drawRect.value(uLx, 204, (437 - uLx), 154);
		drawRect.value(437, 204, (850-437), 154);

		drawRect.value(uLx, 358, (437 - uLx), 154);
		drawRect.value(437, 358, (850-437), 154);

		drawRect.value(5, 5, (85), 600);

	};

	// controll interface

	drawBranding.value(w, (10 + 7), 10 , 75, "CONTROL");


	// branding
	drawBranding.value(w, (136 - (size / 2)), 20, 200, "WERKSTATT-01", 20);
	drawBranding.value(w, (136 - (size / 2) + 145), 23, 200, "ANALOG SYNTHESIZER", 12);
	drawBranding.value(w, (136 - (size / 2) + 677), 20, 200, "MAWK", 24);

	// labels
	drawLabel.value(w, (136 - (size / 2)), 50, size, "VCO");
	drawLabel.value(w, 437, 50, size, "VCF");
	drawLabel.value(w, 700, 50, size, "VCA");
	drawLabel.value(w, (136 - (size / 2)), 204, (size * 1.5), "VCO MOD");
	drawLabel.value(w, 437, 204, (size * 1.5), "VCF MOD");
	drawLabel.value(w, (136 - (size / 2)), 358, (size * 1), "LFO");
	drawLabel.value(w, 437, 358, (size * 1.5), "ENVELOPE");

	// knobs
	vcoFreqControl = makeControl.value(w, 136, 100,size,"FREQ");
	vcoPWMControl = makeControl.value(w, 352, 100 , size, "PWM");
	vcfCutoffControl = makeControl.value(w, 470, 100,size,"CUTOFF");
	vcfResonanceControl = makeControl.value(w, 600, 100,size,"RES");
	vcoModAmountControl = makeControl.value(w, 240, 254 , size, "AMOUNT");
	vcfModAmountControl = makeControl.value(w, 600, 254 , size, "AMOUNT");
	lfoRateControl = makeControl.value(w, (136 + 20), 408 , size, "RATE");
	envAttackControl = makeControl.value(w, 600, 408 , size, "ATTACK");
	envDecayControl = makeControl.value(w, 740, 408 , size, "DECAY");
	glideControl = makeControl.value(w, (136), 530 , size, "GLIDE");

	// buttons
	vcoWaveButton = makeButton.value(w, 240, (100), size, "WAVE", "PULSE", "SAW");
	vcaModeButton = makeButton.value(w, 740, (100), size, "MODE", "ON", "EG");
	vcoModSourceButton = makeButton.value(w, 136, (254), size, "SOURCE", "EG", "LFO");
	vcoModDestButton = makeButton.value(w, 352, (254), size, "DEST", "PWM", "FREQ");
	vcfModsourceButton = makeButton.value(w, 470, (254), size, "SOURCE", "EG", "LFO");
	vcfModPolarityButton = makeButton.value(w, 740, (254), size, "POLARITY", "+", "-");
	lfoWaveButton = makeButton.value(w, 352, (408), (size *1), "WAVE", "SQUARE", "TRIANGLE");
	envSustainButton = makeButton.value(w, 470, (408), (size *1), "SUSTAIN", "ON", "OFF");

	// keyboard
	key60Button = makeKey.value(w, 400, 585, "C");
	key61Button = makeKey.value(w, 430, 545, "C#");
	key62Button = makeKey.value(w, 460, 585, "D");
	key63Button = makeKey.value(w, 490, 545, "D#");
	key64Button = makeKey.value(w, 520, 585, "E");
	key65Button = makeKey.value(w, 580, 585, "F");
	key66Button = makeKey.value(w, 610, 545, "F#");
	key67Button = makeKey.value(w, 640, 585, "G");
	key68Button = makeKey.value(w, 670, 545, "G#");
	key69Button = makeKey.value(w, 700, 585, "A");
	key70Button = makeKey.value(w, 730, 545, "A#");
	key71Button = makeKey.value(w, 760, 585, "B");
	key72Button = makeKey.value(w, 820, 585, "C");

	// set start button to zero upon a cmd-period
	cmdPeriodFunc = { startButton.value = 0; };
	CmdPeriod.add(cmdPeriodFunc);

	// stop the sound when window closes and remove cmdPeriodFunc.
	w.onClose = {
		node.free; node = nil;
		CmdPeriod.remove(cmdPeriodFunc);
	};
});
)
