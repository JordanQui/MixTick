// ================= SynthDef BufferPlayer =================
SynthDef(\bufferPlayer, {
    |out=0, bufnum=0, trig=1, pitch=1, amp=0.5,
     low=0, mid1=0, mid2=0, high=0,
     cue=0, cuegain=1,
     loopOn=0, bpm=120,
     smoothTime=0.01, fadeTime=0.05| // fadeTime = fondu aux bords de la boucle

    var bufFrames, rate, measureDurSec, measureFrames;
    var phasorNormal, loopStart, loopEnd, phasorLoop;
    var sigNormal, sigLoop, sig;
    var fadeFrames, fadeInLoop, fadeOutLoop, fadeEnvLoop;
    var loopOnLag, fadeEnvNormal, loopMixEnv;
    var trigImpulse, crossEnv;

    // === Infos buffer ===
    bufFrames = BufFrames.kr(bufnum);
    rate = BufRateScale.kr(bufnum) * pitch;

    // === Durée d'une mesure en frames (4 temps) ===
    measureDurSec = (60 / bpm) * 4;
    measureFrames = measureDurSec * BufSampleRate.kr(bufnum);

    // === Trigger pour relancer la boucle ===
    trigImpulse = Trig1.kr(Changed.kr(trig), 0.001);

    // === Phasor normal (lecture libre) ===
    phasorNormal = Phasor.ar(
        rate: rate,
        start: 0,
        end: bufFrames
    );

    // === Points de boucle latched sur le trigger ===
    loopStart = Latch.kr(phasorNormal, trigImpulse);
    loopEnd   = loopStart + measureFrames;

    // === Phasor en mode boucle ===
    phasorLoop = Phasor.ar(
        trig: trigImpulse,
        resetPos: loopStart,
        rate: rate,
        start: loopStart,
        end: loopEnd
    );

    // === Lecture audio ===
    sigNormal = BufRd.ar(2, bufnum, phasorNormal, loop: 1);
    sigLoop   = BufRd.ar(2, bufnum, phasorLoop, loop: 1);

    // === Fade sur les bords de la boucle ===
    fadeFrames = fadeTime * BufSampleRate.kr(bufnum);
    fadeInLoop  = ((phasorLoop - loopStart) / fadeFrames).clip(0, 1);
    fadeOutLoop = ((loopEnd - phasorLoop) / fadeFrames).clip(0, 1);
    fadeEnvLoop = fadeInLoop * fadeOutLoop;
    sigLoop = sigLoop * fadeEnvLoop;

    // === Crossfade normal <-> loop ===
    loopOnLag     = Lag.kr(loopOn, 0.1);
    fadeEnvNormal = (1 - loopOnLag);
    loopMixEnv    = loopOnLag;
    sig = (sigNormal * fadeEnvNormal) + (sigLoop * loopMixEnv);

    // === Anti-clic supplémentaire lors d’un changement de trig ===
    crossEnv = Lag.kr(Changed.kr(trig), smoothTime);
    sig = (sig * (1 - crossEnv)) + (sigLoop * crossEnv);

    // === EQ ===
    sig = BLowShelf.ar(sig, freq: 100, rs: 0.7, db: low);
    sig = BPeakEQ.ar(sig, freq: 300, rq: 0.7, db: mid1);
    sig = BPeakEQ.ar(sig, freq: 800, rq: 0.7, db: mid2);
    sig = BHiShelf.ar(sig, freq: 4000, rs: 0.7, db: high);

    // === Sorties ===
    Out.ar(out, sig.tanh * amp);                 // Master
    Out.ar(2,   sig.tanh * cue * cuegain);       // Cue (casque)
}).add;

// ================= Limiteur global =================
SynthDef(\outputLimiter, {|input=0, out=0|
    var inSig = In.ar(input, 2);
    var limited = Limiter.ar(inSig, 0.99, 0.01);
    Out.ar(out, limited.tanh);
}).add;
