(
~numChannels = 2;
~synthNames = [];

PathName("components").filesDo{|file| 
	var path = file.fullPath;
	"Loading %".format(file.fileName).postln;
	path.load
};

// Synths that need to be manually killed
PathName("synths").folders.do{|directory|
	directory.filesDo{|file|
		var path = file.fullPath;
		"Loading %".format(file.fileName).postln;

		path.load.value(numChannels: ~numChannels)
	};
};

// See and test all loaded SynthDefs:
// SynthDescLib.global.browse;

)
