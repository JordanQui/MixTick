// ================= SynthDef BufferPlayer =================
SynthDef(\bufferPlayer, {
    |out=0, bufnum=0, trig=0, pitch=1, amp=0.5,
     low=0, mid1=0, mid2=0, high=0,
     cue=0, cuegain=1,
     loopOn=0, bpm=120|

    var bufFrames, rate, measureDurSec, measureFrames;
    var phasorNormal, loopStart, loopEnd, phasorLoop;
    var sigNormal, sigLoop, sig;
    var trigImpulse;

    // === Infos buffer ===
    bufFrames  = BufFrames.kr(bufnum);
    rate       = BufRateScale.kr(bufnum) * pitch;

    // === Durée d'une mesure en frames ===
    measureDurSec  = (60 / bpm) * 4;
    measureFrames  = measureDurSec * BufSampleRate.kr(bufnum);

    // === Trigger pour définir le point de boucle ===
    trigImpulse = Trig1.kr(trig, 0.001);

    // === Phasor normal ===
    phasorNormal = Phasor.ar(rate: rate, start: 0, end: bufFrames);

    // === Points de boucle (capturés au trig) ===
    loopStart = Latch.kr(phasorNormal, trigImpulse);
    loopEnd   = loopStart + measureFrames;

    // === Phasor bouclé (wrap forcé entre start et end) ===
    phasorLoop = (phasorNormal - loopStart).wrap(0, loopEnd - loopStart) + loopStart;

    // === Lecture audio ===
    sigNormal = BufRd.ar(2, bufnum, phasorNormal, loop: 1);
    sigLoop   = BufRd.ar(2, bufnum, phasorLoop, loop: 1);

    // === Crossfade normal <-> loop ===
    sig = SelectX.ar(loopOn, [sigNormal, sigLoop]);

    // === EQ ===
    sig = BLowShelf.ar(sig, freq: 100, rs: 0.7, db: low);
    sig = BPeakEQ.ar(sig, freq: 300, rq: 0.7, db: mid1);
    sig = BPeakEQ.ar(sig, freq: 800, rq: 0.7, db: mid2);
    sig = BHiShelf.ar(sig, freq: 4000, rs: 0.7, db: high);

    // === Sorties ===
    Out.ar(out, sig.tanh * amp);            // Master
    Out.ar(2,   sig.tanh * cue * cuegain);  // Cue (casque)
}).add;


// ================= Limiteur global =================
SynthDef(\outputLimiter, {|input=0, out=0|
    var inSig = In.ar(input, 2);
    var limited = Limiter.ar(inSig, 0.99, 0.01);
    Out.ar(out, limited.tanh);
}).add;
