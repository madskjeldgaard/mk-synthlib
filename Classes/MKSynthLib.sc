MKSynthLib { 
	*new {|numChannelsOut=2|
		^super.new.init( numChannelsOut );
	}

	init{|numChannels|
		var thisPath = Main.packages.asDict.at('mk-synthlib');
		var synthlibLoader = load(thisPath +/+ "main.scd");
		Server.local.doWhenBooted{
			this.loadMessage;
			synthlibLoader.value(numChannelsOut: numChannels);
		}
	}

	loadMessage{
		"----------".postln;
		"Loading mk-synthlib".postln;
		100.do{
			["🤠", "🪱", "🦑", "🥀", "🌻", "🍁", "🍇",  "🦞", "🍍", "🧀" ].choose.post;
		};

	}
}
