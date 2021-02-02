(
	MKSynthLib.add(\grainsin, {|freq=100, density=10, graindur=0.1, grainshape=0.5, panwidth=0.5| 
		var trigger = Dust2.kr(density);
		var maxgrains = 512;
		var numchannels = 2;
		var shapebuffers = SynthDef.wrap({ MKSynthLib.grainShapeBuffers.asArray });

		GrainSin.ar(numchannels, 
			trigger, 
			graindur, 
			freq, 
			panwidth * LFNoise2.kr(1), 
			Select.kr(grainshape * shapebuffers.size, shapebuffers), 
			maxgrains
		);

	}, numChannelsIn: 2);
)
