{
	MKSynthLib.getEnvelopeNamesForKind.do{|envType|
		MKSynthLib.shapeWrapperKinds.do{|shapeFuncName|
			32.do{|algo|

				var basename = "fm7";
				var name = "%_algo%_%_%".format(basename, algo, envType, shapeFuncName).asSymbol;

				MKSynthLib.addSynthName(name, kind: \oneshot);

				SynthDef.new(name, {
					arg out=0, amp=0.51, 
						freq=100, cutoff=1500, resonance=0.1, 
						filterType=0, ratio=1, 
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
					sig = DFM1.ar(sig, cutoff, resonance, 1.0, filterType);
					sig = MKSynthLib.embedWithPanner(2, Splay.ar(sig, spread: 0.25));
					Out.ar(out, sig * amp)
				}).add
			}
		}
	}
}
