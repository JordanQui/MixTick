~createUI = {
    var window, bufferNames,
    textDeck1, textDeck2, textDeck3, textDeck4,
    listDeck1, listDeck2, listDeck3, listDeck4,
    loopSlider1, loopLabel1, loopSlider2, loopLabel2,
    loopSlider3, loopLabel3, loopSlider4, loopLabel4,
    freqscope,
    toggleLoop,
    loopSliders, loopShortcutMap, registerShortcut,
    resolveLoopShortcut, applyShortcut, shouldLogUnmapped;

    var applyDarkStyle = { |view|
        view.background_(Color.black).stringColor_(Color.white);
    };

    bufferNames = ~files.collect { |file| file.fileName };

    // Flags → morceaux joués
    ~playedFlags = Array.fill(bufferNames.size, { false });

    // Labels avec point devant si déjà joué
    ~getDisplayNames = {
        bufferNames.collect { |name, i|
            if (~playedFlags[i]) { "• " ++ name } { name }
        }
    };

    // Rafraîchir toutes les listes
    ~refreshAllMenus = {
        var names = ~getDisplayNames.();
        [listDeck1, listDeck2, listDeck3, listDeck4].do { |menu|
            if(menu.notNil) {
                var oldVal = menu.value;
                menu.items = names;
                menu.value = oldVal;
            }
        };
    };

    window = Window.new("Buffer Selector", Rect(100, 100, 500, 400))
        .background_(Color.black);

    // Helper pour toggler une boucle et répercuter l'état sur l'UI + le synth
    toggleLoop = { |slider|
        var current = slider.value.asInteger;
        var newVal = if(current == 0) { 1 } { 0 };
        slider.valueAction_(newVal);
    };

    // --- Deck 1 ---
    textDeck1 = StaticText(window).string_("Player Y Buffer:"); applyDarkStyle.(textDeck1);
    listDeck1 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck1.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck1, \deck1);   // ✅ synchro transport
    };
    loopLabel1 = StaticText(window).string_("Free"); applyDarkStyle.(loopLabel1);
    loopSlider1 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck1.set(\loopOn, val);
            if(val == 1) {
                ~deck1.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck1.set(\loopTrig, 0) });
            };
            loopLabel1.string = if(val == 1) { "Looped" } { "Loop OFF" };
        });

    // --- Deck 2 ---
    textDeck2 = StaticText(window).string_("Player X Buffer:"); applyDarkStyle.(textDeck2);
    listDeck2 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck2.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck2, \deck2);
    };
    loopLabel2 = StaticText(window).string_("Free"); applyDarkStyle.(loopLabel2);
    loopSlider2 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck2.set(\loopOn, val);
            if(val == 1) {
                ~deck2.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck2.set(\loopTrig, 0) });
            };
            loopLabel2.string = if(val == 1) { "Looped" } { "Loop OFF" };
        });

    // --- Deck 3 ---
    textDeck3 = StaticText(window).string_("Player Z Buffer:"); applyDarkStyle.(textDeck3);
    listDeck3 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck3.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck3, \deck3);
    };
    loopLabel3 = StaticText(window).string_("Free"); applyDarkStyle.(loopLabel3);
    loopSlider3 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck3.set(\loopOn, val);
            if(val == 1) {
                ~deck3.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck3.set(\loopTrig, 0) });
            };
            loopLabel3.string = if(val == 1) { "Looped" } { "Loop OFF" };
        });

    // --- Deck 4 ---
    textDeck4 = StaticText(window).string_("Player W Buffer:"); applyDarkStyle.(textDeck4);
    listDeck4 = PopUpMenu(window)
        .font_(Font("Helvetica", 35))
        .items_(~getDisplayNames.())
        .background_(Color.black)
        .stringColor_(Color.white);
    listDeck4.action = { |menu|
        var idx = menu.value;
        ~playedFlags[idx] = true;
        ~refreshAllMenus.();
        ~loadTrack.(idx, ~deck4, \deck4);
    };
    loopLabel4 = StaticText(window).string_("Free"); applyDarkStyle.(loopLabel4);
    loopSlider4 = Slider(window)
        .orientation_(\horizontal).minHeight_(100).thumbSize_(200).step_(1)
        .background_(Color.black).knobColor_(Color.white)
        .action_({ |sl|
            var val = sl.value.asInteger;
            ~deck4.set(\loopOn, val);
            if(val == 1) {
                ~deck4.set(\loopTrig, 1);
                AppClock.sched(0.01, { ~deck4.set(\loopTrig, 0) });
            };
            loopLabel4.string = if(val == 1) { "Looped" } { "Loop OFF" };
        });

    // --- Scope ---
    freqscope = FreqScopeView(window);
    freqscope.active_(true);

    // Préparer les raccourcis clavier (support QWERTY, AZERTY, overrides…)
    loopSliders = [loopSlider1, loopSlider2, loopSlider3, loopSlider4];
    loopShortcutMap = Dictionary.new;

    registerShortcut = { |keys, slider|
        var keyList;

        if(slider.isNil) { ^nil };

        keyList = if(keys.isArray) {
            keys
        } {
            if(keys.isKindOf(List)) {
                keys.asArray
            } {
                [keys]
            }
        };

        keyList.do { |key|
            if(key.notNil) {
                loopShortcutMap[key.asString.toLower] = slider;
            };
        };
    };

    resolveLoopShortcut = { |descriptor|
        if(descriptor.isNil) { ^nil };

        if(descriptor.isKindOf(Slider)) { ^descriptor };

        if(descriptor.isKindOf(Integer)) {
            var index = descriptor - 1;
            if(index >= 0 and: { index < loopSliders.size }) {
                ^loopSliders[index];
            } {
                ^nil;
            };
        };

        if(descriptor.isKindOf(Symbol)) {
            switch(descriptor,
                \loop1, { ^loopSlider1 },
                \deck1, { ^loopSlider1 },
                \loop2, { ^loopSlider2 },
                \deck2, { ^loopSlider2 },
                \loop3, { ^loopSlider3 },
                \deck3, { ^loopSlider3 },
                \loop4, { ^loopSlider4 },
                \deck4, { ^loopSlider4 },
                { ^nil }
            );
        };

        if(descriptor.isKindOf(String)) {
            ^resolveLoopShortcut.(descriptor.asSymbol);
        };

        ^nil;
    };

    registerShortcut.( ["w", "z"], loopSlider1 ); // W key on QWERTY, Z on AZERTY
    registerShortcut.( "x", loopSlider2 );
    registerShortcut.( "c", loopSlider3 );
    registerShortcut.( "v", loopSlider4 );

    if(~loopShortcutOverrides.isKindOf(Dictionary)) {
        ~loopShortcutOverrides.keysValuesDo { |key, descriptor|
            var slider = resolveLoopShortcut.(descriptor);

            if(slider.notNil) {
                registerShortcut.(key, slider);
            } {
                ("[MixTick] Impossible d'affecter le raccourci %: cible inconnue (%)"
                    .format(key, descriptor)).postln;
            };
        };
    };

    applyShortcut = { |keyString|
        var slider;

        if(keyString.isNil or: { keyString.size == 0 }) { ^false };

        slider = loopShortcutMap[keyString];

        if(slider.notNil) {
            toggleLoop.(slider);
            ^true;
        };

        ^false;
    };

    shouldLogUnmapped = (~loopShortcutDebug == true);

    // --- Layout ---
    window.layout_(
        VLayout(
            HLayout(
                VLayout(textDeck1, listDeck1, loopLabel1, loopSlider1),
                VLayout(textDeck2, listDeck2, loopLabel2, loopSlider2),
                VLayout(textDeck3, listDeck3, loopLabel3, loopSlider3),
                VLayout(textDeck4, listDeck4, loopLabel4, loopSlider4)
            ),
            freqscope
        )
    );

    window.view.keyDownAction_({ |view, char, modifiers, unicode, keycode|
        var matched = false;

        if(char.notNil) {
            matched = applyShortcut.(char.asString.toLower);
        };

        if(matched.not and: { unicode.notNil }) {
            var unicodeChar = unicode;

            if(unicodeChar.isKindOf(Integer)) {
                unicodeChar = unicodeChar.asAscii;
            };

            if(unicodeChar.notNil) {
                matched = applyShortcut.(unicodeChar.asString.toLower);
            };
        };

        if(matched.not and: { shouldLogUnmapped }) {
            var describe = { |value|
                if(value.isNil) { "nil" } { value.asString }
            };

            ("[MixTick] Touche non assignée → char:% unicode:% keycode:%"
                .format(
                    describe.(char),
                    describe.(unicode),
                    describe.(keycode)
                )).postln;
        };
    });

    window.onClose = { window.close; freqscope.kill };
    window.front;
};

~createUI.value;
