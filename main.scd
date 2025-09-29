// ======================
// Options serveur
// ======================
s.options.memSize = 2.pow(21);
s.options.numBuffers = 2048;
s.options.numWireBufs = 64;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
s.options.maxNodes = 1024;

// ======================
// Pitch de départ
// ======================
// ~pitch = 0.793700526; // 107.15 Ab
// ~pitch = 0.840896415; // 113.52 A
~pitch = 0.890898718; // 120.27 Bb
// ~pitch = 0.943874313; // 127.42 B
// ~pitch = 1; // 135 C
// ~pitch = 1.059463094; // 140.03 C#
// ~pitch = 1.122462; // 151.53 D

~environementPath = PathName.new(thisProcess.nowExecutingPath).pathOnly;

// ======================
// Routine principale
// ======================
~mixTick = Routine {
    ~bpm = 135 * ~pitch;

    // --- fichiers disponibles ---
    ~files = PathName("/Users/jordanquiqueret/Works/tracks").entries;

    // --- dictionnaire : deckName -> buffer actuel ---
    ~deckBuffers = IdentityDictionary.new;

    // --- chargement dynamique ---
    ~loadTrack = { |index, deck, deckName|
        Routine {
            if(index < ~files.size) {
                var key = deckName.asSymbol;
                var oldBuf = ~deckBuffers[key];

                Buffer.read(
                    s,
                    ~files[index].fullPath,
                    action: { |newBuf|
                        // assigner d’abord le nouveau
                        ~deckBuffers[key] = newBuf;
                        deck.set(\bufnum, newBuf.bufnum);

                        // synchro avec le transport (si le synth est actif)
                        if(deck.isPlaying) {
                            deck.set(\trig, 1);
                            AppClock.sched(0.01, {
                                if(deck.isPlaying) { deck.set(\trig, 0) }
                            });
                        };

                        ("[LOAD] Deck % → track % chargé : % (bufnum %, % frames, % canaux)")
                            .format(key, index, ~files[index].fileName, newBuf.bufnum, newBuf.numFrames, newBuf.numChannels)
                            .postln;

                        // libérer l’ancien seulement APRÈS assignation
                        if(oldBuf.notNil) {
                            ("[FREE] Deck % libère ancien buffer bufnum % (fichier: %)")
                                .format(key, oldBuf.bufnum, oldBuf.path).postln;
                            oldBuf.free;
                        };
                    }
                );
            };
        }.play(AppClock);
    };

    // --- connexions MIDI ---
    MIDIIn.connectAll;

    // charger les modules
    PathName(~environementPath++"modules/synths.scd").fullPath.load; s.sync;
    PathName(~environementPath++"modules/ui.scd").fullPath.load; s.sync;
    PathName(~environementPath++"modules/midiresponder.scd").fullPath.load; s.sync;

    // bus et limiter
    ~outputBus = Bus.audio(s, 2);
    ~limiter = Synth(\outputLimiter, [\input, ~outputBus, \out, 0]);

    // decks
    ~deck1 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \bpm, ~bpm, \out, ~outputBus]);
    ~deck2 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \bpm, ~bpm, \out, ~outputBus]);
    ~deck3 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \bpm, ~bpm, \out, ~outputBus]);
    ~deck4 = Synth(\bufferPlayer, [\bufnum, 0, \pitch, ~pitch, \amp, 0, \bpm, ~bpm, \out, ~outputBus]);
    s.sync;

    // fenêtre audio
    s.makeWindow;

    // ======================
    // Transport global
    // ======================
    ~beatDur = 60 / ~bpm;

    ~transport = Routine({
        loop {
            [~deck1, ~deck2, ~deck3, ~deck4].do { |d|
                if(d.notNil and: { d.isPlaying }) {
                    d.set(\trig, 1);
                    AppClock.sched(0.01, {
                        if(d.isPlaying) { d.set(\trig, 0) }
                    });
                };
            };
            ~beatDur.wait;
        }
    }).play(SystemClock);

    // ======================
    // Exemple d’appels
    // ======================
    // ~loadTrack.(0, ~deck1, \deck1);
    // ~loadTrack.(1, ~deck2, \deck2);
    // ~loadTrack.(2, ~deck3, \deck3);
    // ~loadTrack.(3, ~deck4, \deck4);
};

// ======================
// Boot serveur
// ======================
s.waitForBoot({ ~mixTick.play(AppClock) });
