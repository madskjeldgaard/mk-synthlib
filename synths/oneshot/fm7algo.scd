{
	MKSynthLib.getEnvelopeNamesForKind.do{|envType|
		MKSynthLib.shapeWrapperKinds.do{|shapeFuncName|
			MKFilterLib.filterTypes.do{|filterType|
				32.do{|algo|

					var basename = "fm7";
					var name = "%_algo%_%_%_%".format(basename, algo, envType, filterType, shapeFuncName).asSymbol;

					MKSynthLib.addSynthName(name, kind: \oneshot);

					SynthDef.new(name, {
						arg out=0, amp=0.51, 
						freq=100, 
						ratio=1, 
						detuneAmount=0.1, 
						feedback=0, 
						dur=4, envDone=2;
						var ctrls = Array.fill(6, {|i|
							var phase = rrand(0.0,2pi);
							[freq * (i+1 * ratio) * LFNoise2.kr(rrand(0.5,2.0)).range(1.0, 1.0-(detuneAmount/10.0)), phase, 1]
						});
						var sig = FM7.arAlgo(algo, ctrls, feedback);

						sig = MKSynthLib.embedWithVCA(envType, \oneshot, sig, dur, envDone);
						sig = MKSynthLib.embedWithWaveshaper(shapeFuncName, sig);
						sig = MKFilterLib.new(filterType, sig);
						sig = MKSynthLib.embedWithPanner(2, Splay.ar(sig, spread: 0.25));
						Out.ar(out, sig * amp)
					}).store


				}
			}
		}
	}
}
