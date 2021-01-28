// Benjolin inspired synth by Alejandro Olarte
// https://scsynth.org/t/benjolin-inspired-instrument/1074

/*

Synth(\benjo_sine, [\dur, 8, \rungler2, 1, \freq, exprand(80,250), \filtFreq, exprand(80,500)]);

(
// s.record;
Pbind(
	\instrument, \benjo_tadsr, 
	\rungler1, Pbrown(0.0,1.0,0.001), 
	\rungler2, Pbrown(0.0,0.9,0.001) - Pkey(\rungler1), 
	\pan, Pwhite(-1.0,1.0),
	\dur, 1,
	// \attack, 1.5,
	// \decay, 2,
	\loop, 0, //Pwhite(0,1),
	\freq, Pwhite(80,500),
	\filtFreq, Pwhite(40,100),
	\freq2, Pwhite(2,400),
	\filterType, Pwhite(0,3),
	\outSignal, Pwhite(0,5),
).play
)

*/
{|numChannels=2|
	MKSynthLib.getEnvelopeNamesForKind.do{|envType|

		var basename = "benjo";
		var name = "%_%".format(basename, envType).asSymbol;

		MKSynthLib.addSynthName(name, kind: \mono);

		SynthDef.new(name, { |out=0, envDone=2,dur=1, freq= 40, freq2=4, scale=1, rungler1=0.16, rungler2=0.0, runglerFilt=9, loop=0, filtFreq=40, q=0.82, gain=1, filterType=0, outSignal=6, amp=0.5|
			var osc1, osc2, tri1, tri2, sh0, sh1, sh2, sh3, sh4, sh5, sh6, sh7, sh8=1, rungler, pwm, filt, sig;
			var sr;
			var osc2freq, buf, bufR;
			var filters, outs;

			bufR = LocalIn.ar(2,0);
			rungler = bufR.at(0);
			buf = bufR.at(1);

			sr = SampleDur.ir;
			//sr = ControlDur.ir;
			tri1 = LFTri.ar((rungler*rungler1)+freq);
			tri2 = LFTri.ar((rungler*rungler2)+freq2);
			osc1 = PulseDPW.ar((rungler*rungler1)+freq);
			osc2 = PulseDPW.ar((rungler*rungler2)+freq2);

			//pwm = tri1 > tri2;
			pwm = BinaryOpUGen('>', (tri1 + tri2),(0));

			osc1 = ((buf*loop)+(osc1* (loop* -1 +1)));
			sh0 = BinaryOpUGen('>', osc1, 0.5);
			sh0 = BinaryOpUGen('==', (sh8 > sh0), (sh8 < sh0));
			sh0 = (sh0 * -1) + 1;

			sh1 = DelayN.ar(Latch.ar(sh0,osc2),0.01,sr);
			sh2 = DelayN.ar(Latch.ar(sh1,osc2),0.01,sr*2);
			sh3 = DelayN.ar(Latch.ar(sh2,osc2),0.01,sr*3);
			sh4 = DelayN.ar(Latch.ar(sh3,osc2),0.01,sr*4);
			sh5 = DelayN.ar(Latch.ar(sh4,osc2),0.01,sr*5);
			sh6 = DelayN.ar(Latch.ar(sh5,osc2),0.01,sr*6);
			sh7 = DelayN.ar(Latch.ar(sh6,osc2),0.01,sr*7);
			sh8 = DelayN.ar(Latch.ar(sh7,osc2),0.01,sr*8);

			//rungler = ((sh6/8)+(sh7/4)+(sh8/2)); //original circuit
			//rungler = ((sh5/16)+(sh6/8)+(sh7/4)+(sh8/2));

			rungler = ((sh1/2.pow(8))+(sh2/2.pow(7))+(sh3/2.pow(6))+(sh4/2.pow(5))+(sh5/2.pow(4))+(sh6/2.pow(3))+(sh7/2.pow(2))+(sh8/2.pow(1)));

			buf = rungler;
			rungler = (rungler * scale.linlin(0,1,0,127));
			rungler = rungler.midicps;

			LocalOut.ar([rungler,buf]);

			filters = [
				RLPF.ar(pwm,(rungler*runglerFilt)+filtFreq,q* -1 +1,gain),
				//BMoog.ar(pwm,(rungler*runglerFilt)+filtFreq,q,0,gain),
				RHPF.ar(pwm,(rungler*runglerFilt)+filtFreq,q* -1 +1,gain),
				SVF.ar(pwm,(rungler*runglerFilt)+filtFreq,q,1,0,0,0,0,gain),
				DFM1.ar(pwm,(rungler*runglerFilt)+filtFreq,q,gain,1)
			];

			filt = Select.ar(filterType % filters.size, filters);
			// filt = SelectX.ar(filterType * (filters.size-1), filters);

			outs = [tri1, osc1, tri2, osc2, pwm, sh0, filt];
			sig = Select.ar((outSignal % outs.size), outs);
			// sig = SelectX.ar(outSignal * (outs.size-1), outs);

			sig = LeakDC.ar(sig * amp);

			// Envelope
			sig = MKSynthLib.embedWithVCA(envType, \oneshot, sig, dur, envDone);

			// Panning
			sig = SynthDef.wrap(
				~panFunc.value(numChannelsIn: 1, numChannelsOut: numChannels),  
				prependArgs: [sig]
			);

			Out.ar(out, sig);
		}).add;


	};
};
