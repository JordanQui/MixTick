// ================= SynthDef BufferPlayer =================
SynthDef(\bufferPlayer, {
    |out=0, bufnum=0, trig=1, pitch=1, amp=0.5,
     low=0, mid1=0, mid2=0, high=0,
     cue=0, cuegain=1,
     loopOn=0, bpm=120, loopTrig=0, loopBeats=4,
     smoothTime=0.03, fadeTime=0.12| // fadeTime = fondu aux bords de la boucle

    var bufFrames, rate, beatDurSec, loopDurSec, loopFrames;
    var phasorNormal, loopStart, loopEnd, phasorLoop;
    var sigNormal, sigLoopRaw, sigLoop, sig;
    var fadeFrames, fadeInLoop, fadeOutLoop, fadeEnvLoop;
    var loopOnLag, fadeEnvNormal, loopMixEnv;
    var trigImpulse, crossEnv, trigEvents;
    var loopCaptureTrig, loopCaptureImpulse;
    var fadeSafeTime, loopDelayed, retrigEnv;

    // === Infos buffer ===
    bufFrames = BufFrames.kr(bufnum);
    rate = BufRateScale.kr(bufnum) * pitch;

    // === Durée de boucle en frames ===
    beatDurSec = 60 / bpm;
    loopBeats = loopBeats.max(1); // sécurité contre les valeurs nulles
    loopDurSec = beatDurSec * loopBeats;
    // ajuster la longueur de boucle selon le pitch pour garder une durée fixe
    loopFrames = loopDurSec * BufSampleRate.kr(bufnum) * pitch;

    // === Trigger pour relancer la boucle ===
    loopCaptureTrig = HPZ1.kr(loopTrig).max(0);
    loopCaptureImpulse = Trig1.kr(loopCaptureTrig, 0.001);
    trigEvents = HPZ1.kr(trig).max(0) + loopCaptureTrig;
    trigImpulse = Trig1.kr(trigEvents, 0.001);

    // === Phasor normal (lecture libre) ===
    phasorNormal = Phasor.ar(
        rate: rate,
        start: 0,
        end: bufFrames
    );

    // === Points de boucle latched sur le trigger ===
    loopStart = Latch.kr(phasorNormal, loopCaptureImpulse);
    loopEnd   = loopStart + loopFrames;

    // === Phasor en mode boucle ===
    phasorLoop = Phasor.ar(
        trig: trigImpulse,
        resetPos: loopStart,
        rate: rate,
        start: loopStart,
        end: loopEnd
    );

    // === Lecture audio ===
    sigNormal   = BufRd.ar(2, bufnum, phasorNormal, loop: 1);
    sigLoopRaw  = BufRd.ar(2, bufnum, phasorLoop, loop: 1);

    // === Fade sur les bords de la boucle ===
    fadeFrames = fadeTime * BufSampleRate.kr(bufnum);
    fadeInLoop  = ((phasorLoop - loopStart) / fadeFrames).clip(0, 1);
    fadeOutLoop = ((loopEnd - phasorLoop) / fadeFrames).clip(0, 1);
    fadeEnvLoop = fadeInLoop * fadeOutLoop;
    sigLoopRaw = sigLoopRaw * fadeEnvLoop;

    // === Fondu court lors d’un re-trigger pour éviter les clics ===
    fadeSafeTime = fadeTime.max(0.001);
    loopDelayed  = DelayN.ar(sigLoopRaw, fadeSafeTime, fadeSafeTime);
    retrigEnv    = Decay2.kr(trigImpulse, 0.001, fadeSafeTime);
    sigLoop      = (sigLoopRaw * (1 - retrigEnv)) + (loopDelayed * retrigEnv);

    // === Crossfade normal <-> loop ===
    loopOnLag     = LagUD.kr(loopOn, fadeTime, fadeTime);
    fadeEnvNormal = (1 - loopOnLag);
    loopMixEnv    = loopOnLag;
    sig = (sigNormal * fadeEnvNormal) + (sigLoop * loopMixEnv);

    // === Anti-clic supplémentaire lors d’un changement de trig ===
    crossEnv = LagUD.kr(trigEvents, smoothTime, smoothTime);
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
