(
	// Overlapping sampler
	(2..4).do{|numOverlaps| [1,2].do{|numChannels| 
	MKSynthLib.add("sampleroverlap%x%".format(numChannels, numOverlaps), {
		|buffer, rate=1, loop=1, direction=0|
		var dir = Select.kr(direction, [1,(-1)]);
		var wowParam = MKNC.kr("wow", 0);
		var wow = LFNoise2.kr(
			wowParam.linexp(0.0,1.0,0.01,10.0)
		).range(1.0 + wowParam, 1.0 - wowParam);

		var sig = Array.fill(numOverlaps, {|overlapNum|
			var offset = MKNC.kr("playheadOffset", overlapNum/numOverlaps, suffix: overlapNum);

			PlayBuf.ar(numChannels, 
				buffer, 
				dir * rate * BufRateScale.kr(buffer) * wow,
				startPos: offset * BufFrames.kr(buffer),
				loop: loop
			)
		});

		sig = if(numChannels == 1, {
			Splay.ar(sig).sum
		}, { 
			Splay.ar(sig)
		});

		sig

	}, numChannelsIn: numChannels)

	}
	}
)
