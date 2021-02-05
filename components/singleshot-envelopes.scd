(
var envs = (
		// Same as Env.adsr but with release node set to nil to make it triggered
		tadsr:{ |prefix, suffix|
			{ |dur=1, envDone=2|
				var attack=MKNC.kr("attack", 0.01, suffix: suffix, prefix: prefix), 
				decay=MKNC.kr("decay", 0.3, suffix: suffix, prefix: prefix), 
				sustainLevel=MKNC.kr("sustainLevel", 0.5, suffix: suffix, prefix: prefix), 
				release=MKNC.kr("release", 1.0, suffix: suffix, prefix: prefix), 
				peakLevel=MKNC.kr("peakLevel", 1.0, suffix: suffix, prefix: prefix), 
				curve = MKNC.kr("curve", -4.0, suffix: suffix, prefix: prefix), 
				bias = MKNC.kr("bias", 0.0, suffix: suffix, prefix: prefix), 
				gate=MKNC.kr("gate", 1, suffix:suffix, prefix:prefix),
				legato = MKNC.kr("legato", 1);


				EnvGen.kr(
				Env.new(			
				[0, peakLevel, peakLevel * sustainLevel, 0] + bias,
						[attack, decay, release],
						curve
				),
					gate,  
					timeScale:legato * dur,
					levelBias: 0,
					levelScale: 1.0,
					doneAction: envDone
				)
			}
		},
		perc: { |prefix, suffix|
			{|dur=1, envDone=2|
				var attack=MKNC.kr("attack", 0.1, suffix: suffix, prefix: prefix), 
				release=MKNC.kr("release", 0.9, suffix: suffix, prefix: prefix), 
				envcurve=MKNC.kr("envcurve", -5.0, suffix: suffix, prefix: prefix), 
				gate=MKNC.kr("gate", 1, suffix: suffix, prefix: prefix),
				legato = MKNC.kr("legato");

				EnvGen.kr(
				Env.perc(attack, release,  level: 1.0,  curve: envcurve),
					gate,  
					timeScale:legato * dur,
					levelBias: 0,
					levelScale: 1.0,
					doneAction: envDone
				)
			}
		},
		/*
		sine:{ |dur=1, envDone=2, gate=1|
		EnvGen.kr(
		Env.sine(1,  level: 1.0),
		gate,  
		timeScale:dur,
		levelBias: 0,
		levelScale: 1.0,
		doneAction: envDone
		)
		},
		triangle:{ |dur=1, envDone=2, gate=1|
		EnvGen.kr(
		Env.triangle(1,  level: 1.0),
		gate,  
		timeScale:dur,
		levelBias: 0,
		levelScale: 1.0,
		doneAction: envDone
		)
		}
		*/
); 

envs.keysValuesDo({|envName, env|
	MKSynthLib.addEnvelope(envName, \oneshot, env)
})
)
