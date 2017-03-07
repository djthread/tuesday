const elmDiv  = document.getElementById('elm-main')
     , idapp  = Elm.Public.embed(elmDiv)
     , vjsUrl = "//vjs.zencdn.net/5.8.8/video.min.js";

let theaudio;

idapp.ports.activateVideo.subscribe((messageFromElm) => {
  loadScript(vjsUrl, () => {
    videojs.options.flash.swf = '/swf/video-js.swf';
    videojs(document.getElementById('thevideo'), {
      'fluid': true,
      'aspectRatio': '16:9'
    });
  });
});

idapp.ports.playEpisode.subscribe((messageFromElm) => {
  const audioPlayer = $(".audioplayer");

  if (audioPlayer.length) {
    theaudio = $("audio");
    theaudio.detach();
    audioPlayer.remove();
    $(".dock").append(theaudio);
  }

  theaudio = $("audio");
  theaudio.audioPlayer();
});


idapp.ports.getChatName.subscribe((messageFromElm) => {
  var chatname = localStorage.getItem("chatname");
  idapp.ports.gotChatName.send(chatname || "");
});

idapp.ports.setChatName.subscribe((chatname) => {
  localStorage.setItem("chatname", chatname || "");
});

idapp.ports.setTitle.subscribe((title) => {
  document.title = title;
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
        if (!done) {
            if (scr.readyState === "complete") {
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
