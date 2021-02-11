(
	MKSynthLib.add(\grainsin, {|freq=100, density=10, graindur=0.1, panwidth=0.5| 
		var trigger = Dust2.ar(density);
		var maxgrains = 512;
		var numchannels = 2;
		var shape = MKSynthLib.embedWithGrainShapes();

		GrainSin.ar(numchannels, 
			trigger, 
			graindur, 
			freq, 
			panwidth * LFNoise2.kr(1), 
			shape, 
			maxgrains
		);

	}, numChannelsIn: 2);
)
