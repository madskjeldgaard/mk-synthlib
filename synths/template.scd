/*
{|envType, numChannels=2|
		var basename = "template";
		var name = "%_%".format(basename, envType).asSymbol.postln;

		~synthNames = ~synthNames.add(name);

		SynthDef(name, { 
			arg out=0, amp=0.5,
			dur=1,
			envDone=2;

			var sig;

			// Envelope
			var env = SynthDef.wrap(~envs[envType],  prependArgs: [dur, envDone]);

			// Sound source
			sig = Silent.ar();

			// Panning
			sig = SynthDef.wrap(
				~panFunc.value(numChannelsIn: 1, numChannelsOut: numChannels),  
				prependArgs: [sig]
			);

			// Output stage
			Out.ar(out, sig * env * amp);
		}).add;

};
*/
