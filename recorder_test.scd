//Recorder and Loop-Player
(
var getplaylength, getLength;
~record = Buffer.alloc(s, s.sampleRate * 30.0, 1);
(
SynthDef(\Recorder, {arg out=0, bufnum=0,trig=0,reply=0,gater=1;//switch between intern or extern recording
	var sourceIn,sourceEx,frame,looper,endtrig;
	sourceIn=In.ar(0)+In.ar(1);
	sourceEx=SoundIn.ar(0);
	frame=Sweep.ar(trig, 44100);
	looper=BufWr.ar((sourceEx+sourceIn),bufnum,frame) *EnvGen.ar(Env.asr(0.015,1,0.01,-4),gate: gater, doneAction:2);
	SendReply.kr(reply,'/recordStopped/',frame+441);
	//SendReply.kr(DelayN.kr(reply, delaytime: 0.01),'/recordStopped/',frame);//delay trigger to have smooth transistions??
	//Out.ar(0,[source,source]);
}).add;);

(
SynthDef(\Player, {arg bufnum = 0, gater = 0, amp = 0, rate =1;
	var sound, toplay;
	sound = BufRd.ar(1, bufnum, Phasor.ar(0, BufRateScale.kr(bufnum)*rate, 0, BufFrames.kr(bufnum)));
	//toplay = sound * EnvGen.ar(Env.asr(0.03,1,0.03,-4),gate: gater, doneAction:2);
	toplay = sound;
	Out.ar([0,1], (toplay * amp)/1.3);
}).add;);

(
//var getplaylength, getLength;
//if all is called together var have to be called first -> see before Recorder
getplaylength=OSCFunc({|msg|
	msg[3].postln;
	getLength=msg[3];
	~copyBuf = Buffer.alloc(s, getLength, 1);
	//"buffer".postln;
	~copyBuf.zero;//srcStartAt: 0, see Buffer help
	~record.copyData(~copyBuf,  dstStartAt: 0, numSamples: getLength);
	"copy".postln;
	~player.set("bufnum", ~copyBuf,"gater",1);// set the new copyBuf for the playback
	"play".postln;
},'/recordStopped/');
);

(
~onoff = {arg num;
	if(num.value==1,{a=Synth.head(~recgroup, "Recorder",["bufnum", ~record, "trig",1])},0);
	if(num.value==0,{a.set("reply",1,"gater",0)});
});



s.sendBundle(0.5, ["/s_new", "recorder", x = s.nextNodeID, 0, ~recgroup], ["/n_set", x, "freq", 500]);
Server