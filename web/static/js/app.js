const node = document.getElementById('elm-main')
    , idapp = Elm.Public.embed(node);

var theaudio, thevideo;
  // , audioFinder = setInterval(function() {
  //     audio = document.getElementById('theaudio');
  //     console.log('looking for audio:', audio);
  //     if (audio) clearInterval(audioFinder);
  //   }, 400);

/*
idapp.ports.init.subscribe((messageFromElm) => {
  $(document).foundation();
});
*/

idapp.ports.activateVideo.subscribe((messageFromElm) => {

  console.log('got signal');

  var tryvideo = setInterval(() => {
    thevideo = document.getElementById('thevideo');
    console.log('trying:', thevideo);
    if (!thevideo) return;

    clearInterval(tryvideo);
    console.log('calling!', thevideo);

    videojs.options.flash.swf = '/swf/video-js.swf';
    videojs(thevideo, {
      'fluid': true,
      'aspectRatio': '16:9'
    });
  }, 150);
});

var loadedAudioPlayer = false;

idapp.ports.playEpisode.subscribe((messageFromElm) => {
  var audioWatcher
    , player = $(".audioplayer");

  if (player.length) {
    console.log("rremoving player", player);
    theaudio = $("audio");
    console.log('got audio', theaudio.children());
    theaudio.detach();
    player.remove();
    $(".dock").append(theaudio);
    console.log('appended', theaudio, theaudio.children());
  }
  console.log('win');

  audioWatcher = setInterval(() => {
    theaudio = $("audio");
    console.log('trying', theaudio);

    if (!theaudio.length) return;

    clearInterval(audioWatcher);
    theaudio.audioPlayer();

    // theaudio.load();
    // theaudio.play();
  }, 150);
});


idapp.ports.getChatName.subscribe((messageFromElm) => {
  var chatname = localStorage.getItem("chatname");
  idapp.ports.gotChatName.send(chatname || "");
});

idapp.ports.setChatName.subscribe((chatname) => {
  localStorage.setItem("chatname", chatname || "");
});

