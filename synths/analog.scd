{|envType=\adsr|
	[DPW4Saw, BlitB3Tri, PulseDPW, SawDPW, DPW3Tri, SinOsc].do{|soundSource|

		var basename = "analog";
		var shape = soundSource.name.asString.toLower;
		var name = "%_%_%".format(basename, shape, envType).asSymbol.postln;

		~synthNames = ~synthNames.add(name);

		SynthDef(name, { 
			arg out=0, amp=0.5, freq=441, freqModAmount=0.09,
			detuneFreq=1, detuneModFreq=5.5, detuneModAmount=0.5, detuneModShape=0,
			pan=1, dur=1, cutoff=1500.0, resonance=0.5, type=0,
			filterModAmount=0.5,
			envDone=2;

			var sig;

			// Envelope
			var env = SynthDef.wrap(~envs[envType],  prependArgs: [dur, envDone]);

			// Detune modulator
			var modulators = [
				SinOsc.kr(detuneModFreq), 
				LFTri.kr(detuneModFreq), 
				LFSaw.kr(detuneModFreq), 
				LFNoise2.kr(detuneModFreq), 
			];

			var detune = SelectX.kr(
				detuneModShape * modulators.size, 
				modulators, 
				wrap: 1
			);

			detune = detune.lag(Rand() * dur * 0.1);

			freq = detune.linexp(-1.0,1.0,freq,(1.0+freqModAmount) * freq); 
			// Source sound
			sig = soundSource.ar(
				freq:
				[
					freq,
					freq - detune.linexp(
						-1.0,
						1.0,
						0.0001, 
						(detuneFreq * detuneModAmount) + 0.0001
					).lag(dur*0.1)
				]

			);

			sig = sig / 2.0;

			// Filtering
			sig = DFM1.ar(
				sig,  
				env.lag(Rand(0.1,1.0) * dur / 10.0).linexp(
					0.0,
					1.0,
					((1.0-filterModAmount) * cutoff).clip(20.0,20000.0),
					cutoff
				),  
				resonance,  
				type: type,  
				noiselevel: 0.0003
			);

			// Panning
			// sig = Pan2.ar(sig, pan);
			sig = sig * env;

			// Output stage
			Out.ar(out, sig * amp);
		}).add;

	};
}
