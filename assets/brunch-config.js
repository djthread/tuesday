exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"

      // To use a separate vendor.js bundle, specify two files path
      // https://github.com/brunch/brunch/blob/stable/docs/config.md#files
      // joinTo: {
      //  "js/app.js": /^(web\/static\/js)/,
      //  "js/vendor.js": /^(web\/static\/vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // https://github.com/brunch/brunch/tree/master/docs#concatenation
      // order: {
      //   before: [
      //     "web/static/vendor/js/jquery-2.1.1.js",
      //     "web/static/vendor/js/bootstrap.min.js"
      //   ]
      // }
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: [
          "css/app.scss"
        ]
      }
    // },
    // templates: {
    //   joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["../elm", "static", "css", "js", "vendor"],

    // Where to compile files to
    public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
    elmBrunch: {
      elmFolder: "../elm",
      mainModules: ["src/Public/Main.elm"],
      outputFolder: "../assets/vendor",
      outputFile: "elm.js",
      executablePath: "../assets/node_modules/elm/binwrappers"
    },
    uglify: {
      global_defs: {
        DEBUG: false
      },
      compress: {
        dead_code: true,
        properties: true,
        booleans: true,
        conditionals: true,
        sequences: true,
        loops: true,
        if_return: true,
        join_vars: true,
        cascade: true
      }
    },
    sass: {
      mode: "native",
      options: {
        sourceMapEmbed: true,
        // allowCache: true,
        // includePaths: [
        //   "node_modules/foundation/scss/"
        // ]
      }
    },
    copycat: {
      // "js": [
      //   // "node_modules/video.js/dist/video.min.js",
      //   // "node_modules/foundation/stylus/foundation.js"
      // ],
      "swf": [
        "node_modules/video.js/dist/video-js.swf"
      ],
      "ttf": [
        "ttf/desonanz.ttf"
      ],
    },
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/]
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["js/app"]
    }
  },

  npm: {
    enabled: true,
    // Whitelist the npm deps to be pulled in as front-end assets.
    // All other deps in package.json will be excluded from the bundle.
    whitelist: ["phoenix", "phoenix_html"]
  }
};
