(
MKSynthLib.add("zosc", {
	ZOsc.ar(
		freq: MKNC.kr("freq", 100),  
		formantfreq: MKNC.kr("formantfreq", 91, spec: Spec.specs[\freq]),  
		shape: MKNC.kr("shape", 0.5),  
		mode: MKNC.kr("mode", spec: [-1.0,1.0])
	)
}, numChannelsIn: 1);
)
