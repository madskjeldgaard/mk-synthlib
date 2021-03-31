(
MKSynthLib.add("varshape", {
	VarShapeOsc.ar(
		freq: MKNC.kr("freq", 100),  
		pw: MKNC.kr("pw", 0.5),  
		waveshape: MKNC.kr("shape", 0.5),  
		sync: MKNC.kr("sync", 1),  
		syncfreq: MKNC.kr("syncfreq", 101, spec: Spec.specs[\freq])
	);
}, numChannelsIn: 1);
)
