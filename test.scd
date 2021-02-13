MKSynthLib();
b = Buffer.read(s, MKSynthLib.sndPath+/+"harmshort-mono.wav");

b = Buffer.readChannel(s, "~/testsound/harmshort.wav".asAbsolutePath);

Synth(\bufgrain2_tadsr_dfm1_ws , [\buffer, b, \dur, 4, \density, 80.5,\legato, 1, \grainsize, 0.75, \windowrand, 0.9, \grainfreqScale, 0.25, \grainshape, 0.9, \grainoverlap, 16])

Synth(\warpoverlap1_tadsr_dfm1_n, [\buffer, b, \dur, 4, \grainsize, 0.25, \grainfreqScale, 0.5])

