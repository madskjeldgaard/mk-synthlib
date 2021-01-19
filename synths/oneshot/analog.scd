/*
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
		\freqModAmount, Pbrown(0.0,0.9,0.001),
		\detuneModAmount, Pbrown(0.0,0.9,0.001),
		\detuneFreq, Pkey(\freq) * Pbrown(0.1,1.0,0.001),
		\detuneModShape, Pwhite(0.0,0.4),
		\filterModAmount, 1.5,
		\resonance, 0.95,
		\cutoff, Pseg(Pwhite(100.0,2500.0), 32, \exp, inf),
		\attack, Pseg(Pseq([0.0001,0.25],inf), 12, \exp, inf),
		\decay, Pseg(Pseq([2,8],inf), 32, \lin, inf) - Pkey(\attack),
		\pan, Pseg(Pseq([0.0,1.0],inf), 16, \lin, inf) * Pwhite(-1.0,1.0)
	)
};

Pdef(\a, 
	Ptpar([
		0.0, ~analogPat.value(\analog_dpw4saw_tadsr, (1/12)),
		13.66, ~analogPat.value(\analog_sawdpw_tadsr, (1/12)),
		21.33, ~analogPat.value(\analog_sawdpw_tadsr, (1/12)),
	])
).play;
)
*/
{|numChannels=2|
	~envs.keys.do{|envType|
		[DPW4Saw, BlitB3Tri, PulseDPW, SawDPW, DPW3Tri, SinOsc].do{|soundSource|

			var basename = "analog";
			var shape = soundSource.name.asString.toLower;
			var name = "%_%_%".format(basename, shape, envType).asSymbol.postln;

			~synthNames = ~synthNames.add(name);

			SynthDef(name, { 
				arg out=0, amp=0.5, freq=441, freqModAmount=0.09, modFreq=5.5,
				detuneFreq=1, detuneModAmount=0.5, detuneModShape=0,
				dur=1, cutoff=1500.0, resonance=0.5, type=0,
				filterModAmount=0.5,
				envDone=2;

				var sig, calculatedCutoff;

				// Envelope
				var env = SynthDef.wrap(~envs[envType],  prependArgs: [dur, envDone]);

				// Detune modulator
				var modulators = [
					SinOsc.kr(modFreq), 
					LFTri.kr(modFreq), 
					LFSaw.kr(modFreq), 
					LFNoise2.kr(modFreq), 
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
				calculatedCutoff = env.lag(Rand(0.1,1.0) * dur / 10.0).linexp(
					0.0,
					1.0,
					((1.0-filterModAmount) * cutoff).clip(20.0,20000.0),
					cutoff
				) * detune.lag(Rand(0.0,0.25) * dur / 10).linlin(-1.0,1.0,1.0,1.0-filterModAmount);

				sig = DFM1.ar(
					sig,  
					calculatedCutoff.clip(20.0,20000.0),	
					resonance,  
					type: type,  
					noiselevel: 0.0003
				);

				// Panning
				sig = sig * env;
				sig = SynthDef.wrap(
					~panFunc.value(numChannelsIn: 2, numChannelsOut: numChannels),  
					prependArgs: [sig]);

					// Output stage
					Out.ar(out, sig * amp);
				}).add;

			};

		};
	}
