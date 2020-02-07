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
    extensions: [".ts", ".js"],
    modules: ["node_modules"]
  },
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
      }
    ]
  }
};
