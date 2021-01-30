{|numChannelsOut=2|

	~numChannels = numChannelsOut;

	s.waitForBoot{
		fork{

			PathName(MKSynthLib.path +/+ "components").filesDo{|file| 
				var path = file.fullPath.postln;
				MKSynthLib.poster("Loading %".format(file.fileName));
				path.load
			};

			s.sync;
			
			// Synths that need to be manually killed
			PathName(MKSynthLib.path +/+ "synths").folders.do{|directory|
				directory.filesDo{|file|
					var path = file.fullPath;
					MKSynthLib.poster("Loading %".format(file.fileName));
					path.load.value(numChannels: numChannelsOut);
				};
			};

			s.sync;
			MKSynthLib.poster("DONE LOADING MKSynthLib");
			MKSynthLib.poster("Want to try something?");
			MKGenPat.new(MKSynthLib.synths[\oneshot].choose);

			// See and test all loaded SynthDefs:
			// SynthDescLib.global.browse;

		};

	};
}
