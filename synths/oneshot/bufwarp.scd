(
	[1,2].do{|numChans|
	MKSynthLib.add("warp%".format(numChans), {|buffer| 
		var rate = MKNC.kr("grainrate", 0.5);
		var pointer = LFSaw.ar(rate).range(0.0,1.0);

		var shape = MKSynthLib.embedWithGrainShapes();

		var sig = Warp1.ar(numChannels: numChans, 
			bufnum: buffer, 
			pointer: pointer, 
			freqScale: MKNC.kr("grainfreqScale", 1), 
			windowSize: MKNC.kr("grainsize", 0.1), 
			envbufnum: shape, 
			overlaps: MKNC.kr("grainoverlap", 2), 
			windowRandRatio: MKNC.kr("windowrand", 0.0), 
			interp: 4
		);

		LeakDC.ar(sig);
	}, numChannelsIn: numChans);

	}
)
