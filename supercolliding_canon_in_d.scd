// supercolliding round-robin canon in d (~30 seconds)


// Server config and boot
(
Server.local.options.numInputBusChannels = 0;
Server.local.options.blockSize = 512;
// s.makeWindow;
s.reboot;
)

// Main code
(
t = TempoClock(76/60); // currently unused

// Defining global vars
~dmaj;
~dmaj = Dictionary[
	'A'->[9, 13, 16],
	'Bm'->[11, 14, 18],
	'D'->[2, 6, 9],
	'F#m'->[6, 9, 13],
	'G'->[7, 11, 14],
];

~selectedScales;
~selectedScales = [
	Scale.augmented2,
	Scale.chinese,
	Scale.locrian,
	Scale.saba,
	Scale.yu
];

// Creating some instruments
SynthDef(
	\harpsi, // as defined by scd docs
	{
		|outbus = 0, freq = 440, amp = 0.1, gate = 1|
		var out;
		out = EnvGen.ar(Env.adsr, gate, doneAction: Done.freeSelf) * amp * Pulse.ar(freq, 0.25, 0.75);
		Out.ar(outbus, out ! 2);
	}
).add;

SynthDef(
	\harpsi2, // slightly modified
	{
		|outbus = 0, freq = 440, amp = 0.1, gate = 1|
		var out;
    	out = EnvGen.ar(Env.adsr, gate, doneAction: Done.freeSelf) * amp * Pulse.ar(freq, 0.5, 0.75);
    	Out.ar(outbus, out ! 2);
	}
).add;

SynthDef(
	\weirdsynth1,
	{
		|outbus = 0, freq = 440, amp = 0.1, gate = 1|
		var out;
		out = EnvGen.ar(Env.adsr, gate, doneAction: Done.freeSelf) * amp * RLPF.ar(Pulse.ar(freq, 0.5, 0.1), XLine.kr(freq, 400, 5), 0.05);
		Out.ar(outbus, out ! 2);
	}
).add;

SynthDef(
	\weirdsynth2,
	{
		|outbus = 0, freq = 440, amp = 0.1, gate = 1|
		var out;
		out = EnvGen.ar(Env.adsr, gate, doneAction: Done.freeSelf) * amp * Saw.ar(freq, 0.9);
		Out.ar(outbus, out ! 2);
	}
).add;

// Defining patterns
// TODO: DRY Pbind code

~randomStartingNotes;
~randomStartingNotes = {
	arg instrument, scale, dur, amp;
	Pbind(
		\instrument,
		instrument,
		\scale,
		scale,
		\note,
		Pshuf([
			~dmaj['D'],
			~dmaj['A'],
			~dmaj['Bm'],
			~dmaj['F#m'],
			~dmaj['G'],
			~dmaj['D'],
			~dmaj['G'],
			~dmaj['A'],
			Rest(96)
		], 2),
		\dur,
		dur,
		\amp,
		amp
	).play;
};

~longSingleNotes;
~longSingleNotes = {
	arg instrument, scale, dur, amp;
	Pbind(
		\instrument,
		instrument,
		\scale,
		scale,
		\note,
		Pseq([
			Rest(36),
			~dmaj['D'][0],
			~dmaj['A'][0],
			~dmaj['Bm'][0],
			~dmaj['F#m'][0],
			~dmaj['G'][0],
			~dmaj['D'][0],
			~dmaj['G'][0],
			~dmaj['A'][0]
		], 4),
		\dur,
		dur,
		\amp,
		amp
	).play;
};

~longChords;
~longChords = {
	arg instrument, scale, dur, amp;
	Pbind(
		\instrument,
		instrument,
		\scale,
		scale,
		\note,
		Pser([
			~dmaj['D'],
			~dmaj['A'],
			~dmaj['Bm'],
			~dmaj['F#m'],
			~dmaj['G'],
			~dmaj['D'],
			~dmaj['G'],
			~dmaj['A'],
		], 16),
		\dur,
		dur,
		\amp,
		amp
	).play;
};

~shortChords;
~shortChords = {
	arg instrument, scale, dur, amp;
	Pbind(
		\instrument,
		instrument,
		\scale,
		scale,
		\note,
		Pseq([
			~dmaj['D'],
			~dmaj['D'],
			~dmaj['A'],
			~dmaj['A'],
			~dmaj['Bm'],
			~dmaj['Bm'],
			~dmaj['F#m'],
			~dmaj['F#m'],
			~dmaj['G'],
			~dmaj['G'],
			~dmaj['D'],
			~dmaj['D'],
			~dmaj['G'],
			~dmaj['G'],
			~dmaj['A'],
			~dmaj['A'],
		], 2),
		\dur,
		dur,
		\amp,
		amp
	).play;
};


// Playing defined patterns
~randomStartingNotes.value(\default, ~selectedScales.choose, 1.5, 0.05);
~longSingleNotes.value(\weirdsynth2, ~selectedScales.choose, 1.5, 0.1);
SystemClock.sched(12, {~longChords.value(\harpsi2, ~selectedScales.choose, 1.5, 0.2)});
SystemClock.sched(24, {~shortChords.value(\weirdsynth1, ~selectedScales.choose, 0.75, 0.3)});
)
