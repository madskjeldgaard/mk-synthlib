(
MKSynthLib.add("varsaw", {
	VarShapeOsc.ar(
		freq: MKNC.kr("freq", 100, spec: Spec.specs[\freq]),  
		pw: MKNC.kr("pw", 0.5),  
		waveshape: MKNC.kr("waveshape", 0.5),  
		sync: MKNC.kr("sync", 1),  
		syncfreq: MKNC.kr("syncfreq", 100, spec: Spec.specs[\freq])
	);
}, numChannelsIn: 1);
)
