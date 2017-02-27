const elmDiv  = document.getElementById('elm-main')
     , idapp  = Elm.Public.embed(elmDiv)
     , vjsUrl = "//vjs.zencdn.net/5.8.8/video.min.js";

var theaudio;
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

  loadScript(vjsUrl, () => {
    videojs.options.flash.swf = '/swf/video-js.swf';
    videojs(document.getElementById('thevideo'), {
      'fluid': true,
      'aspectRatio': '16:9'
    });
  });

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



// ty, http://stackoverflow.com/questions/1293367/how-to-detect-if-javascript-files-are-loaded
function loadScript(path, callback) {

    var done = false;
    var scr = document.createElement('script');

    scr.onload = handleLoad;
    scr.onreadystatechange = handleReadyStateChange;
    scr.onerror = handleError;
    scr.src = path;
    document.body.appendChild(scr);

    function handleLoad() {
        if (!done) {
            done = true;
            callback(path, "ok");
        }
    }

    function handleReadyStateChange() {
        var state;

        if (!done) {
            state = scr.readyState;
            if (state === "complete") {
                handleLoad();
            }
        }
    }
    function handleError() {
        if (!done) {
            done = true;
            callback(path, "error");
        }
    }
}
