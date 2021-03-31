(
MKSynthLib.add("harmonic", {
	var amplitudes = Array.fill(16, {|i| MKNC.kr("amp%".format(i+1), 1/16) });
	HarmonicOsc.ar(freq: MKNC.kr("freq", 100),  firstharmonic: MKNC.kr("first", 3),  amplitudes: amplitudes)
}, numChannelsIn: 1);
)
