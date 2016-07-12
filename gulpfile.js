var gulp = require('gulp');
var gutil = require('gulp-util');
var jade = require('gulp-jade');
var concat = require('gulp-concat');
var rename = require('gulp-rename');
var stylus = require('gulp-stylus');
var prefix = require('gulp-autoprefixer');
var bootstrap = require('bootstrap-styl');
var minify = require('gulp-clean-css');
var uglify = require('gulp-uglify');
var connect = require('gulp-connect');
var maps = require('gulp-sourcemaps');
var filter = require('gulp-filter');
var browserify = require('gulp-browserify');

var path = {
  'js': '../static/js',
  'css': '../static/css',
  'fonts': '../static/fonts'
}

var environment = 'development';

gulp.task('set-production', function() {
  environment = 'production';
});

var handleError = function (err) {
  gutil.log(err.toString());
  this.emit('end');
}

gulp.task('vendor', function(){
  return gulp.src([
    './bower_components/jquery/dist/jquery.js',
    './bower_components/bootstrap/dist/js/bootstrap.js',
    './bower_components/underscore/underscore.js',
    './bower_components/backbone/backbone.js',
    './bower_components/backbone.stickit/backbone.stickit.js',
    './bower_components/backbone-validator/backbone-validator.js',
  ])
  .pipe(uglify())
  .pipe(concat('vendor.js'))
  .pipe(gulp.dest(path.js));
});

gulp.task('plugin', function(){
  return gulp.src([
    './bower_components/moment/moment.js',
    './bower_components/bootstrap-daterangepicker/daterangepicker.js',
    './bower_components/bootstrap3-wysihtml5-bower/dist/bootstrap3-wysihtml5.all.js',
    './bower_components/bootstrap3-wysihtml5-bower/dist/locales/bootstrap-wysihtml5.zh-CN.js',
  ])
  .pipe(uglify())
  .pipe(concat('plugin.js'))
  .pipe(gulp.dest(path.js))
})

gulp.task('fonts', function(){
  return gulp.src('./bower_components/bootstrap/dist/fonts/**/*')
    .pipe(gulp.dest(path.fonts));
});

gulp.task('stylus', function() {
  var stream = gulp.src('./app/styles/app.styl')
    .pipe(maps.init())
    .pipe(stylus({
      use: [bootstrap()]
    }))
    .pipe(prefix({browsers: '> 1% in CN, iOS 7'}))
    .pipe(maps.write('./'))
    .pipe(gulp.dest(path.css));
  return stream;
});

gulp.task('browserify', function() {
  stream = gulp.src('./app/scripts/app.coffee', { read: false })
    .pipe(browserify({
      paths: ['./node_modules', './app/scripts', './app'],
      debug: environment == 'development',
      transform: ['coffeeify', 'jadeify'],
      extensions: ['.coffee', '.jade']
    })).on('error', handleError)
    .pipe(concat('app.js'))
    .pipe(gulp.dest(path.js))
    .pipe(maps.init())
    .pipe(rename('app.min.js'))
    .pipe(uglify())
    .pipe(maps.write('./'))
    .pipe(gulp.dest(path.js));
    return stream;
});

gulp.task('build', ['stylus', 'fonts', 'vendor', 'plugin', 'browserify']);
gulp.task('default', ['build']);
gulp.task('watch', ['build'], function() {
  gulp.watch('./app/styles/**/*.styl', ['stylus']);
  gulp.watch('./app/scripts/**/*.coffee', ['browserify']);
  gulp.watch('./app/templates/**/*.jade', ['browserify']);
});
