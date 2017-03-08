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
  console.log(theaudio);
  theaudio.audioPlayer();
});


idapp.ports.getChatName.subscribe((messageFromElm) => {
  var chatname = localStorage.getItem("chatname");
  idapp.ports.gotChatName.send(chatname || "");
});

idapp.ports.setChatName.subscribe((chatname) => {
  localStorage.setItem("chatname", chatname || "");
});

idapp.ports.loadPhotos.subscribe((messageFromElm) => {
  const
    loadButton = document.getElementById('photo-more-link'),
    feed = new Instafeed({
      get:      'user',
      userId:   '3231464724',
      // clientId: 'e4f766d90a1340e69cbf31289b297a9a',
      // accessToken: 'a9ca95e498c044d0ac696c0f38d0d544',
      accessToken: '3231464724.1677ed0.b23842419da9474d8246a9fcabb0ba68',
      limit:    4,
      target:   'photo-feed'
    });

  loadButton.addEventListener('click', function(event) {
    document.getElementById('photo-feed').innerHTML = '';
    feed.next();
    event.preventDefault();
  });

  feed.run();
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
