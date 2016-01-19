// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import {Socket, LongPoller} from "phoenix"

class App {

  static init() {
    this.startChat()
    this.startProjekktor()
  }

  static startProjekktor() {
    projekktor('#player_a', {
      poster: '/images/intro.jpg',
      title: 'Techno Tuesday',
      playerFlashMP4: '/projekktor/swf/StrobeMediaPlayback/StrobeMediaPlayback.swf',
      playerFlashMP3: '/projekktor/swf/StrobeMediaPlayback/StrobeMediaPlayback.swf',
      width: 600,
      height: 400,
      platforms: ['browser', 'flash', 'vlc'],
      //platforms: ['browser', 'android', 'ios', 'native', 'flash', 'vlc'],
      playlist: [ { 0: {
        src: 'rtmp://tuesday.threadbox.net/live/techno', streamType:'rtmp', type:'video/flv'
      } } ]
    }, function(player) {
        window.p = player;
        p.setDebug(true);
    })
  }

  static startChat() {
		let socket = new Socket("/socket", {
      logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}`, data) })
    })

    socket.connect({user_id: "123"})

    var $status    = $("#status")
    var $messages  = $("#messages")
    var $input     = $("#message-input")
    var $username  = $("#username")

    socket.onOpen( ev => console.log("OPEN", ev) )
    socket.onError( ev => console.log("ERROR", ev) )
    socket.onClose( e => console.log("CLOSE", e))

    var chan = socket.channel("rooms:lobby", {})
    chan.join().receive("ignore", () => console.log("auth error"))
               .receive("ok",     () => console.log("join ok"))
               .receive("error",  () => console.log("Connection interruption"))

    chan.onError(e => console.log("something went wrong", e))
    chan.onClose(e => console.log("channel closed", e))

    $input.off("keypress").on("keypress", e => {
      if (e.keyCode == 13) {
        chan.push("new:msg", {user: $username.val(), body: $input.val()})
        $input.val("")
      }
    })

    chan.on("new:msg", msg => {
      $messages.append(this.messageTemplate(msg))
      // scrollTo(0, document.body.scrollHeight)
			$messages.animate({scrollTop: $messages[0].scrollHeight}, 1000)
    })

    chan.on("user:entered", msg => {
      var username = this.sanitize(msg.user || "anonymous")
      $messages.append(`<br/><i>[${username} entered]</i>`)
    })
  }

  static sanitize(html) { return $("<div/>").text(html).html() }

  static messageTemplate(msg) {
    let username = this.sanitize(msg.user || "anonymous")
    let body     = this.sanitize(msg.body)

    return(`<p><a href='#'>[${username}]</a>&nbsp; ${body}</p>`)
  }

}

$( () => App.init() )

export default App
