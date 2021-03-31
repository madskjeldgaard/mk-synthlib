(
MKSynthLib.add("formant", {
	NeoFormant.ar(
		formantfreq: MKNC.kr("freq", 100),  
		carrierfreq: MKNC.kr("carrierfreq", 250, spec: Spec.specs[\freq]),  
		phaseshift: MKNC.kr("phasehift", 0.5)
	)
	}, numChannelsIn: 1);
)
