//syncEQ/S3SC


Server.program="SC_JACK_DEFAULT_OUTPUTS=\"system:playback_1,system:playback_2,ftpro34:playback_1,ftpro34:playback_2\" && scsynth";
s.boot;

b = Buffer.alloc(s,4096,1);
~fifoSize=10;
a=Array.fill(~fifoSize, {100});
FreqScope.new(400, 400, 0, server: s);
z=(SynthDef("syncEQSC", {
	arg lowcut=0;
	var in = AudioIn.ar(1);
	var out = HPF.ar(
		in,
		lowcut
	);

	Out.ar(0,
		out
	);
}).play(s););

(SynthDef("findPeak", {
	var in = AudioIn.ar(1);
	var chain = FFT(b.bufnum, in);
	var out;
	# f,m = FFTPeak.kr(chain);
	//f.at(0).poll(label:"Poll:",trigid:1, trig:20);
	f.poll(label:"Poll:",trigid:1, trig:20);
}).play(s);
);

o = OSCresponderNode(
		s.addr, '/tr', {arg time, resp, msg;
		var peak = msg.at(3);
		var avg = 0;
		a=a.shift(1).put(0,peak);
		a.do({arg item; avg=avg+item;});
		avg=avg/a.size();
		z.set(\lowcut, avg);
		"Filter set: ".post;
		avg.post;
		"Hz".postln;
}).add();

	//o.remove();

