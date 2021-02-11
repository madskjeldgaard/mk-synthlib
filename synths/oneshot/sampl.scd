(
[1,2].do{|numChannels| MKSynthLib.add("sampler%".format(numChannels), {
	|buffer, rate=1, loop=1, direction=0, startPosition=0|
	var dir = Select.kr(direction, [1,(-1)]);

	PlayBuf.ar(numChannels, 
		buffer, 
		dir * rate * BufRateScale.kr(buffer), 
		startPos: startPosition * BufFrames.kr(buffer),
		loop: loop
	)}, numChannelsIn: numChannels)
};
)

