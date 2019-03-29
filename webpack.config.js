'use strict';
const fs = require('fs');
const path = require('path');
const webpack = require("webpack");
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const extractCSS = new ExtractTextPlugin('./dist/css[name].css');
const prod = process.argv.indexOf('-p') !== -1;
const css_output_template = prod ? "javascript/src/[name]-[hash].css" : "javascript/src/[name].css";
const js_output_template = prod ? "javascripts/[name]-[hash].js" : "javascripts/[name].js";

module.exports = {
  context: __dirname + "/app",
  entry: {
      app: ['./src/base.js', './src/admin.js', './src/author.js'],
    },

  output: {
    path: __dirname + "/public",
    filename: "[name]-[hash]",
   },
  module: {
      loaders: [
          {
              test: /\.js$/,
              // exclude: /node_modules/,
              loader: 'babel-loader',
              query: {
                    presets: ['es2015']
                }
            },
            {
              test: /\.scss$/,
              use: [{
                    loader: "style-loader" // creates style nodes from JS strings
                }, {
                    loader: "css-loader" // translates CSS into CommonJS
                }, {
                    loader: "sass-loader" // compiles Sass to CSS
                }]
                // loader: ExtractTextPlugin.extract("css!sass")
            },
            {
                test: /\.(jpe?g|png|gif|svg)$/i,
                loader: 'file'
            },
            { test: /bootstrap-sass\/javascripts\//, loader: 'imports-loader?jQuery=jquery' },
            { test: /\.(woff2?|svg)$/, loader: 'url-loader?limit=10000&name=/fonts/[name].[ext]' },
            { test: /\.(ttf|eot)$/, loader: 'file-loader?name=/fonts/[name].[ext]' },
            {
              loader: 'file-loader',
              options: {
                  name (file) {
                      if (env === 'development') {
                          return '[path][name].[ext]'
                      }

                      return '[hash].[ext]'
                  }
              }
            },
          {
              test: /\.css$/,
              loaders: ["style-loader","css-loader"]
          },
          {
              test: /\.(gif|png|jpe?g|svg)$/i,
              use: [
                  'file-loader',
                  {
                      loader: 'image-webpack-loader',
                      options: {
                          limit: 8000,
                          mozjpeg: {
                              progressive: true,
                              quality: 65
                          },
                              // optipng.enabled: false will disable optipng
                          optipng: {
                              enabled: false,
                          },
                          pngquant: {
                              quality: '65-90',
                              speed: 4
                          },
                          gifsicle: {
                              interlaced: false,
                          },
                              // the webp option will enable WEBP
                          webp: {
                              quality: 75
                          }
                      }
                  },
              ],
          },
        ],

  },
    plugins: [
        new webpack.ProvidePlugin({
            $: 'jquery',
            jQuery: 'jquery',
            jquery: 'jquery'}),

        new webpack.ProvidePlugin({
            $: 'jquery-ui',
            jQuery: 'jquery-ui',
            'window.jQuery': 'jquery',
            'window.$': 'jquery',
        }),
        new ExtractTextPlugin(css_output_template),
            function() {
            // delete previous outputs
                this.plugin("compile", function () {
                    let basepath = __dirname + "/public";
                    let paths = ["javascript", "javascript/src", "javascript/styles", 'javascript/images'];

                    for (let x = 0; x < paths.length; x++) {
                        const asset_path = basepath + paths[x];

                        fs.readdir(asset_path, function (err, files) {
                            if (files === undefined) {
                                return;
                            }

                        for (let i = 0; i < files.length; i++) {
                            fs.unlinkSync(asset_path + "/" + files[i]);
                        }
                    });
                }
            });
            // output the fingerprint
            this.plugin("done", function(stats) {
                let output = "ASSET_FINGERPRINT = \"" + stats.hash + "\""
                fs.writeFileSync("config/initializers/fingerprint.rb", output, "utf8mb4");
            });
        }
      ]
};
