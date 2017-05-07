const elmDiv  = document.getElementById('elm-main')
     , idapp  = Elm.Public.embed(elmDiv)
     , vjsUrl = "//vjs.zencdn.net/5.8.8/video.min.js";

let theaudio;

idapp.ports.activateVideo.subscribe((messageFromElm) => {
  loadScript(vjsUrl, () => {
    videojs.options.flash.swf = '/swf/video-js.swf';
    videojs(document.getElementById('thevideo'), {
      'fluid': true,
      'aspectRatio': '16:9',
      'autoplay': true
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


idapp.ports.getChatNick.subscribe((messageFromElm) => {
  var chatnick = localStorage.getItem("chatnick");
  idapp.ports.gotChatNick.send(chatnick || "");
});

idapp.ports.setChatNick.subscribe((chatnick) => {
  localStorage.setItem("chatnick", chatnick || "");
});

idapp.ports.setTitle.subscribe((title) => {
  document.title = title;
});

idapp.ports.activateLightbox.subscribe((title) => {
  var lightbox;
  var options = {};
  // var options = {
  //   // boxId:              'photo-feed',
  //   dimensions:         true,
  //   captions:           true,
  //   prevImg:            false,
  //   nextImg:            false,
  //   hideCloseBtn:       false,
  //   closeOnClick:       true,
  //   loadingAnimation:   200,
  //   animElCount:        4,
  //   preload:            true,
  //   carousel:           true,
  //   animation:          400,
  //   nextOnClick:        true,
  //   responsive:         true,
  //   maxImgSize:         0.8,
  //   keyControls:        true,
  //   // callbacks
  //   onopen: function(){
  //       // ...
  //   },
  //   onclose: function(){
  //       // ...
  //   },
  //   onload: function(){
  //       // ...
  //   },
  //   onresize: function(event){
  //       // ...
  //   },
  //   onloaderror: function(event){
  //       // ...
  //   }
  // };

  lightbox = new Lightbox();
  lightbox.load(options);
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
