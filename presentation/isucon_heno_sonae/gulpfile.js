var gulp = require('gulp');
var connect = require('gulp-connect');
var exec = require('child_process').exec;

gulp.task('serve', ['connect'], function() {
  gulp.watch([
    '*.go', '*.md', '*.tmpl'
  ]).on('change', function(changedFile) {
    exec('go run main.go');
    // go runをちょっとまってからlivereloadを実行
    setTimeout(function() {
      gulp.src(changedFile.path).pipe(connect.reload());
    }, 1000);
  });
});

gulp.task('connect', function() {
  connect.server({
    root: ['.'],
  port: 3000,
  livereload: true
  });
});
gulp.task('default', ['serve']);
