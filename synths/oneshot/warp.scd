(
	[1,2].do{|numChans|
	MKSynthLib.add("warp%".format(numChans), {|buffer| 
		var rate = MKNC.kr("grainrate", 0.5);
		var pointer = LFSaw.ar(rate).range(0.0,1.0).poll(label: \pointer);

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
		).poll;

		LeakDC.ar(sig);
	}, numChannelsIn: numChans);

	}
)
(
	[1,2].do{|numChans|
	MKSynthLib.add("warpoverlap%".format(numChans), {|buffer| 
		var rate = MKNC.kr("grainrate", 0.5);

		var sig = WarpOverlap.ar(numChans: numChans, 
			buffer: buffer, 
			stretch: rate,
			starttime: MKNC.kr("starttime", 0.5),
			harm: MKNC.kr("grainfreqScale", 1), 
			windowsize: MKNC.kr("overlapWindows", 6),
			step: MKNC.kr("warpstep", 1),
			warpwindowoverlaps: MKNC.kr("grainoverlap", 8), 
			overlaps: 8, 
			warpwindowsize: MKNC.kr("grainsize", 0.1), 
			warpwindowran: MKNC.kr("windowrand", 0.5) 
		).poll;

		LeakDC.ar(sig);
	}, numChannelsIn: numChans);

	}
)
