(
~synthNames = [];
~envs = "components/singleshot-envelopes.scd".load;

["synths", "effects", "control"].do{|dir|
	PathName.new(dir).filesDo{|file|
		var path = file.fullPath;
		"Loading %".format(file.fileName).postln;

		// Create a synth for each envelope type
		~envs.keys.do{|envtype|
			path.load.value(envType: envtype)
		}
	};
};

)

Synth(\analog_sawdpw_perc, [\freq, 100,\pan, 0.0, \freqModAmount, 0, \detuneModAmount,0 ])

Pdef(\a).play

Saw.name.asString.toLower

Synth(~synthNames.choose.postln, [\amp, 0.1, \freq, exprand(40.0,200.0)])
(
Pbind(
	\instrument, Prand([
		\analog_dpw4saw_perc,
		\analog_blitb3tri_perc,
		\analog_pulsedpw_perc,
		\analog_sawdpw_perc,
		\analog_dpw3tri_perc,
		\analog_sinosc_perc,
		\analog_dpw4saw_triangle,
		\analog_blitb3tri_triangle,
		\analog_pulsedpw_triangle,
		\analog_sawdpw_triangle,
		\analog_dpw3tri_triangle,
		\analog_sinosc_triangle,
		\analog_dpw4saw_sine,
		\analog_blitb3tri_sine,
		\analog_pulsedpw_sine,
		\analog_sawdpw_sine,
		\analog_dpw3tri_sine,
		\analog_sinosc_sine,
	],inf).trace,
	\dur, 0.25,
	\cutoff, 500,
).play
)
