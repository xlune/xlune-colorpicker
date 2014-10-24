# require
gulp = require('gulp')
compass = require('gulp-compass')
minifyCSS = require('gulp-minify-css')
coffee = require('gulp-coffee')
gutil = require('gulp-util')
concat = require('gulp-concat')
uglify = require('gulp-uglify')
connect = require('gulp-connect')
rimraf = require('gulp-rimraf')
wait = require('gulp-wait')

# config
vendor_list = [
    'bower_components/webcomponentsjs/webcomponents.js'
    'bower_components/jquery/dist/jquery.js'

]
sass_list = [
    'src/sass/**/*.scss'
]
coffee_list = [
    'src/coffee/Config.coffee'
    'src/coffee/**/!(Main).coffee'
    'src/coffee/Main.coffee'
]

#css build
gulp.task 'compass', ->
    gulp.src(sass_list)
        .pipe(compass({
            config_file: 'src/sass/config.rb'
            comments: false
            css: 'src/css'
            sass: 'src/sass'
        }))
        .pipe(minifyCSS({keepBreaks:true}))
        .pipe(gulp.dest('./dist/css'))

#coffee build
gulp.task 'coffee', ->
    gulp.src(coffee_list)
        .pipe(concat('main.coffee'))
        .pipe(coffee({bare:true, header: false}).on('error', gutil.log))
        .pipe(gulp.dest('./src/js'))
        .pipe(uglify())
        .pipe(gulp.dest('./dist/js'))

#vendor build
gulp.task 'vendor', ->
    gulp.src(vendor_list)
        .pipe(concat('vendor.js'))
        .pipe(gulp.dest('./src/js'))
        # .pipe(uglify())
        # .pipe(gulp.dest('./dist/js'))

#source watch
gulp.task 'watch', ->
    gulp.watch vendor_list, ['vendor', 'reload']
    gulp.watch coffee_list, ['coffee', 'reload']
    gulp.watch sass_list, ['compass', 'reload']
    gulp.watch './src/*.html', ['reload']

#server
gulp.task 'connect', ->
    connect.server {
        root: 'src'
        livereload: true
        port: 8080
    }

#reload
gulp.task 'reload', ->
    gulp.src('./src/*.html')
        .pipe(connect.reload())

#copy
gulp.task 'copy', ->
    return
    # gulp.src(['./src/!(coffee|sass|js|css)/**', './src/!(coffee|sass|js|css)'])
    #     .pipe(wait(500))
    #     .pipe(gulp.dest('./dist'))

#clean
gulp.task 'clean', ->
    gulp.src('dist', {read: false})
        .pipe(rimraf())


#command
gulp.task 'default', ['build']
gulp.task 'build', ['clean', 'vendor', 'coffee', 'compass', 'copy']
gulp.task 'server', ['vendor', 'coffee', 'compass', 'watch', 'connect']
