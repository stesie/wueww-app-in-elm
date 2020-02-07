const HtmlWebpackPlugin = require("html-webpack-plugin");
const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const cssnano = require("cssnano");

const cssLoaders = [
  MiniCssExtractPlugin.loader,
  "css-loader",
  { loader: "postcss-loader", options: { plugins: [cssnano()] } }
];

module.exports = {
  entry: "./src/index.ts",
  output: {
    filename: "bundle.js",
    libraryTarget: "umd"
  },
  resolve: {
    alias: {
      "../../theme.config$": path.join(
        __dirname,
        "/src/styling/theme.config.less"
      )
    },
    extensions: [".ts", ".js"],
    modules: ["node_modules"]
  },
  plugins: [
    new HtmlWebpackPlugin({
      title: "WueWW App",
      template: "./public/index.html"
    }),
    new MiniCssExtractPlugin({
      filename: "styles.css"
    })
  ],
  module: {
    rules: [
      {
        test: /\.less$/,
        use: [...cssLoaders, "less-loader"]
      },
      {
        test: /\.css$/,
        use: cssLoaders
      },
      {
        test: /\.ts$/i,
        exclude: [/node_modules/],
        loader: "ts-loader"
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: "elm-webpack-loader",
          options: {}
        }
      },
      {
        test: /\.jpe?g$|\.gif$|\.png$|\.ttf$|\.eot$|\.svg$/,
        use: "file-loader?name=[name].[ext]?[hash]"
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&mimetype=application/fontwoff"
      }
    ]
  }
};
