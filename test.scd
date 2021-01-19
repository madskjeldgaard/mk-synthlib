(// A four operator FM synth
	SynthDef(\fmx, {| dur=1, pan=0, amp = 0.1, out = 0,
		freq = 440, feedback = 0.9, hr4 = 4 ,hr3 = 2, hr2 = 1.08, hr1= 1.0812, mi4 = 2.0128, mi3 = 3.018,
		mi2 = 4, en1 = 0, en2 = 0, en3 = 0, en4 = 0, curve1 = -4.0, curve2 = -1.0, curve3 = 10,
		curve4 = 0, detune = 0.2 |
		var env4,env3,env2,env1,sig,modComp;

		env4 = EnvGen.ar(Env.perc(en4,1-en4,curve:curve4),timeScale:dur);
		env3 = EnvGen.ar(Env.perc(en3,1-en3,curve:curve3),timeScale:dur);
		env2 = EnvGen.ar(Env.perc(en2,1-en2,curve:curve2),timeScale:dur);
		env1 = EnvGen.ar(Env.perc(en1,1-en1,curve:curve1),timeScale:dur,doneAction:2);

		modComp = freq.explin(20,20000,1,0.01);

		sig = SinOscFB.ar(freq*hr4,feedback*modComp,mi4*modComp ) * env4;
		sig = SinOsc.ar(freq*hr3,sig+[0.0,pi/2.0],mi3*modComp ) * env3;
		sig = SinOsc.ar(freq*hr2,sig,mi2*modComp ) * env2;
		sig = SinOsc.ar(freq*hr1+[detune.neg,detune], sig ) * env1;

		sig = sig.sum * AmpCompA.kr(freq,17.323914436055);
		sig = sig * amp;
		sig = Pan2.ar(sig, pan);
		Out.ar(out, sig);
	}).add;
)

Synth(\fmx, [\freq, exprand(40.0,500.0), \pan, rand(-0.5,0.5)])

Pbind(\instrument, \fmx, \freq, Pwhite(50.0,500.0),\fdb, Pwhite(0.5,2.0), \dur, 0.1).play
(
Pdef(\a, 
	Pbind(
		\instrument, Pxrand(~synthNames, inf), 
		\freq, Pwhite(150.0,2500.0), 
		\dur, 2.5, 
		\amp, 0.5,
		\detuneModAmount, 0.1, //Pwhite(0.0,1.0),
		\detuneFreq, Pkey(\freq) * 1.0, //Pwhite(1.0,100.0), 
		\detuneModShape, Pwhite(0.0,1.0).trace,
		\detuneModFreq, Pwhite(0.001,10.0),
		\attack, 0.0,
		\release, Pwhite(0.5,2.0), 
		\pan, 0
	)
).play
)

(
Ndef(\o, {|shape=0.5|

	var shapes = [LFSaw.kr(0.5), LFPar.kr(0.5), LFNoise2.kr(0.5)];
	SelectX.kr(shape * shapes.size,  shapes,  wrap: 1);
}).scope
)

Ndef(\o).set(\shape, 0.3)

(
s.record;
~analogPat = {|instr=\analog_dpw4saw_tadsr, dur=(1/12)|
	Pbind(
		\instrument, instr,
		\octave, Pstep.new(
			Pwrand([3,4,5,6], [0.05,0.2,0.5,0.2].normalizeSum,inf),
			durs: Prand([12,15,16],inf),  
			repeats: inf
		),
		\degree, Pseq([0,5,3,2,1,Pwhite(0,3,1)], inf),
		\root, 2,
		\dur, dur,
		\amp, 0.125 * Pbrown(0.5,1.0,0.0001),
		\freqMod, Pbrown(0.0,0.9,0.001),
		\detuneModAmount, Pbrown(0.0,0.9,0.001),
		\detuneFreq, Pkey(\freq) * Pbrown(0.1,1.0,0.001),
		\detuneModShape, Pwhite(0.0,0.4),
		\filterModAmount, 1.5,
		\resonance, 0.95,
		\cutoff, Pseg(Pwhite(100.0,2500.0), 32, \exp, inf),
		\filterMod, Pwhite(0.0,1.0),
		\attack, Pseg(Pseq([0.0001,0.25],inf), 12, \exp, inf),
		\decay, Pseg(Pseq([2,8],inf), 32, \lin, inf) - Pkey(\attack),
		\pan, Pseg(Pseq([0.0,1.0],inf), 16, \lin, inf) * Pwhite(-1.0,1.0)
	)
};

Pdef(\a, 
	Ptpar([
		0.0, ~analogPat.value(\analog_dpw4saw_tadsr, (1/16)),
		3, ~analogPat.value(\analog_sawdpw_tadsr, (1/16)),
		7, ~analogPat.value(\analog_sawdpw_tadsr, (1/16)),
	])
);

Ndef(\fxout).mold(2, 'audio').play; s.record;
Ndef(\fxout).source = Pdef(\a);
Ndef(\fxout)[1] = \filter -> {|in, verbtime=1, damp=0.1, size=1, moddepth=0.5|
	Greyhole.ar(in, verbtime, damp, size,  diff: 0.707,  feedback: 0.9,  modDepth: moddepth,  modFreq: 2.0)
	// JPverb.ar(in,  t60: verbtime,  damp: damp,  size: size,  earlyDiff: 0.707,  modDepth: moddepth,  modFreq: 2.0,  low: 1.0,  mid: 1.0,  high: 1.0,  lowcut: 500.0,  highcut: 2000.0)
};

// Ndef(\fxout).gui

)

)
Pdef.all.clear

x = Synth(\analog_saw_adsr, [\dur, 1, \gate, 1])
x.set(\gate, 0)

(
{ SinOsc.ar(
	freq: EnvGen.kr(
        Env([6000, 700, 100], [1, 1], ['exp', 'lin']).circle
	)
    ) * 0.1
}.play;
)

{ EnvGen.kr(Env.perc.circle) }.scope

Synth(\analog_dpw4saw_tadsr, [\cutoffMod, 0.2, \dur, 3, \modFreq, 0.1, \cutoff, 500])

(

// Test
(
Pmono(\west,
	\freq, Pwhite(100.0,2400.0),
	\dur, 0.125,
	\gate, 1,
	\pitchBendRatio, Pwhite(0.0,1.0), 
	\glide, Pwhite(0.25,0.9), 
	\fm1Ratio, Pwhite(0.25,3.0), 
	\fm2Ratio, Pkey(\fm1Ratio) + Pwhite(0.25,3.0), 
	\fm1Amount, Pwhite(0.0,0.25), 
	\fm2Amount, Pwhite(0.0,0.5),
	\vel, 0.5, 
	\pressure, 0.5, //Pwhite(), 
	\timbre, Pwhite(0.0,0.75), 
	\waveShape, Pwhite(0.0,0.5), 
	\waveFolds, Pwhite(0.0,0.5), 
	\envType, Pwhite(0,1), 
	\attack, Pwhite(0.01,0.1), 
	\peak, Pwhite(1500.0,10000.0), 
	\decay, Pwhite(1.0,4.0), 
	\pan, Pbrown(-0.5,0.5,0.001),
	\amp, 0.5, 
	\lfoShape, 0, //Pwhite(), 
	\lfoFreq, Pwhite(0.1,5.0),
	\lfoToFreqAmount, Pwhite(), 
	\lfoToWaveShapeAmount, Pwhite(), 
	\lfoToWaveFoldsAmount, Pwhite(), 
	\lfoToFm1Amount, Pwhite(), 
	\lfoToFm2Amount, Pwhite(),
	\lfoToAttackAmount, Pwhite(), 
	\lfoToPeakAmount, Pwhite(), 
	\lfoToDecayAmount, Pwhite(), 
	\lfoToReverbMixAmount, Pwhite(), 
	\drift, Pwhite()
).play
)

)
(
Pmono(\west, \freq, Pwhite(150,500), \pan, Pwhite(-1.0,1.0), \dur, 1.25, \decay, Pkey(\dur), \envType, 0, \gate, 1).play
)

(
Pmono(\benjo, \degree, Pwhite(0,10), \rungler1, 0.85, \rungler2, 0.9, \pan, Pwhite(-1.0,1.0), \dur, 1.25, \decay, Pkey(\dur), \envType, 0, \gate, 1).play
)

(



Ndef(\pll, {|freq=199, lag=0.5, amp=0.1|
		var oscRef, oscExt, output, pc, freqfbk=9;

		freqfbk = LocalIn.ar(1,0);

		oscRef = LFPulse.ar(freqfbk, 0, 0.5);

		oscExt = LFPulse.ar(freq, 0, 0.5);

		pc = (oscRef+oscExt)%2;

		pc = pc.floor.lag(lag);

		//pc = OnePole.ar(pc,0.99999);

		pc = pc.linexp(0,1,1,10000);

		//pc.poll;

		LocalOut.ar(pc);

		//DC.ar(0)+pc;

		oscRef * amp

	}

).playN(0)

)

(

Ndef(\pll, {
	var oscRef, oscExt, output, pc, freqsrc, freqfbk=1, freqQ;

	freqfbk = LocalIn.ar(1,0);
	freqsrc = LFDNoise3.ar(20.9).range(2, 100);
	freqQ = freqfbk / freqsrc;
	freqQ.poll(label: \freqQ);
		
	oscRef = LFPulse.ar(freqfbk, 0, 0.5);
	oscExt = LFPulse.ar(freqsrc, 0, 0.5);

	pc = (oscRef+oscExt)%2;
	pc = pc.floor.lag(\lag.ar(0.15));

	// pc = OnePole.ar(pc,0.99999);

	pc = pc.linexp(0,1,1,10000);
	LocalOut.ar(pc);
	oscRef * 0.1
}).playN(0)
)
)

(
Pmono(\west,
	\freq, Pwhite(80.0,200.0) + Pwrand([0,150,500], [0.5,0.25,0.25],inf),
	\dur, Prand([0.125,1/12,0.25,0.125],inf),
	\killgate, Pseq([1,1,1,1],inf),
	\gate, 1,
	\pitchBendRatio, Pwhite(0.0,1.0), 
	\glide, Pwhite(0.25,0.9), 
	\fm1Ratio, Pwhite(0.25,3.0), 
	\fm2Ratio, Pkey(\fm1Ratio) + Pwhite(0.25,3.0), 
	\fm1Amount, Pwhite(0.0,0.25), 
	\fm2Amount, Pwhite(0.0,0.5),
	\vel, 0.5, 
	\pressure, 0.5, //Pwhite(), 
	\timbre, Pwhite(0.0,0.75), 
	\waveShape, Pwhite(0.0,0.9), 
	\waveFolds, Pwhite(0.0,0.9), 
	\envType, Pwhite(0,1), 
	\attack, Pwhite(0.001,0.01), 
	\peak, Pwhite(1500.0,10000.0), 
	\decay, Prand((1..4),inf),
	\pan, Pbrown(-0.5,0.5,0.001),
	\amp, 0.5, 
	\lfoShape, 0, //Pwhite(), 
	\lfoFreq, Pwhite(0.1,5.0),
	\lfoToFreqAmount, Pwhite(), 
	\lfoToWaveShapeAmount, Pwhite(), 
	\lfoToWaveFoldsAmount, Pwhite(), 
	\lfoToFm1Amount, Pwhite(), 
	\lfoToFm2Amount, Pwhite(),
	\lfoToAttackAmount, Pwhite(), 
	\lfoToPeakAmount, Pwhite(), 
	\lfoToDecayAmount, Pwhite(), 
	\lfoToReverbMixAmount, Pwhite(), 
	\drift, Pwhite()
).play(quant:1)

)

(
Ndef(\a, {|g=1|
	var e = EnvGen.kr(Env([0,1,1,0], [0.1,0.1], releaseNode:2),  gate: g,  levelScale: 1.0,  levelBias: 0.0,  timeScale: 1.0,  doneAction: 0).poll;
	e

})
)
Ndef(\a).set(\g, 0)

z = Synth(\west, [\decay, 40, \envType, 1])

z.set(\killgate, 0)

(

SynthDef(\pm4, {

	var numops = 4;
	var fb = LocalIn.ar(numops);

	var gate = \gate.kr(1);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar(freqbend, \vrate.kr(6), \vdepth.kr(0.000));
	var detunehz = \detunehz.kr(0);
	var vel = \vel.kr(1);

	var car = numops.collect({arg i;
		var num = i+1;
		var ratio = ('op' ++ num ++ 'ratio').asSymbol;
		var curve = ('op' ++ num ++ 'curve').asSymbol.kr(0);
		var atk = ('op' ++ num ++ 'atk').asSymbol.kr(0.01);
		var dec = ('op' ++ num ++ 'dec').asSymbol.kr(0.01);
		var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1);
		var rel = ('op' ++ num ++ 'rel').asSymbol.kr(1);
		var env = Env.adsr(
			attackTime:atk,
			decayTime:dec,
			sustainLevel:suslevel,
			releaseTime:rel,
			curve:curve
		).kr(gate:gate);
		
		[freq * ratio.kr(1) + Rand(detunehz.neg, detunehz), env]
	});

	var mods = numops.collect({arg i;
		var y = i + 1;
		numops.collect({arg j;
			var x = j + 1;
			var key = ('m' ++ y ++ '_' ++ x).asSymbol;
			key.kr(0);
		});
	});

	var sig = numops.collect({arg i;
		var num = i+1;
		var freq = car[i][0].clip(20, 20000);
		var index = mods[i];
		var mod = (fb * index).sum;
		var sig = SinOsc.ar(freq, mod.mod(2pi)) * car[i][1];
		var coef = ('op' ++ num ++ 'coef').asSymbol.kr(0.5).clip(-1, 1);
		sig = OnePole.ar(sig, coef);
		sig;
	});

	sig = LeakDC.ar(sig);

	LocalOut.ar(sig);

	// set output level
	sig = sig * numops.collect({arg i;
		var num = i + 1;
		var key = ('op' ++ num).asSymbol;
		key.kr(1);
	}).normalizeSum;

	// set panning
	sig = numops.collect({arg i;
		var num = i + 1;
		var key = ('op' ++ num ++ 'pan').asSymbol;
		Pan2.ar(sig[i],	key.kr(0),	1)
	}).sum;

	sig = BLowPass.ar(
		BHiPass.ar(sig,
			\hpf.kr(20).clip(20, 18000),
			\hpfres.kr(0).linlin(0, 1, 1, 0.001)
		),
		\lpf.kr(20000).clip(20, 20000),
		\lpfres.kr(0).linlin(0, 1, 1, 0.001)
	);

	sig = sig * AmpCompA.kr(freq) * \amp.kr(0.1) * vel;
	sig = sig.softclip;
	DetectSilence.ar(sig, doneAction:Done.freeSelf);

	Out.ar(\out.kr(0), sig);

}).add;
)

(
Ndef(\verb).play;
Ndef(\verb).filter(1, {arg in;
	var sig = HPF.ar(in, 220);
	FreeVerb2.ar(sig[0], sig[1], 1, 0.9, 0.5);
}).set(\wet1, 0.4);

Pdef(\pm6, Pbind(
	\instrument, \pm5,
	\out, Pfunc({Ndef(\verb).bus}),
	\detunehz, 1,
	\vdepth, 0.003,
	
	// rhythm
	\legato, 0.9,
	\dur, 0.25,
	\tempo, 1,
	
	// melody
	\scale, Scale.dorian,
	\degree, [0,2,3] + Pshuf([-1, 0, 2, 4, 6, 7], inf),
	\octave, Pbjorklund(5, 8).linlin(0, 1, 3, Pseq([4, 5], inf)),
	
	// volume
	\amp, 0.3,
	\vel, Pseq([1, 0.5, 0.8, 0.7], inf),
	
	//////////////////////////////
	// operator 1
	\op1, 0.25,
	\op1ratio, 1,
	\op1atk, 0.01,
	\op1dec, 0.5,
	\op1suslevel, 1,
	\op1rel, 2,
	\op1curve, -4,
	// one-pole coefficient
	\op1coef, 0.2,
	\op1pan, Pwhite(-0.5, 0.5),
	
	// operator 2
	\op2, 0.5,
	\op2ratio, 3,
	\op2atk, 0.07,
	\op2dec, 0.4,
	\op2suslevel, 0.5,
	\op2rel, Pkey(\op1rel) * 0.5,
	\op2curve, 2,
	// one-pole coefficient
	\op2coef, 0.25,
	\op2pan, Pwhite(-0.3, 0.3),
	
	// operator 3
	\op3, 1,
	\op3ratio, 3,
	\op3atk, 0.01,
	\op3dec, 0.3,
	\op3suslevel, 0.7,
	\op3rel, 2,
	\op3curve, 3,
	// one-pole coefficient
	\op3coef, 0.25,
	\op3pan, Pwhite(-1.0,1.0),
	
	// operator 4
	\op4, 0.4,
	\op4ratio, 5,
	\op4atk, 0.01,
	\op4dec, 0.1,
	\op4suslevel, 0.4,
	\op4rel, 0.5,
	\op4curve, -4,
	// one-pole coefficient
	\op4coef, 0.3,
	\op4pan, Pwhite(-1.0,1.0),

	// operator 5
	\op5, 0.7,
	\op5ratio, 8,
	\op5atk, 0.1,
	\op5dec, 0.1,
	\op5suslevel, 0.5,
	\op5rel, 0.5,
	\op5curve, -1,
	// one-pole coefficient
	\op5coef, 0.3,
	\op5pan, Pwhite(-1.0,1.0),
	
	//////////////////////////////
	// modulators
	// 0pi to 2pi seems to be most useful range
	\m1_1, Pwhite(0.0,0.1)*pi, //feedback
	\m1_2, 0.2pi,
	\m1_3, 0.25pi,
	\m1_4, 0.5pi,
	
	\m2_1, 0pi,
	\m2_2, 0pi, //feedback
	\m2_3, 0.2pi,
	\m2_4, 0pi,
	
	\m3_1, 0.2pi,
	\m3_2, 0.1pi,
	\m3_3, 0.3pi, //feedback
	\m3_4, 0.3pi,
	
	\m4_1, 0.1pi,
	\m4_2, 0.1pi,
	\m4_3, 0.0pi,
	\m4_4, 0.3pi, //feedback
	
	\lpf, Pseg(Pseq([1000,100],inf), 16, \exp, inf),
	\hpf, 80
));

Pdef(\pm4).play;

)
s.record
Pdef.all.clear;

(
(
Ndef(\verb).play;
Ndef(\verb).filter(1, {arg in;
	var sig = HPF.ar(in, 220);
	Greyhole.ar(sig,  delayTime: 1.0,  damp: 0.0,  size: 1.0,  diff: 0.707,  feedback: 0.9,  modDepth: 0.1,  modFreq: 2.0)
	// FreeVerb2.ar(sig[0], sig[1], 1, 0.9, 0.5);
}).set(\wet1, 0.4);

Pdef(\pm, Pbind(
	\instrument, \pm5,
	\out, Pfunc({Ndef(\verb).bus}),
	\detunehz, 1,
	\vdepth, 0.003,
	
	// rhythm
	\legato, 0.9,
	\dur, 0.25,
	\tempo, 1,
	
	// melody
	\scale, Scale.dorian,
	\degree, Pshuf([-1, 0, 2, 4, 6, 7], inf),
	\octave, Pbjorklund(5, 8).linlin(0, 1, 3, Pseq([4, 5], inf)),
	
	// volume
	\amp, 0.3,
	\vel, Pseq([1, 0.5, 0.8, 0.7], inf),
	
	//////////////////////////////
	// operator 1
	\op1, 0.25,
	\op1ratio, 1,
	\op1atk, 0.01,
	\op1dec, 0.5,
	\op1suslevel, 1,
	\op1rel, 2,
	\op1curve, -4,
	// one-pole coefficient
	\op1coef, 0.2,
	\op1pan, Pwhite(-0.5, 0.5),
	
	// operator 2
	\op2, 0.5,
	\op2ratio, 3,
	\op2atk, 0.07,
	\op2dec, 0.4,
	\op2suslevel, 0.5,
	\op2rel, Pkey(\op1rel) * 0.5,
	\op2curve, 2,
	// one-pole coefficient
	\op2coef, 0.25,
	\op2pan, Pwhite(-0.3, 0.3),
	
	// operator 3
	\op3, 1,
	\op3ratio, 3,
	\op3atk, 0.01,
	\op3dec, 0.3,
	\op3suslevel, 0.7,
	\op3rel, 2,
	\op3curve, 3,
	// one-pole coefficient
	\op3coef, 0.25,
	\op3pan, Pwhite(-1.0,1.0),
	
	// operator 4
	\op4, 0.7,
	\op4ratio, 5,
	\op4atk, 0.01,
	\op4dec, 0.1,
	\op4suslevel, 0.4,
	\op4rel, 0.5,
	\op4curve, -4,
	// one-pole coefficient
	\op4coef, 0.3,
	\op4pan, Pwhite(-1.0,1.0),
	
	//////////////////////////////
	// modulators
	// 0pi to 2pi seems to be most useful range
	\m1_1, Pwhite(0.0,0.1)*pi, //feedback
	\m1_2, 0.2pi,
	\m1_3, 0pi,
	\m1_4, 0.5pi,
	
	\m2_1, 0pi,
	\m2_2, 0pi, //feedback
	\m2_3, 0.2pi,
	\m2_4, 0pi,
	
	\m3_1, 0.2pi,
	\m3_2, 0.1pi,
	\m3_3, 0.3pi, //feedback
	\m3_4, 0.3pi,
	
	\m4_1, 0.1pi,
	\m4_2, 0.1pi,
	\m4_3, 0.0pi,
	\m4_4, 0.3pi, //feedback
	
	\lpf, Pseg(Pwhite(100.0,3500.0), Prand([16,32,48,64],inf), \exp, inf),
	\hpf, 80
));

Pdef(\pm4).play;

Pdef(\pm5, 
	Pbindf(
		Pdef(\pm4), \octave, Pkey(\octave) + 1, \dur, Pkey(\dur) / 2.0
	)
).play;

Pdef(\pm6, 
	Pbindf(
		Pdef(\pm4), \octave, Pkey(\octave) - 1, \dur, Pkey(\dur) / 1.5 
	)
).play;

)
)

Synth(\pm5)

(
var numChannels = 2;
// (3..8).do{|numops|
var numops = 4;
		var basename = "pm%".format(numops);
		var name = "%".format(basename).asSymbol.postln;

		// ~synthNames = ~synthNames.add(name);

		SynthDef(name, { 
			arg out=0, amp=0.5,
			dur=1,
			envDone=2;

			// var numops = 4;
			var fb = LocalIn.ar(numops);

			var gate = \gate.kr(1);
			var in_freq = \freq.ar(261).lag(\glis.kr(0));
			var bend = \bend.ar(0).midiratio;
			var freqbend = in_freq * bend;
			var freq = Vibrato.ar(freqbend, \vrate.kr(6), \vdepth.kr(0.000));
			var detunehz = \detunehz.kr(0);
			var vel = \vel.kr(1);

			var car = numops.collect({arg i;
				var num = i+1;
				var ratio = ('op' ++ num ++ 'ratio').asSymbol;
				var curve = ('op' ++ num ++ 'curve').asSymbol.kr(0);
				var atk = ('op' ++ num ++ 'atk').asSymbol.kr(0.01);
				var dec = ('op' ++ num ++ 'dec').asSymbol.kr(0.01);
				var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1);
				var rel = ('op' ++ num ++ 'rel').asSymbol.kr(1);
				var env = Env.adsr(
					attackTime:atk,
					decayTime:dec,
					sustainLevel:suslevel,
					releaseTime:rel,
					curve:curve
				).kr(gate:gate);

				[freq * ratio.kr(1) + Rand(detunehz.neg, detunehz), env]
			});

			var mods = numops.collect({arg i;
				var y = i + 1;
				numops.collect({arg j;
					var x = j + 1;
					var key = ('m' ++ y ++ '_' ++ x).asSymbol;
					key.kr(0);
				});
			});

			var sig = numops.collect({arg i;
				var num = i+1;
				var freq = car[i][0].clip(20, 20000);
				var index = mods[i];
				var mod = (fb * index).sum;
				var sig = SinOsc.ar(freq, mod.mod(2pi)) * car[i][1];
				// var sig = PinkNoise.ar(0.25);
				var coef = ('op' ++ num ++ 'coef').asSymbol.kr(0.5).clip(-1, 1);
				sig = OnePole.ar(sig, coef);
				sig;
			});

			sig = LeakDC.ar(sig);

			LocalOut.ar(sig);

			// set output level
			sig = sig * numops.collect({arg i;
				var num = i + 1;
				var key = ('op' ++ num).asSymbol;
				key.kr(1);
			}).normalizeSum;

			// set panning
			sig = numops.collect({arg i;
				var num = i + 1;
				var key = ('op' ++ num ++ 'pan').asSymbol;
				Pan2.ar(sig[i],	key.kr(0),	1)
			}).sum;

			sig = BLowPass.ar(
				BHiPass.ar(sig,
					\hpf.kr(20).clip(20, 18000),
					\hpfres.kr(0).linlin(0, 1, 1, 0.001)
				),
				\lpf.kr(20000).clip(20, 20000),
				\lpfres.kr(0).linlin(0, 1, 1, 0.001)
			);

			sig = sig * AmpCompA.kr(freq) * amp * vel;
			sig = sig.softclip;
			DetectSilence.ar(sig, doneAction:Done.freeSelf);

			// Envelope
			// var env = SynthDef.wrap(~envs[envType],  prependArgs: [dur, envDone]);

			// Panning
			// sig = SynthDef.wrap(
			// 	~panFunc.value(numChannelsIn: 2, numChannelsOut: numChannels),  
			// 	prependArgs: [sig]
			// );

			Out.ar(out, sig);
		}).add;

	// }
)


Pdef.all.clear
(
Pdef(\pm, Pbind(
	\instrument, \pm4,
	\out, 0, //Pfunc({Ndef(\verb).bus}),
	\detunehz, 1,
	\vdepth, 0.003,
	
	// rhythm
	\legato, 0.9,
	\dur, 0.25,
	\tempo, 1,
	
	// melody
	\scale, Scale.dorian,
	\degree, Pshuf([-1, 0, 2, 4, 6, 7], inf),
	\octave, Pbjorklund(5, 8).linlin(0, 1, 3, Pseq([4, 5], inf)),
	
	// volume
	\amp, 0.3,
	\vel, Pseq([1, 0.5, 0.8, 0.7], inf),
	
	//////////////////////////////
	// operator 1
	\op1, 0.25,
	\op1ratio, 1,
	\op1atk, 0.01,
	\op1dec, 0.5,
	\op1suslevel, 1,
	\op1rel, 2,
	\op1curve, -4,
	// one-pole coefficient
	\op1coef, 0.2,
	\op1pan, Pwhite(-0.5, 0.5),
	
	// operator 2
	\op2, 0.5,
	\op2ratio, 3,
	\op2atk, 0.07,
	\op2dec, 0.4,
	\op2suslevel, 0.5,
	\op2rel, Pkey(\op1rel) * 0.5,
	\op2curve, 2,
	// one-pole coefficient
	\op2coef, 0.25,
	\op2pan, Pwhite(-0.3, 0.3),
	
	// operator 3
	\op3, 1,
	\op3ratio, 3,
	\op3atk, 0.01,
	\op3dec, 0.3,
	\op3suslevel, 0.7,
	\op3rel, 2,
	\op3curve, 3,
	// one-pole coefficient
	\op3coef, 0.25,
	\op3pan, Pwhite(-1.0,1.0),
	
	// operator 4
	\op4, 0.7,
	\op4ratio, 5,
	\op4atk, 0.01,
	\op4dec, 0.1,
	\op4suslevel, 0.4,
	\op4rel, 0.5,
	\op4curve, -4,
	// one-pole coefficient
	\op4coef, 0.3,
	\op4pan, Pwhite(-1.0,1.0),
	
	//////////////////////////////
	// modulators
	// 0pi to 2pi seems to be most useful range
	\m1_1, Pwhite(0.0,0.1)*pi, //feedback
	\m1_2, 0.2pi,
	\m1_3, 0pi,
	\m1_4, 0.5pi,
	
	\m2_1, 0pi,
	\m2_2, 0pi, //feedback
	\m2_3, 0.2pi,
	\m2_4, 0pi,
	
	\m3_1, 0.2pi,
	\m3_2, 0.1pi,
	\m3_3, 0.3pi, //feedback
	\m3_4, 0.3pi,
	
	\m4_1, 0.1pi,
	\m4_2, 0.1pi,
	\m4_3, 0.0pi,
	\m4_4, 0.3pi, //feedback
	
	// \lpf, Pseg(Pwhite(100.0,3500.0), Prand([16,32,48,64],inf), \exp, inf),
	\hpf, 80
));

Pdef(\pm).play;


)

(
(
Ndef(\verb).play;
Ndef(\verb).filter(1, {arg in;
	var sig = HPF.ar(in, 220);
	Greyhole.ar(sig,  delayTime: 1.0,  damp: 0.3,  size: 1.0,  diff: 0.707,  feedback: 0.9,  modDepth: 0.1,  modFreq: 2.0)
	// FreeVerb2.ar(sig[0], sig[1], 1, 0.9, 0.5);
}).set(\wet1, 0.4);

Pdef(\pm, Pbind(
	\instrument, \pm5,
	\out, Pfunc({Ndef(\verb).bus}),
	\detunehz, 1,
	\vdepth, 0.003,
	
	// rhythm
	\legato, 0.9,
	\dur, 0.25,
	\tempo, 1,
	
	// melody
	\scale, Scale.dorian,
	\degree, Pshuf([-1, 0, 2, 4, 6, 7], inf),
	\octave, Pbjorklund(5, 8).linlin(0, 1, 3, Pseq([4, 5], inf)),
	
	// volume
	\amp, 0.3,
	\vel, Pseq([1, 0.5, 0.8, 0.7], inf),
	
	//////////////////////////////
	// operator 1
	\op1, 0.25,
	\op1ratio, 1,
	\op1atk, 0.01,
	\op1dec, 0.5,
	\op1suslevel, 1,
	\op1rel, 2,
	\op1curve, -4,
	// one-pole coefficient
	\op1coef, 0.2,
	\op1pan, Pwhite(-0.5, 0.5),
	
	// operator 2
	\op2, 0.5,
	\op2ratio, 3,
	\op2atk, 0.07,
	\op2dec, 0.4,
	\op2suslevel, 0.5,
	\op2rel, Pkey(\op1rel) * 0.5,
	\op2curve, 2,
	// one-pole coefficient
	\op2coef, 0.25,
	\op2pan, Pwhite(-0.3, 0.3),
	
	// operator 3
	\op3, 1,
	\op3ratio, 3,
	\op3atk, 0.01,
	\op3dec, 0.3,
	\op3suslevel, 0.7,
	\op3rel, 2,
	\op3curve, 3,
	// one-pole coefficient
	\op3coef, 0.25,
	\op3pan, Pwhite(-1.0,1.0),
	
	// operator 4
	\op4, 0.7,
	\op4ratio, 5,
	\op4atk, 0.01,
	\op4dec, 0.1,
	\op4suslevel, 0.4,
	\op4rel, 0.5,
	\op4curve, -4,
	// one-pole coefficient
	\op4coef, 0.3,
	\op4pan, Pwhite(-1.0,1.0),
	
	//////////////////////////////
	// modulators
	// 0pi to 2pi seems to be most useful range
	\m1_1, Pwhite(0.0,0.1)*pi, //feedback
	\m1_2, 0.2pi,
	\m1_3, 0pi,
	\m1_4, 0.5pi,
	
	\m2_1, 0pi,
	\m2_2, 0pi, //feedback
	\m2_3, 0.2pi,
	\m2_4, 0pi,
	
	\m3_1, 0.2pi,
	\m3_2, 0.1pi,
	\m3_3, 0.3pi, //feedback
	\m3_4, 0.3pi,
	
	\m4_1, 0.1pi,
	\m4_2, 0.1pi,
	\m4_3, 0.0pi,
	\m4_4, 0.3pi, //feedback
	
	\lpf, Pseg(Pseq([100,500,100,1500]), Prand([16,32,48,64],inf), \exp, inf),
	\hpf, 80
));

Pdef(\pm).stop;

Pdef(\pm5, 
	Pbindf(
		Pdef(\pm), \octave, Pkey(\octave) + 1, \dur, Pkey(\dur) / 2.0
	)
).stop;

Pdef(\pm6, 
	Pbindf(
		Pdef(\pm), \octave, Pkey(\octave) - 1, \dur, Pkey(\dur) / 1.5 
	)
).stop;

Pdef(\pms, Ptpar([0.0, Pdef(\pm), 8, Pdef(\pm5), 12, Pdef(\6)])).play
)
)

Env.at

(
[\sine, \tri].do{|zzz|
	SynthDef.new(zzz, {|out=0|
		var sig = if (zzz == \sine, {
			SinOsc.ar(141);
		}, {
			LFTri.ar(141);
		});

		Out.ar(out, Env.perc.kr(gate:1) * sig * 0.25)
	}).add;
};

SynthDef.new(\pis, {|out=0|
		var sig = 
			SinOsc.ar(141);

		Out.ar(out, Env.perc.kr(gate:1) * sig * 0.25)
	}).add;
)
Synth(\pis)

Synth(\lol, [\waveshapeCrossfade, -1, \waveshapeBufferA, ~shaperBuffers.choose, \waveshapeBufferB, ~shaperBuffers.choose])
o.allControlNames

(
Pbind(
	\instrument, \pm4_xshaped,
	\freq, Pwhite(100.0,200.0),
	\lpf, 1500.0,
	\dur, 0.25,
	\waveshapeCrossfade, Pwhite(-1.0,1.0), 
	\waveshapeBufferA, ~shaperBuffers.choose, 
	\waveshapeBufferB, ~shaperBuffers.choose
).play

)

Synth(\pm8_xshaped, [\t_gate, 1, \waveshapeCrossfade, -1, \waveshapeBufferA, ~shaperBuffers.choose, \waveshapeBufferB, ~shaperBuffers.choose])

