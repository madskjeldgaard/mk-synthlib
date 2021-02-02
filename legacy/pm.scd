(
// Four operator phase modulation synth
// Originally by David Morgan, modified to my liking
// https://sccode.org/1-5dl
(3..8).do{|numops|
	var basename = "pm%".format(numops);
	MKSynthLib.add(basename, {
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
		// Waveshaping
		sig = MKSynthLib.embedWithWaveshaper(shapeFuncName, sig);

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


	}, numChannelsIn: 2);

};

)
