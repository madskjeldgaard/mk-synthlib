// Four operator phase modulation synth
// Originally by David Morgan, modified to my liking
// https://sccode.org/1-5dl

// One of the many great things about the open source music technology world is to be able to stumble upon other people's great work and reuse it. I found this gem of a phase modulation synth (with a beautiful example composition to go with it) today and it is the most touching encounter I have had with an algorithm in a while.
// You can find the SuperCollider code for it here: https://sccode.org/1-5dl

/*
(
Ndef(\verb).play;
Ndef(\verb).filter(1, {arg in;
	var sig = HPF.ar(in, 220);
	Greyhole.ar(sig,  delayTime: 0.5,  damp: 0.1,  size: 0.1,  diff: 0.707,  feedback: 0.9,  modDepth: 0.1,  modFreq: 2.0)
	// FreeVerb2.ar(sig[0], sig[1], 1, 0.9, 0.5);
}).set(\wet1, 0.2);

Pdef(\pm, Pbind(
	\instrument, \pm5_xshaped,
	\out, Pfunc({Ndef(\verb).bus}),
	\detunehz, 1,
	\vdepth, 0.003,

	// rhythm
	\legato, 0.9,
	\dur, 0.25,
	\tempo, 1,
	
	// Waveshaping
	\waveshapeA, Pwhite(0,9),
	\waveshapeB, Pwhite(0,9),
	\waveshapeCrossfade, Pwhite(-1.0,1.0),
	\waveshapeAmount, Pseg(Pseq([0.92, 0.34, -0.54, 0.04, -1.0, 0.28, 0.46]), 101, Pwhite(0.7,4.53), inf),

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

	\lpf, Pseg(Pxrand([100,500,1500,2500],inf), Prand([16,32,8],inf), \exp, inf),
	\hpf, 80
));

Pdef(\pm).play;

Pdef(\pm5, 
	Pbindf(
		Pdef(\pm), \octave, Pkey(\octave) + 1, \dur, Pkey(\dur) / 2.0
	)
).play;

Pdef(\pm6, 
	Pbindf(
		Pdef(\pm), \octave, Pkey(\octave) - 1, \dur, Pkey(\dur) / 1.5 
	)
).stop;

)

*/
{|numChannels=2|

	var shapeNames = [\normal, \shaped, \xshaped];
	shapeNames.do{|shapeFuncName|
		(3..8).do{|numops|
			var basename = "pm%".format(numops);
			var name = "%_%".format(basename,shapeFuncName).asSymbol.postln;

			~synthNames = ~synthNames.add(name);

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
					var curve = ('op' ++ num ++ 'curve').asSymbol.kr(rand(-10,10));
					var atk = ('op' ++ num ++ 'atk').asSymbol.kr(rrand(0.001,0.1));
					var dec = ('op' ++ num ++ 'dec').asSymbol.kr(rrand(0.005,0.1));
					var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(0.75);
					var rel = ('op' ++ num ++ 'rel').asSymbol.kr(0.78);
					var env = Env.adsr(
						attackTime:atk * \attack.kr(0.5),
						decayTime:dec * \decay.kr(1.0),
						sustainLevel:suslevel * \sustain.kr(0.9),
						releaseTime:rel * \release.kr(0.5),
						curve:curve
					).kr(gate:gate, timeScale: dur);

					[freq * ratio.kr(i) + Rand(detunehz.neg, detunehz), env]
				});

				var mods = numops.collect({arg i;
					var y = i + 1;
					numops.collect({arg j;
						var x = j + 1;
						var key = ('m' ++ y ++ '_' ++ x).asSymbol;
						key.kr(rrand(0.0,0.2) * pi);
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

				// Shaping
				sig = switch (shapeFuncName,
					\n, {sig},
					\s, { SynthDef.wrap(~waveshapeWrap,  prependArgs: [sig]) },
					\xs,{ SynthDef.wrap(~waveshapeXWrap,  prependArgs: [sig])  },
					sig);

				sig = LeakDC.ar(sig);

				LocalOut.ar(sig);

				// set output level
				sig = sig * numops.collect({arg i;
					var num = i + 1;
					var key = ('op' ++ num).asSymbol;
					key.kr(rrand(0.5,1.0));
				}).normalizeSum;

				// set panning
				sig = numops.collect({arg i;
					var num = i + 1;
					var key = ('op' ++ num ++ 'pan').asSymbol;
					Pan2.ar(sig[i],	key.kr(rrand(-0.1,0.1)),	1)
				}).sum;

				sig = BLowPass.ar(
					BHiPass.ar(sig,
						\hpf.kr(40).clip(20, 18000),
						\hpfres.kr(0).linlin(0, 1, 1, 0.001)
					),
					\lpf.kr(10000).clip(20, 20000),
					\lpfres.kr(0.5).linlin(0, 1, 1, 0.001)
				);

				sig = sig * AmpCompA.kr(freq) * amp * vel;
				sig = sig.softclip;
				DetectSilence.ar(sig, doneAction:Done.freeSelf);

				// Envelope
				// var env = SynthDef.wrap(~envs[envType],  prependArgs: [dur, envDone]);

				// Panning
				sig = SynthDef.wrap(
					~panFunc.value(numChannelsIn: 2, numChannelsOut: numChannels),  
					prependArgs: [sig]
				);

				Out.ar(out, sig);


			}).add;

		};

	};
};

