const node = document.getElementById('elm-main')
    , idapp = Elm.Public.embed(node);

var audio;
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
  }, 250);
});

var loadedAudioPlayer = false;

idapp.ports.playEpisode.subscribe(
  function startEpisode(messageFromElm) {
    var audioWatcher
      , player = $(".audioplayer");

    if (player.length) {
      console.log("rremoving player", player);
      audio = $("audio");
      console.log('got audio', audio.children());
      audio.detach();
      player.remove();
      $(".dock").append(audio);
      console.log('appended', audio, audio.children());
    }
    console.log('win');

    audioWatcher = setInterval(() => {
      audio = $("audio");
      console.log('trying', audio);

      if (!audio.length) return;

      clearInterval(audioWatcher);
      audio.audioPlayer();

      // audio.load();
      //audio.play();
      // if (!loadedAudioPlayer) {
        // $('audio').audioPlayer();
        // loadedAudioPlayer = true;
      // }
/*
      setTimeout(() => {
        //$(() => { $('audio').audioPlayer(); });
      }, 200);
*/
    }, 120);
  }
);
