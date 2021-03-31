(
MKSynthLib.add("oscbank", {
	OscBank.ar(
		freq:MKNC.kr("freq", 100),  
		gain:MKNC.kr("gain", 1),  
		saw8:MKNC.kr("saw8", 0.5),  
		square8:MKNC.kr("square8", 0.5),  
		saw4:MKNC.kr("saw4", 0.5),  
		square4:MKNC.kr("square4", 0.5),  
		saw2:MKNC.kr("saw2", 0.5),  
		square2:MKNC.kr("square2", 0.5),  
		saw1:MKNC.kr("saw1", 0.5)
	)
	}, numChannelsIn: 1);
)
