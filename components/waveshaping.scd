// Waveshaping buffers to be used with Shaper.ar
// Some of these were pulled out of Aaron Lanterman's Buchla 700 project: https://github.com/lantertronics/b700ish/blob/main/b700ish.scd
/*
(

Ndef(\lfo, {|freq=0.1| LFTri.kr(freq) });

Ndef(\a, {|freq=141, modfreq=0.1, shapebufA, shapebufB, crossfade=0, amp=0.1|
	var lfo = LFTri.kr(modfreq);
	var sig = SinOsc.ar(freq: SinOsc.ar(lfo.lag.lag*215) * lfo.lag.exprange(freq/2.0, freq),  phase: 0.0,  mul: 1.0,  add: 0.0);
	var shapeA = Shaper.ar(shapebufA, sig);
	var shapeB = Shaper.ar(shapebufB, sig);

	sig = XFade2.ar(shapeA, shapeB, crossfade) * amp;
	Pan2.ar(sig * lfo, lfo);
})
.set(
	\shapebufA, ~shaperBuffers[\fulltonewheel], 
	\shapebufB, ~shaperBuffers[\altsaw]
)
.map(\crossfade, Ndef(\lfo))
.mold(2)
.play;

Ndef(\a).copy(\b).set(
	\freq, 182,
	\modfreq, 0.185,
	\shapebufA, ~shaperBuffers[\truesquare], 
	\shapebufB, ~shaperBuffers[\altsignflipping_impulse_train]
).play;

Ndef(\b).copy(\c).set(
	\freq, 582,
	\modfreq, 5.085,
	\shapebufA, ~shaperBuffers[\jimmysmith], 
	\shapebufB, ~shaperBuffers[\truetriangle]
).play;
)

*/
(

// Coeffecients
~waveShapeCoeffecients = IdentityDictionary.new;
~waveShapeCoeffecients.put('truetriangle ', [1,0] / ((1..32).squared));
~waveShapeCoeffecients.put('squarecompatible_triangle', [1,0,-1,0] / ((1..32).squared));
~waveShapeCoeffecients.put('jimmysmithpositive', [1,1,1]);
~waveShapeCoeffecients.put('jimmyshith', [1,1,-1]);
~waveShapeCoeffecients.put('fulltonewheel', [1,1,-1,-1,0,1,0,-1,0,1,0,-1,0,0,0,1]);
~waveShapeCoeffecients.put('truesquare', [1,0,-1,0] / (1..32));
~waveShapeCoeffecients.put('trianglecompatible_square', [1,0] / (1..32));
~waveShapeCoeffecients.put('altsaw', 0.25*[1,-1,-1,1] / (1..32));
~waveShapeCoeffecients.put('altimpulsetrain', 0.1*[1,-1,-1,1]*Array.fill(32,1));
~waveShapeCoeffecients.put('altsignflipping_impulse_train', 0.1*[1,0,-1,0]*Array.fill(32,1));

// Convert coeffecients to waveshaping buffers
~shaperBuffers = IdentityDictionary.new;
~waveShapeCoeffecients.keysValuesDo{|name, coeffecients|
	var waveShapeSignal = Signal.chebyFill(4096, coeffecients, normalize: true, zeroOffset:false);
	var buf = Buffer.loadCollection(s, waveShapeSignal.asWavetableNoWrap);
	~shaperBuffers.put(name, buf);
};

"Waveshaping buffers are available in ~shaperBuffers using the following keys:".postln;
~shaperBuffers.keys.do{|k| k.postln};

// A function for embedding in a synthdef using SynthDef.wrap
/*

SynthDef.new(\lol, {|out=0, amp=0.25|
	var sig = SinOsc.ar(141);
	sig = SynthDef.wrap(~waveshapeXWrap,  prependArgs: [sig]);

	Out.ar(out, Env.perc.kr(gate:1, timeScale: dur) * sig * amp)
}).add;

Synth(\lol, [
	\waveshapeCrossfade, -1, 
	\waveshapeBufferA, ~shaperBuffers.choose, 
	\waveshapeBufferB, ~shaperBuffers.choose
]);

*/
// This one crossfades
~waveshapeWrap = {
	arg sig, 
		waveshapeBuffer=~shapeBuffers[\fulltonewheel];
	Shaper.ar(waveshapeBuffer, sig);
};

// This one crossfades
~waveshapeXWrap = {
	arg sig, 
		waveshapeBufferA = ~shapeBuffers[\altimpulsetrain], 
		waveshapeBufferB = ~shapeBuffers[\fulltonewheel], 
		waveshapeCrossfade=0;

	var shapeA = Shaper.ar(waveshapeBufferA, sig);
	var shapeB = Shaper.ar(waveshapeBufferB, sig);

	XFade2.ar(shapeA, shapeB, waveshapeCrossfade)
};
)
