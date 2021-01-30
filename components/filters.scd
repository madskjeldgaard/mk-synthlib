(
var filters = (
	dfm1: {|suffix|
		{|sig|

			DFM1.ar(
				sig, 
				MKNC.ar("cutoff", 1500, suffix: suffix),
				MKNC.ar("resonance", 0.5, suffix:suffix), 
				MKNC.ar("filterGain", 1.0, suffix: suffix), 
				MKNC.ar("filterType", 0.0, suffix: suffix), 
				MKNC.ir("filterNoise", 0.0003, suffix: suffix)
			)

		}
	},
	svf: {|suffix|
		{|sig|
			SVF.ar(
				sig,
				MKNC.ar("cutoff", 1500, suffix: suffix),
				MKNC.ar("resonance", 0.5, suffix: suffix),
				MKNC.ar("lowpassAmount", 1.0, suffix: suffix),
				MKNC.ar("bandpassAmount", 0.0, suffix: suffix),
				MKNC.ar("highpassAmount", 0.0, suffix: suffix),
				MKNC.ar("notchAmount", 0.0, suffix: suffix),
				MKNC.ar("filterPeak", 0.0, suffix: suffix),
			)
		}
	},
	// Picked this up here: https://scsynth.org/t/morphing-filters/1790/6
	morphing: {|suffix|
		{|sig|
			var freq = MKNC.ar("morphFreq", 1500, suffix: suffix);

			// Render Low/Band/High-pass signals
			var lp = BLowPass4.ar(sig, freq, rq: 0.25);
			var bp = BHiPass4.ar(lp, freq: freq, rq: 1);
			var hp = BHiPass4.ar(sig, freq: freq, rq: 0.3);

			// Mix through signals
			var morphAmount = MKNC.ar("filterMorph", 0.5, suffix:suffix);
			LinSelectX.ar((morphAmount * 2), [lp, bp, hp]);
		}
	},
	morphingParallel: {|suffix|
		{|sig|
			var filters = Array.fill(2, {|filterNum|
				var freq = MKNC.ar("morphFreq", 1500, suffix: (filterNum+1).asString ++ suffix);

				// Render Low/Band/High-pass signals
				var lp = BLowPass4.ar(sig, freq, rq: 0.25);
				var bp = BHiPass4.ar(lp, freq: freq, rq: 1);
				var hp = BHiPass4.ar(sig, freq: freq, rq: 0.3);

				// Mix through signals
				var morphAmount = MKNC.ar("filterMorph", 0.5, suffix:(filterNum+1).asString ++ suffix);
				LinSelectX.ar((morphAmount * 2), [lp, bp, hp]);
			});
			sig
		}
	},
);

filters
)
