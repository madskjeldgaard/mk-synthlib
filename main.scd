(
~numChannels = 2;
~synthNames = [];
~envs = "components/singleshot-envelopes.scd".load;
"components/panning.scd".load;

["synths", "effects", "control"].do{|dir|
	PathName.new(dir).filesDo{|file|
		var path = file.fullPath;
		"Loading %".format(file.fileName).postln;

		// Create a synth for each envelope type
		~envs.keys.do{|envtype|
			path.load.value(envType: envtype, numChannels: ~numChannels)
		}
	};
};
)
