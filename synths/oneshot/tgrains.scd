(
	[1, 2].do{|numChans|

	MKSynthLib.add("tgrains3x%".format(numChans), {|density=10, grainsize=0.1, grainpos=0, grainrate=0.5, buffer| 
		var trigger = Dust2.kr(density);
		var shape = MKSynthLib.embedWithGrainShapes(); 

		// BufGrain.ar(trigger, 1, buffer)
		TGrains3.ar(numChans, 
			trigger: trigger, 
			bufnum: buffer, 
			rate: grainrate, 
			centerPos: grainpos, 
			dur: graindur, 
			pan: 0, 
			amp: 0.9, 
			att: graindur / 2, 
			dec: graindur / 2, 
			window: shape, 
			interp: 4
		)
	}, numChannelsIn: numChans);
	}
)
