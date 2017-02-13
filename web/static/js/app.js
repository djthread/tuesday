const node = document.getElementById('elm-main')
    , idapp = Elm.Public.embed(node);

idapp.ports.activateVideo.subscribe(
  function launchVideoJs(messagefromElm) {
    videojs.options.flash.swf = '/swf/video-js.swf';

    videojs(
      document.getElementById('thevideo'),
      {'fluid': true, 'aspectRatio': '16:9'}
    );

    return "score";
  }
);
