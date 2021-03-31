(
MKSynthLib.add("vosim", {
	VosimOsc.ar(
		freq: MKNC.kr("freq", 100),  
		form1freq: MKNC.kr("form1freq", 1054, spec: Spec.specs[\freq]),  
		form2freq: MKNC.kr("form2freq", 454, spec: Spec.specs[\freq]),  
		shape: MKNC.kr("shape", 0, spec: [-1.0,1.0])
	);
	
	}, numChannelsIn: 1);
)
