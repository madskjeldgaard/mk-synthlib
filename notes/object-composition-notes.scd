(
~b = Bus.control(s, 1).set(0);
~c = Bus.control(s, 1).set(0);
~d = Bus.control(s, 1).set(0);
)
(
SynthDef(\testobj, {|freq=100, out=0, dur=1, pan=0, eocOut=1, amp=0.5, gate=0, atk=0.9, rel=0.1| 
	// Source signal
	var sig = SinOsc.ar(freq);

	// Envelope
	var env = Env.perc(atk, rel).kr(gate: gate, timeScale: dur, doneAction: 2);

	// This output will be gated when the envelope is done
	Out.kr(eocOut, TDelay.kr(gate, dur));

	// Sound out
	sig = Pan2.ar(sig, pan);
	Out.ar(out, env * sig * amp)
}).add;
)

// Spawn synths. a starts, then when it's done it triggers b, then when that's done it SHOULD trigger c
(
c = Synth(\testobj, [\out, 0, \gate, ~c.asMap, \eocOut, ~d, \freq, 931, \atk, 0, \rel, 1, \pan, 0]);
b = Synth(\testobj, [\out, 0, \gate, ~b.asMap, \eocOut, ~c, \freq, 200, \atk, 0, \rel, 1, \pan, -1]);
a = Synth(\testobj, [\out, 0, \eocOut, ~b, \gate, 1, \atk, 1, \rel, 0, \pan, 1]);
)

// Now as an event type
(
Event.addEventType(\three, { |server|
	~stretch = ~stretch ?? 1.0;

	// Last
	Synth(~instrument3 ? ~instrument1, [
		\dur, ~dur3 * ~stretch, 
		\out, ~out ? 0, 
		\gate, ~bus2.asMap, 
		\eocOut, nil, 
		\freq, ~freq.value, 
		\atk, 0, 
		\rel, 1, 
		\pan, ~pan3 ? 0,
		\amp, ~amp ? 0.5
	]);

	// Middle
	Synth(~instrument2 ? ~instrument1, [
		\dur, ~dur2 * ~stretch, 
		\out, ~out ? 0, 
		\gate, ~bus1.asMap, 
		\eocOut, ~bus2, 
		\freq, ~freq.value * 2.0, 
		\atk, 0, 
		\rel, 1, 
		\pan, ~pan2 ? -1.0,
		\amp, ~amp ? 0.5
	]);

	// First
	Synth(~instrument1, [
		\dur, ~dur1 * ~stretch, 
		\out, ~out, 
		\eocOut, ~bus1 ? 0, 
		\freq, ~freq.value * 1.5, 
		\gate, 1, 
		\atk, 1, 
		\rel, 0, 
		\pan, ~pan1 ? 1.0,
		\amp, ~amp ? 0.5
	]);

	currentEnvironment.asArgArray.postln;
});
)

~bus1 = Bus.control(s, 1);~bus2 = Bus.control(s, 1);
(
Pbind(
	\type, \three, 
	\octave, 4,
	\degree, Pwhite(0,10),
	\stretch, 1.0,
	\dur, 2, 
	\bus1, ~bus1, \bus2, ~bus2, 
	\instrument1, \obj, //\instrument2, \obj,\instrument3, \obj, 
	\dur1, 0.25, \dur2, 0.5, \dur3, 0.1,
	\pan1, Pwhite(-1.0,1.0), \pan2, Pwhite(-1.0,1.0), \pan3, Pwhite(-1.0,1.0)
).play
)
