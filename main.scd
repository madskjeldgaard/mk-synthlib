(
~numChannels = 2;
~synthNames = [];
~envs = "components/singleshot-envelopes.scd".load;
"components/panning.scd".load;

// One shot synths (that are killed by their envelope)
// Create variants for each envelope type
PathName("synths/oneshot").filesDo{|file|
	var path = file.fullPath;
	"Loading %".format(file.fileName).postln;

	// Create a synth for each envelope type
	~envs.keys.do{|envtype|
		path.load.value(envType: envtype, numChannels: ~numChannels)
	};
};

// Synths that need to be manually killed
PathName("synths/mono").filesDo{|file|
	var path = file.fullPath;
	"Loading %".format(file.fileName).postln;

	path.load.value(numChannels: ~numChannels)
};
)
