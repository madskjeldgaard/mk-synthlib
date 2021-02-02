(
	MKSynthLib.add(\warp2, {|buffer| 
		var numchannels = 2;
		var rate = MKNC.kr("grainrate", 0.5);
		var pointer = LFSaw.ar(rate).range(0.0,1.0);

		var shape = MKSynthLib.embedWithGrainShapes();

		var sig = Warp1.ar(numChannels: numchannels, 
			bufnum: buffer, 
			pointer: pointer, 
			freqScale: MKNC.kr("grainfreqScale", 1), 
			windowSize: MKNC.kr("grainsize", 0.1), 
			envbufnum: shape, 
			overlaps: MKNC.kr("grainoverlap", 10), 
			windowRandRatio: MKNC.kr("windowrand", 0.0), 
			interp: 4);

			LeakDC.ar(sig);
	}, numChannelsIn: 2);

)
